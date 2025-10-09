extends Modifier
class_name ConstantMultiplyAttributeModifier


@export var attribute: String
@export var value: int


func apply(inp):
    var new = (inp as Dictionary).duplicate()
    # FIXME: For now we are doing this with ints.  We really should have an int and float version
    new[attribute] = int(new.get(attribute, 0) * value)
    return new


func tags():
    return super.tags() + ["multiplicative", "attribute", attribute]


func as_string():
    return "multiply {} by {}".format(value, attribute)