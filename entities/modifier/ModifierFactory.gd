extends Resource
class_name ModifierFactory


func noop():
    return NoOpModifier.new()


func add_to_attribute(attr: String, value: int):
    var mod = AddToAttributeModifier.new()
    mod.attribute = attr
    mod.value = value
    return mod


func multiply_attribute(attr: String, value: int):
    var mod = ConstantMultiplyAttributeModifier.new()
    mod.attribute = attr
    mod.value = value
    return mod