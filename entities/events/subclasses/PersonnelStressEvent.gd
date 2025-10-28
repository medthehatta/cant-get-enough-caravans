extends Event
class_name PersonnelStressEvent

@export var stress: float = 0


static func create(stress_: float = 0):
    var event = PersonnelStressEvent.new()
    event.stress = stress_
    return event