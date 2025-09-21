extends Resource
class_name ResourceValidator


@export var debug: bool = false


func debug_print(msg):
    if debug:
        print(msg)


func validate(_resource: Resource) -> bool:
    print("Do not use the base Validator")
    return false
