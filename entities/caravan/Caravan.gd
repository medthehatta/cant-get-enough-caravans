extends Actor
class_name Caravan


@export var leader: Person
@export var personnel: Array[Person] = []
@export var equipment: Array[Equipment] = []
# TODO: Temporary measures of food and power consumption
@export var food_calories: int
@export var equipment_power: int


func base_stats():
    return {
        "name": name,
        "_kind": "Caravan",
    }


func dynamic_stats():
    return {
        "remaining_food_calories": food_calories,
        "remaining_equipment_power": equipment_power,
        "auras": auras,
    }


# Override because we need to talk to our children
func respond(event: String, args: Dictionary = {}, current: StateDiffAggregate = null):
    current = current if current else StateDiffAggregate.new()

    var responses = StateDiffAggregate.new()

    responses.append_array(leader.respond(event, args, current))

    for person in personnel:
        responses.append_array(person.respond(event, args, current))

    for device in equipment:
        responses.append_array(device.respond(event, args, current))

    # Do self last
    responses.append(super.respond(event, args, current))

    return responses