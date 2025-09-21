extends RichTextLabel
class_name EntityTooltip


@export var property_icons: PropertyIcons
@export var debug: bool = false


func debug_print(msg):
    if debug:
        print(msg)


func _ready():
    clear_text()


func _process(_delta):
    var pad = 10
    var desired_pos = get_global_mouse_position() + Vector2(pad, pad)
    var screen_rect = get_viewport_rect()
    var usable_screen_rect = screen_rect.size - size - Vector2(pad, pad)
    global_position = Vector2(
        clamp(desired_pos.x, 0, usable_screen_rect.x),
        clamp(desired_pos.y, 0, usable_screen_rect.y),
    )


func get_for_person(p: Person):
    return {
        "_kind": "Personnel",
        "_name": p.name if p.name else "Anonymous",
        "_flavor": p.flavor if p.flavor else "",
        "max_personnel_as_leader": p.max_personnel_as_leader,
        "max_equipment_slots": p.max_equipment_slots,
        "daily_calories": p.daily_calories,
    }


func get_for_equipment(e: Equipment):
    return {
        "_kind": "Equipment",
        "_name": e.name if e.name else "Anonymous",
        "_flavor": e.flavor if e.flavor else "",
        "weight": e.weight,
        "cargo_capacity": e.cargo_capacity,
    }


func get_text_size():
    return get_theme_font_size("normal_font_size")


func prettify_width():
    var thresh = 1.4
    if size.y / size.x > thresh:
        debug_print("too narrow")
        custom_minimum_size.x = size.y / thresh
        autowrap_mode = TextServer.AUTOWRAP_OFF
    elif size.x / size.y > thresh and "\n" in text:
        debug_print("too wide")
        autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        #custom_minimum_size.x = size.y / thresh
        size.x = size.y * thresh


func iconify(prop_name: String, kind: String = ""):
    if not property_icons:
        debug_print("No property icons attached")
        return prop_name

    return property_icons.iconify(get_text_size(), prop_name, kind)


func render_for_data(data: Dictionary):
    var kind = data["_kind"]
    var name_ = data["_name"]
    var flavor_ = data["_flavor"]
    var fpad = "\n" if flavor_ else ""

    var tip = "[b]{n}[/b]\n{k}\n{fpad}[i]{f}[/i]{fpad}\n".format({"n": name_, "k": kind, "f": flavor_, "fpad": fpad})

    for k in data.keys():
        # Skip special keys that start with underscores; we handle those in
        # specific ways
        if k.begins_with("_"):
            continue
        tip += "{k}: {v}\n".format({"k": iconify(k, kind), "v": data[k]})

    text = tip
    visible = true


func render_for_string(s: String):
    text = s
    visible = true


func render_for(inp: Variant):
    if inp is Person:
        var data = get_for_person(inp)
        render_for_data(data)
    elif inp is Equipment:
        var data = get_for_equipment(inp)
        render_for_data(data)
    elif inp is String:
        render_for_string(inp)
    else:
        clear_text()
    reset_size()
    prettify_width()


func clear_text():
    visible = false
    text = ""
    custom_minimum_size.x = 0
    autowrap_mode = TextServer.AUTOWRAP_OFF
