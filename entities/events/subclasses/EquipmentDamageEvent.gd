extends Event
class_name EquipmentDamageEvent

@export var kinetic: float = 0
@export var thermal: float = 0
@export var electromagnetic: float = 0
@export var explosive: float = 0


static func create(dmg: Dictionary):
    check_dictionary(
        ["kinetic", "thermal", "electromagnetic", "explosive"],
        dmg,
    )
    var event = EquipmentDamageEvent.new()
    event.kinetic = dmg.get("kinetic", 0)
    event.thermal = dmg.get("thermal", 0)
    event.electromagnetic = dmg.get("electromagnetic", 0)
    event.explosive = dmg.get("explosive", 0)
    return event


static func copy(d):
    return create(
        {
            "kinetic": d.kinetic,
            "thermal": d.thermal,
            "electromagnetic": d.electromagnetic,
            "explosive": d.explosive,
        }
    )