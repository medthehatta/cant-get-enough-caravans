extends Modifier
class_name ConstantMultiplyAttributeModifier


@export var attribute: String
@export var value: float


func apply(inp):
    var new = (inp as Dictionary).duplicate()
    new[attribute] = new.get(attribute, 0) * value
    return new


func tags():
    return super.tags() + ["multiplicative", "attribute", attribute]


func as_string():
    return "multiply {} by {}".format(value, attribute)