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


func clamp_attribute(attr: String, min_value: float, max_value: float):
    var mod = ClampAttributeModifier.new()
    mod.attribute = attr
    mod.min_value = min_value
    mod.max_value = max_value
    return (mod as Modifier)