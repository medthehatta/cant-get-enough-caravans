extends Resource
class_name Actor


@export var name: String
@export var auras: Array[Aura] = []


func modify(event: String, initial: Variant):
    var mods = []
    for aura in auras:
        var mod = aura.modify(event, initial)
        mods.append_array(mod)
    return mods


func collect(event: String, initial: Variant):
    var modifiers = modify(event, initial)
    # TODO: Ordering
    var modified = Modifier.modified(initial, modifiers)
    return modified