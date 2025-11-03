extends Modifier
class_name AddToAttributeModifier


@export var attribute: String
@export var value: float


func apply(inp: Resource):
    if inp.has(attribute):
        inp.set(attribute, inp.get(attribute) + value)
    return inp


func tags():
    return super.tags() + ["additive", "attribute", attribute]


func as_string():
    return "add {} to {}".format([value, attribute], "{}")