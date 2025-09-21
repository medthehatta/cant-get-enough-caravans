extends Resource
class_name Aura


@export var name: String
@export var owner: Resource
@export var hidden: bool = false
@export var tags: Array[String] = []


func respond(_event: String, _args: Dictionary, _current: StateDiffAggregate):
    return StateDiffFactory.new().no_op(self)