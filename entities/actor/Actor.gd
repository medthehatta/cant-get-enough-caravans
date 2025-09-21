extends Resource
class_name Actor


@export var name: String
@export var auras: Array[Aura] = []


func respond(event: String, args: Dictionary, current: StateDiffAggregate):
    var responses = StateDiffAggregate.new()
    for aura in auras:
        if current.active(aura):
            continue
        var response = aura.respond(event, args, current)
        responses.append(response)
    return responses