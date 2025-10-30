extends Resource
class_name Actor


@export var name: String
@export var auras: Array[Aura] = []


func collect(event: Event):
    var mods = []
    for aura in auras:
        var mod = aura.collect2(event)
        mods.append_array(mod)
    return mods


func modify(event: Event):
    var modifiers = collect(event)
    # TODO: Ordering
    var modified = Modifier.modified(event, modifiers)
    return modified
