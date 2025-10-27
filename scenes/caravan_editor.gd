extends Panel
class_name CaravanEditor

@onready var leader_grid: InventoryGrid = %leader
@onready var personnel_grid: InventoryGrid = %personnel
@onready var equipment_grid: InventoryGrid = %equipment
@onready var caravan_evaluator: CaravanEvaluator = %CaravanEvaluator

@export var property_icons: PropertyIcons

# FIXME: Hack to just pass the tooltip like this
@export var tooltip: Control


func connect_cursor_inventory(cursor_inventory: CursorInventory):
    print("Connecting cursor inventory to {0}".format([name]))
    cursor_inventory.picked.connect(_on_cursor_picked)
    cursor_inventory.placed.connect(_on_cursor_placed)
    leader_grid.resource_clicked.connect(cursor_inventory.on_grid_item_clicked)
    personnel_grid.resource_clicked.connect(cursor_inventory.on_grid_item_clicked)
    equipment_grid.resource_clicked.connect(cursor_inventory.on_grid_item_clicked)


func disconnect_cursor_inventory(cursor_inventory: CursorInventory):
    print("Disconnecting cursor inventory from {0}".format([name]))
    maybe_disconnect(cursor_inventory.picked, _on_cursor_picked)
    maybe_disconnect(cursor_inventory.placed, _on_cursor_placed)
    maybe_disconnect(leader_grid.resource_clicked, cursor_inventory.on_grid_item_clicked)
    maybe_disconnect(personnel_grid.resource_clicked, cursor_inventory.on_grid_item_clicked)
    maybe_disconnect(equipment_grid.resource_clicked, cursor_inventory.on_grid_item_clicked)


func maybe_disconnect(sig, callback):
    if sig.is_connected(callback):
        sig.disconnect(callback)


func _ready():
    for grid in [leader_grid, personnel_grid, equipment_grid]:
        grid.resource_hovered.connect(_on_item_hovered)
        grid.resource_unhovered.connect(_on_item_unhovered)


func _on_cursor_placed(resource, dest):
    var dest_grid = dest.grid
    print("Placed {a} into slot {c}".format({"a": resource, "c": dest}))
    if dest_grid == leader_grid:
        caravan_evaluator.set_leader(resource)
    elif dest_grid == personnel_grid:
        caravan_evaluator.add_personnel([resource])
    elif dest_grid == equipment_grid:
        caravan_evaluator.add_equipment([resource])
    tooltip.render_for(resource)
    show_caravan_stats(evaluate_caravan())


func _on_cursor_picked(resource: Resource, src: InventoryGridItem):
    var src_grid = src.grid
    print("Picked {a} from slot {b}".format({"a": resource, "b": src}))
    if src_grid == leader_grid:
        caravan_evaluator.set_leader(null)
    elif src_grid == personnel_grid:
        caravan_evaluator.remove_personnel([resource])
    elif src_grid == equipment_grid:
        caravan_evaluator.remove_equipment([resource])


func evaluate_caravan():
    var num_personnel_slots = caravan_evaluator.get_num_personnel_slots()
    var num_equipment_slots = caravan_evaluator.get_num_equipment_slots()
    var weight = caravan_evaluator.get_weight()
    var capacity = caravan_evaluator.get_cargo_capacity()
    var daily_calories = caravan_evaluator.get_daily_calories()

    var summary: Dictionary = {
        "personnel_slots": num_personnel_slots,
        "equipment_slots": num_equipment_slots,
        "weight": weight,
        "cargo_capacity": capacity,
        "daily_calories": daily_calories,
    }

    return summary


func show_caravan_stats(stat_dict: Dictionary):
    var stat_blocks: Array[String] = []
    var icon_scale = 1.75
    var font_size = %StatSummary.get_theme_font_size("normal_font_size")
    for key in stat_dict.keys():
        # Skip "special" keys
        if key.begins_with("_"):
            continue
        stat_blocks.append(
            "{k} {v}".format(
                {
                    "k": property_icons.iconify(icon_scale * font_size, key, "Caravan"),
                    "v": stat_dict[key],
                }
            )
        )

    %StatSummary.text = "   ".join(stat_blocks)

    personnel_grid.set_num_slots(stat_dict["personnel_slots"])
    equipment_grid.set_num_slots(stat_dict["equipment_slots"])


func _on_item_hovered(_item: InventoryGridItem, resource: Resource):
    tooltip.render_for(resource)


func _on_item_unhovered(_item: InventoryGridItem, _resource: Resource):
    tooltip.clear_text()


func _on_stat_summary_meta_hover_started(meta: Variant) -> void:
    tooltip.render_for(meta)


func _on_stat_summary_meta_hover_ended(_meta: Variant) -> void:
    tooltip.clear_text()
