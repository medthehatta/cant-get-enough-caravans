from pprint import pprint
from random import shuffle
from random import Random
from choice import Choice


pct = Choice.percentage
weight = Choice.weighted
otherwise = Choice.otherwise
delayed = Choice.delayed
disj = Choice.of


rng = Random()


def ev(x):
    return x.evaluate(rng)


@delayed
def _tup(*s):
    return tuple(s)


magnitude = disj("small", "normal", "large", "huge")


def allowed_magnitude(min_=None, max_=None):
    every = ["small", "normal", "large", "huge"]
    started = True if min_ is None else False
    result = []
    for e in every:
        if e == min_:
            started = True
        if started:
            result.append(e)
        if e == max_:
            return result
    else:
        return result


dmg_type = disj("kinetic", "thermal", "explosive", "electromagnetic")


def allowed_combat_typed(affinity, magnitude):
    return disj(
        _tup("equipment", "attack", affinity, magnitude),
        _tup("equipment", "defend", affinity, magnitude),
        _tup("equipment", "attack-debuff", affinity, magnitude),
    )


def allowed_combat_untyped(affinity, magnitude):
    return disj(
        _tup("equipment", "increase-hp", magnitude),
        _tup("equipment", "targeting-jammer", magnitude),
        _tup("equipment", "targeting-improvement", magnitude),
        _tup("equipment", "speed-debuff", magnitude),
        _tup("equipment", "power-vamp", magnitude),
        _tup("equipment", "personnel-confuser", magnitude),
    )


def allowed_utility(affinity, magnitude):
    return disj(
        _tup("equipment", "cargo", magnitude),
        _tup("equipment", "power-generation", magnitude),
        _tup("equipment", "speed", magnitude, "from fuel"),
        _tup("equipment", "speed", magnitude, "from power"),
        _tup("equipment", "loot-scanner", magnitude),
        _tup("equipment", "weight-debuff-mitigation", magnitude),
    )


def allowed_fuel(affinity, magnitude):
    return disj(
        _tup("fuel", "fuel", magnitude),
        _tup("fuel", "power", magnitude),
        _tup("fuel", "coolant", magnitude),
        _tup("fuel", "ammo", affinity, magnitude),
    )


def allowed_structures(affinity, magnitude):
    return disj(
        _tup("struct", "crafting-station"),
        _tup("struct", "training-center"),
        _tup("struct", "hospital"),
        _tup("struct", "repair/refuel"),
        _tup("struct", "kitchen"),
    )


affinity = disj("red", "green", "blue", "black", "white")


def allowed_materials(affinity, magnitude):
    return disj(
        _tup("raw", "solid", affinity),
        _tup("raw", "liquid", affinity),
        _tup("raw", "volatile", affinity),
    )


nonneutral_faction = _tup("faction", affinity, affinity)
neutral_faction = _tup("faction", "neutral")
faction = disj(neutral_faction, nonneutral_faction)

vendor_kind = disj("military", "logistics", "structure", "material")


personnel = disj(
    _tup("person", "cartographer"),
    _tup("person", "cook"),
    _tup("person", "military"),
    _tup("person", "engineer"),
    _tup("person", "diplomat"),
    _tup("person", "merchant"),
    _tup("person", "instructor"),
    _tup("person", "scientist"),
    _tup("person", "doctor"),
)


def _affinity_for_faction(fac):
    match fac:
        case ("faction", a1, a2):
            return disj(weight(3, a1), weight(1, a2))
        case ("faction", "neutral"):
            return affinity


def successor_to(poi=None, fac=None, vkind=None):
    fac = fac or faction
    vkind = vkind or vendor_kind

    match poi:
        case ("null",) | None:
            return disj(
                weight(8, _tup("vendor", vkind, "small", disj(fac, neutral_faction))),
                weight(5, _tup("repair/refuel")),
                weight(3, _tup("warehouse")),
                weight(2, _tup("vendor", vkind, "medium", disj(fac, neutral_faction))),
                weight(1, _tup("rumor-mill", disj(fac, neutral_faction))),
            )

        case ("vendor", kind, "small", fac):
            return disj(
                weight(5, _tup("vendor", kind, "medium", disj(fac, neutral_faction))),
                weight(4, _tup("discount", "small")),
                weight(3, _tup("rumor-mill", disj(fac, neutral_faction))),
                weight(2, _tup("warehouse")),
                weight(2, _tup("repair/refuel")),
                weight(2, _tup("recipe")),
                weight(1, _tup("discount", "medium")),
            )

        case ("vendor", kind, "medium", fac):
            return disj(
                weight(4, _tup("recipe")),
                weight(4, _tup("discount", "small")),
                weight(3, _tup("rumor-mill", disj(fac, neutral_faction))),
                weight(1, _tup("vendor", kind, "large", disj(fac, neutral_faction))),
                weight(1, _tup("discount", "medium")),
            )

        case ("rumor-mill", fac):
            return disj(
                weight(1, _tup("cartographer", disj(fac, neutral_faction))),
                weight(1, _tup("recruit", disj(fac, neutral_faction))),
            )

        case ("repair/refuel",):
            return disj(
                weight(5, _tup("rumor-mill", disj(fac, neutral_faction))),
                # FIXME: vendor_kinds just uses the provided distribution, it
                # is unable to look at the local "context" because
                # repair/refuel doesn't have a vendor kind.
                weight(2, _tup("crafting", vkind, disj(fac, neutral_faction))),
            )

        case ("warehouse",):
            return disj(
                _tup("repair/refuel"),
            )

        case ("recipe",):
            return disj(
                _tup("augment"),
            )

        case _:
            return Choice.solo(None)


d_successor_to = delayed(successor_to)


def make_poi(rng):
    fac = faction.evaluate(rng)
    mfac = faction
    aff = _affinity_for_faction(fac)

    starter = successor_to(None, fac).evaluate(rng)

    @delayed
    def _vendor_kind_from(starter):
        match starter:
            case ("vendor", kind, _, _):
                return Choice.solo(kind)
            case _:
                return vendor_kind

    vkind = _vendor_kind_from(starter)

    topology = disj(
        [2, 2, 2],
        [2, 2, 1],
        [2, 1, 1],
        [2, 1, 0],
        [1, 1, 0],
        [1, 0, 0],
        [2, 0, 0],
    ).evaluate(rng)

    to_deliver = _tup(disj("equipment", "fuel", "raw"), faction)

    def _quests(mag, fc, aff):
        return disj(
            weight(5, _tup("quest", "deliver", to_deliver, "me")),
            weight(5, _tup("quest", "deliver", to_deliver, fc)),
            weight(1, _tup("quest", "pay", "cash", "me")),
            weight(2, _tup("quest", "pay", "cash", fc)),
        )

    children = []
    shuffle(topology)
    for num in topology:
        child = []
        new = starter
        for _ in range(num):
            new = successor_to(new, fac, vkind).evaluate(rng)
            if not new:
                break
            q = _quests("small", mfac, aff).evaluate(rng)
            child.append((q, new))
        children.append(child)

    return (starter, children)


def pretty(tup):
    match tup:
        case ("faction", x, y):
            modded = ("faction", f"{x}{y}")
        case _:
            modded = tup

    if isinstance(tup, (tuple, list)):
        return "(" + " ".join(str(pretty(x)) for x in modded) + ")"
    else:
        return modded


def printable(poi):
    lines = []
    (start, children) = poi
    lines.append(f"=== {pretty(start)} ===")
    for child in children:
        if not child:
            continue
        for layer in child:
            (quest, what) = layer
            lines.append(f"{pretty(quest)}\n        {pretty(what)}")
        lines.append("-----")
    return "\n".join(lines)
