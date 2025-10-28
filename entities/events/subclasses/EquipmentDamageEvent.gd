extends Event
class_name EquipmentDamageEvent

@export var kinetic: float = 0
@export var thermal: float = 0
@export var electromagnetic: float = 0
@export var explosive: float = 0


static func create(
    kinetic_: float = 0,
    thermal_: float = 0,
    electromagnetic_: float = 0,
    explosive_: float = 0,
):
    var event = EquipmentDamageEvent.new()
    event.kinetic = kinetic_
    event.thermal = thermal_
    event.electromagnetic = electromagnetic_
    event.explosive = explosive_
    return event