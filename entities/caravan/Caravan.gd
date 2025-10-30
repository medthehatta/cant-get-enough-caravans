extends Actor
class_name Caravan


@export var leader: Person
@export var personnel: Array[Person] = []
@export var equipment: Array[Equipment] = []
# TODO: Temporary measures of food and power consumption
@export var food_calories: float
@export var equipment_power: float
@export var weight: float


var mods = ModifierFactory.new()


func base_stats():
    return {
        "name": name,
        "_kind": "Caravan",
    }


func dynamic_stats():
    return {
        "remaining_food_calories": food_calories,
        "remaining_equipment_power": equipment_power,
        "weight": weight,
        "auras": auras,
    }


func _collect(_event: Event):
    return []


# Override because we need to talk to our children
func collect(event: Event):
    var responses = []

    responses.append_array(leader.collect(event))

    for person in personnel:
        responses.append_array(person.collect(event))

    for device in equipment:
        responses.append_array(device.collect(event))

    # Do self last
    responses.append_array(_collect(event))

    return responses


func inflict_damage_to_caravan(damage):
    for child in equipment:
        var modified_damage = child.modify(damage)
        child.inflict_damage(modified_damage)


func inflict_stress_to_caravan(stress):
    for child in [leader] + personnel:
        var modified_stress = child.modify(stress)
        child.inflict_stress(modified_stress)


func contribute_xp_to_caravan(xp):
    for child in [leader] + personnel:
        var modified_xp = child.modify(xp)
        child.contribute_xp(modified_xp)


func consume_caravan_resources(consumption):
    # DEBUG: FIXME: skip for now
    return

    # FIXME: Each collect might actually need to be a derived event
    var consumed_calories = 0
    var consumed_power = 0
    var generated_power = 0

    # Calculate food calories consumed
    for child in [leader] + personnel:
        var modified_consumption = child.modify(consumption)
        consumed_calories += modified_consumption["calories"]

    # Consume food calories
    # TODO: This should actually consume inventory items, but we're not modeling that yet
    # TODO: This should also reduce the weight
    if food_calories >= consumed_calories:
        food_calories -= consumed_calories
    else:
        assert(false) # die, for now

    # Calculate power consumed
    for child in equipment:
        var modified_consumption = child.modify(consumption)
        consumed_power += modified_consumption["power"]

    # Consume power
    # TODO: This should also reduce the weight if the power is consumed from physical fuel
    if equipment_power >= consumed_power:
        equipment_power -= consumed_power
    else:
        assert(false) # die, for now

    # Calculate power generated
    for child in equipment:
        var modified_generation = child.modify(consumption)
        generated_power += modified_generation["power"]

    # Generate power
    equipment_power += generated_power


func receive_loot(loot):
    pass


func summary():
    var responses = []

    responses.append(leader.dynamic_stats())

    for person in personnel:
        responses.append(person.dynamic_stats())

    for device in equipment:
        responses.append(device.dynamic_stats())

    # Do self last
    responses.append(dynamic_stats())

    var printable_entries = []

    for resp in responses:
        printable_entries.append(str(resp))

    return "\n".join(printable_entries)
