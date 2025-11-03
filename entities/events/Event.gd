extends Resource
class_name Event


static func check_dictionary(keys: Array, dict: Dictionary):
    for k in dict.keys():
        if not keys.has(k):
            print("Unexpected key: {0}".format([k]))
            assert(false)


func modify(modifiers: Array):
    # TODO: Ordering
    return ([self] + modifiers).reduce(func(acc, m): return m.apply(acc))


func modify_with(actors: Array):
    var mods: Array[Modifier] = []
    for act in actors:
        mods.append_array(act.collect(self))
    return modify(mods)


func copy_to(new_klass: Script):
    var props = get_property_list()
    var relevant = []
    for prop in props:
        if (prop["usage"] & (PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE)):
            relevant.append(prop["name"])
    var new = new_klass.new()
    for prop in relevant:
        new.set(prop, get(prop))
    return new
