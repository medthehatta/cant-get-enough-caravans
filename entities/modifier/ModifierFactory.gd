extends Resource
class_name ModifierFactory


func noop():
    return (NoOpModifier.new() as Modifier)


func add_to_attribute(attr: String, value: float):
    var mod = AddToAttributeModifier.new()
    mod.attribute = attr
    mod.value = value
    return (mod as Modifier)


func multiply_attribute(attr: String, value: float):
    var mod = ConstantMultiplyAttributeModifier.new()
    mod.attribute = attr
    mod.value = value
    return (mod as Modifier)