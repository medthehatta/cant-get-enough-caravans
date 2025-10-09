extends Modifier
class_name AddToAttributeModifier


@export var attribute: String
@export var value: int


func apply(inp):
    var new = (inp as Dictionary).duplicate()
    new[attribute] = new.get(attribute, 0) + value
    return new


func tags():
    return super.tags() + ["additive", "attribute", attribute]


func as_string():
    return "add {} to {}".format(value, attribute)