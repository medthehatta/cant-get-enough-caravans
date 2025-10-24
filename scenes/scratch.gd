extends Control

@onready var cursor_inventory: CursorInventory = %cursor
@onready var inventory_grid: InventoryGrid = %inventory
@onready var leader_grid: InventoryGrid = %leader
@onready var personnel_grid: InventoryGrid = %personnel
@onready var equipment_grid: InventoryGrid = %equipment
@onready var caravan_evaluator: CaravanEvaluator = %CaravanEvaluator

@export var property_icons: PropertyIcons
@export var example_resources: Array[Resource]

var expeditions: Array[Expedition] = []


# Called when the node enters the scene tree for the first time.
func _ready():
    inventory_grid.populate_from_array(example_resources)

    for grid in [inventory_grid, leader_grid, personnel_grid, equipment_grid]:
        grid.resource_hovered.connect(_on_item_hovered)
        grid.resource_unhovered.connect(_on_item_unhovered)

    cursor_inventory.visible = true

    print([3].reduce(func(acc, x): return acc + x))


func _on_cursor_placed(resource, dest):
    var dest_grid = dest.grid
    print("Placed {a} into slot {c}".format({"a": resource, "c": dest}))
    if dest_grid == leader_grid:
        caravan_evaluator.set_leader(resource)
    elif dest_grid == personnel_grid:
        caravan_evaluator.add_personnel([resource])
    elif dest_grid == equipment_grid:
        caravan_evaluator.add_equipment([resource])
    %Tooltip.render_for(resource)
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


func _on_gui_input(event):
    if event.is_action_released("clear_cursor"):
        cursor_inventory.clear_cursor()


func _on_item_hovered(_item: InventoryGridItem, resource: Resource):
    %Tooltip.render_for(resource)


func _on_item_unhovered(_item: InventoryGridItem, _resource: Resource):
    %Tooltip.clear_text()


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


func _on_stat_summary_meta_hover_started(meta: Variant) -> void:
    %Tooltip.render_for(meta)


func _on_stat_summary_meta_hover_ended(_meta: Variant) -> void:
    %Tooltip.clear_text()


func _on_button_2_pressed() -> void:
    var caravan = caravan_evaluator.emit_caravan()
    var route = %ExampleMap.route()
    var expedition = Expedition.new()
    expedition.caravan = caravan
    expedition.route = route

    expeditions.append(expedition)


func _physics_process(delta: float):
    for expedition in expeditions:
        expedition.traverse(delta)
        print("+++")
        print(expedition.remaining_tile_progress)
        print(expedition.caravan.dynamic_stats())
        print("---")
