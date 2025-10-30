extends Event
class_name CaravanTileProgressEvent

@export var speed: float = 1


static func create():
    var event = CaravanTileProgressEvent.new()
    event.speed = 1
    return event