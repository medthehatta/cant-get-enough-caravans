@tool
extends Control
class_name PropertyIcons


var processed_entries: Dictionary = {}


@export var debug: bool = false


func debug_print(msg):
    if debug:
        print(msg)


func _ready():
    if not Engine.is_editor_hint():
        %Preview.visible = false

        var icon_map_entries = %ChildContainer.get_children()

        for entry in icon_map_entries:
            var texture_path = entry.texture.resource_path
            var parsed = parse_prop_name(entry.name)
            add_parsed_prop(parsed, texture_path)

        debug_print(processed_entries)


func get_icon(prop: String, kind: String = ""):
    if prop not in processed_entries:
        debug_print("Did not find {a} in processed_entries".format({"a": prop, "b": kind}))
        return null
    
    if kind not in processed_entries[prop]:
        debug_print("Did not find {b} in processed_entries for {a}".format({"a": prop, "b": kind}))

        if "" in processed_entries[prop]:
            debug_print("But found default for {a}, using it".format({"a": prop}))
            return processed_entries[prop][""]
        else:
            debug_print("And found no default for {a}, no icon will be used".format({"a": prop}))
            return null

    return processed_entries[prop][kind]


func parse_prop_name(s):
    var name_components = s.split("+", true, 2)
    var prop_name: String
    var kind_name: String

    if len(name_components) == 1:
        prop_name = name_components[0]
        kind_name = ""
    elif len(name_components) == 2:
        prop_name = name_components[0]
        kind_name = name_components[1]
    else:
        prop_name = ""
        kind_name = ""

    return {"prop": prop_name, "kind": kind_name}


func add_parsed_prop(p, texture_path):
    var prop_name = p["prop"]
    var kind_name = p["kind"]

    if prop_name not in processed_entries:
        processed_entries[prop_name] = {kind_name: texture_path}
    else:
        processed_entries[prop_name][kind_name] = texture_path


func remove_parsed_prop(p):
    var prop_name = p["prop"]
    var kind_name = p["kind"]

    if prop_name in processed_entries:
        if kind_name in processed_entries[prop_name]:
            processed_entries[prop_name].erase(kind_name)
        processed_entries.erase(prop_name)


func render_entries(entries, embedded_size):
    var txt = ""

    for prop_name in entries.keys():
        for kind in entries[prop_name].keys():
            var kind_txt: String
            if not kind:
                kind_txt = ""
            else:
                kind_txt = " ({a})".format({"a": kind})
            var tex_path = entries[prop_name][kind]

            var tpl = "[img={sz},center,center]{texture_path}[/img] {prop_name}{kind_txt}\n"
            txt += tpl.format({"texture_path": tex_path, "prop_name": prop_name, "kind_txt": kind_txt, "sz": int(2 * embedded_size)})

    return txt


func _process(_delta: float):
    if not Engine.is_editor_hint():
        return

    var icon_map_entries = %ChildContainer.get_children()

    for entry in icon_map_entries:
        if not entry.texture:
            continue
        var texture_path = entry.texture.resource_path
        var parsed = parse_prop_name(entry.name)
        add_parsed_prop(parsed, texture_path)

    var embedded_size = %Preview.get_theme_font_size("normal_font_size")
    %Preview.text = render_entries(processed_entries, embedded_size)


func _on_child_container_child_exiting_tree(node: Node) -> void:
    var parsed = parse_prop_name(node.name)
    remove_parsed_prop(parsed)


func iconify(text_size: int, prop_name: String, kind: String = ""):
    var found = get_icon(prop_name, kind)
    if not found:
        debug_print("Did not find prop {a} ({b})".format({"a": prop_name, "b": kind}))
        return prop_name
    else:
        debug_print("Found prop {a} ({b})".format({"a": prop_name, "b": kind}))
        return "[url={prop_name}][img={text_size},center,center]{found}[/img][/url]".format({"text_size": text_size, "found": found, "prop_name": prop_name})
