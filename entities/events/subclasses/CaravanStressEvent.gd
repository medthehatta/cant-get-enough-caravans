extends Event
class_name CaravanStressEvent

@export var stress: float = 0


static func create(stress_: float = 0):
    var event = CaravanStressEvent.new()
    event.stress = stress_
    return event