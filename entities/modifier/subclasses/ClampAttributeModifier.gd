extends Modifier
class_name ClampAttributeModifier


@export var attribute: String
@export var min_value: float
@export var max_value: float


func _apply(x):
    return clamp(x, min_value, max_value)


func apply(inp):
    if inp.has(attribute):
        inp.set(attribute, _apply(inp.get(attribute)))
    return inp


func tags():
    return super.tags() + ["clamp", "attribute", attribute]


func as_string():
    return "clamp {} between {} and {}".format([attribute, min_value, max_value], "{}")