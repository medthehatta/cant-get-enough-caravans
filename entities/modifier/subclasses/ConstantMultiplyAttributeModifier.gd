extends Modifier
class_name ConstantMultiplyAttributeModifier


@export var attribute: String
@export var value: float


func apply(inp):
    if inp.has(attribute):
        inp.set(attribute, inp.get(attribute) * value)
    return inp


func tags():
    return super.tags() + ["multiplicative", "attribute", attribute]


func as_string():
    return "multiply {} by {}".format([attribute, value], "{}")