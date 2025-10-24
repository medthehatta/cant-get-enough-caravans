extends Resource
class_name Aura


@export var name: String
@export var owner: Resource
@export var hidden: bool = false
@export var tags: Array[String] = []


func modify(_event: String, _initial: Variant):
    return []