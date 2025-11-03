extends Resource
class_name Modifier


@export var modifier_name: String
@export var originator: Resource


func apply(inp):
    return inp


func tags():
    return []


func as_string():
    return ""


static func modified(initial: Variant, modifiers: Array):
    # TODO: Ordering
    return ([initial] + modifiers).reduce(func(acc, m): return m.apply(acc))
