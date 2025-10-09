extends Modifier
class_name NoOpModifier


func apply(inp):
    return inp


func tags():
    return super.tags() + ["noop"]


func as_string():
    return ""