extends Control

@onready var cursor_inventory: CursorInventory = %cursor
@onready var inventory_grid: InventoryGrid = %inventory
@onready var editors: TabContainer = %Editors
@onready var route_planner: RoutePlanner = %RoutePlanner
@onready var last_timer_time = Time.get_ticks_msec()

@export var property_icons: PropertyIcons
@export var example_resources: Array[Resource]
@export var editor_scn: PackedScene
@export var simple_text_input_modal: PackedScene
@export var debug: bool = false

var editor_to_route_idx: Dictionary = {}
var incrementing: int = 0
var running: bool = false
var expeditions: Array[Expedition] = []


func debug_print(msg):
    if debug:
        print(msg)


# Called when the node enters the scene tree for the first time.
func _ready():
    inventory_grid.populate_from_array(example_resources)
    inventory_grid.resource_hovered.connect(_on_item_hovered)
    inventory_grid.resource_unhovered.connect(_on_item_unhovered)
    cursor_inventory.visible = true


func _on_gui_input(event):
    if event.is_action_released("clear_cursor"):
        cursor_inventory.clear_cursor()


func _on_item_hovered(_item: InventoryGridItem, resource: Resource):
    %Tooltip.render_for(resource)


func _on_item_unhovered(_item: InventoryGridItem, _resource: Resource):
    %Tooltip.clear_text()


func _on_stat_summary_meta_hover_started(meta: Variant) -> void:
    %Tooltip.render_for(meta)


func _on_stat_summary_meta_hover_ended(_meta: Variant) -> void:
    %Tooltip.clear_text()


func current_caravan_id():
    if editors.get_child_count() >= 0:
        return editors.current_tab
    else:
        return null


func current_caravan_editor():
    var id_ = current_caravan_id()
    if id_ != null:
        return editors.get_child(id_)
    else:
        return null


func current_route_id():
    var editor = current_caravan_editor()
    if editor:
        return editor_to_route_idx.get(editor)
    else:
        return null


func current_route():
    var id_ = current_route_id()
    if id_ != null:
        return route_planner.route(id_)
    else:
        return null


func _on_editors_tab_selected(tab: int) -> void:
    if not editors:
        return

    var current_editor_id = current_caravan_id()

    var current_editor = current_caravan_editor()
    if current_editor:
        current_editor.disconnect_cursor_inventory(cursor_inventory)

    var new_active_editor = editors.get_child(tab)
    new_active_editor.connect_cursor_inventory(cursor_inventory)

    var route_idx = editor_to_route_idx.get(new_active_editor)
    if route_idx:
        route_planner.edit_path(route_idx)

    debug_print("current_id={0} new_id={1} route_id={2}".format([current_editor_id, tab, route_idx]))


func _on_check_route_button_pressed() -> void:
    var route = current_route()
    if route == null:
        route = []

    for tile in current_route():
        print("{0} {1}".format([tile.biome, tile.density]))


func _on_new_caravan_button_pressed() -> void:
    var next_tab = editors.get_child_count()

    var default_name = "Caravan {0}".format([incrementing])
    var caravan_name = await single_text_prompt_modal("Caravan name", default_name)
    if not caravan_name:
        return

    incrementing += 1

    var new_editor: CaravanEditor = editor_scn.instantiate()
    new_editor.property_icons = %PropertyIcons
    new_editor.tooltip = %Tooltip
    editors.add_child(new_editor)
    editors.set_tab_title(next_tab, caravan_name)

    var route_idx = route_planner.add_path(Vector2(60, 60))

    editor_to_route_idx[new_editor] = route_idx

    editors.current_tab = next_tab
    if editors.get_child_count() > 0:
        %BigNewCaravanButton.visible = false


func single_text_prompt_modal(prompt: String, default: String = ""):
    print("starting modal")
    var modal: SimpleTextInputModal = simple_text_input_modal.instantiate()
    %SmallModalSpawnPos.add_child(modal)
    return await modal.prompt_and_wait(prompt, default)


func _on_remove_caravan_button_pressed() -> void:
    # FIXME: When we remove editors, we reuse tab ids, but the routes are not
    # cleared, so we get weird shared routes
    var current_editor = current_caravan_editor()
    var current_route_id_ = current_route_id()

    if current_editor:
        current_editor.queue_free()
        editors.select_previous_available()
        if editors.get_child_count() <= 0:
            %BigNewCaravanButton.visible = true
        editor_to_route_idx.erase(current_editor)

    if current_route_id_ != null:
        route_planner.remove_path(current_route_id_)


func _on_edit_route_button_pressed() -> void:
    if current_caravan_id() == null:
        print("Nothing to edit")
        return

    if route_planner.editing:
        route_planner.editing = false
        %EditRouteButton.text = "Edit Route"
    else:
        route_planner.editing = true
        %EditRouteButton.text = "Stop Editing Route"


func _on_toggle_run_toggled(toggled_on: bool) -> void:
    if toggled_on:
        route_planner.lock_all()
        for editor in editor_to_route_idx.keys():
            var route_id = editor_to_route_idx[editor]
            var route = route_planner.route(route_id)
            var expedition = Expedition.new()
            expedition.caravan = editor.caravan()
            expedition.route = route
            expeditions.append(expedition)
        running = true
        %ToggleRunButton.text = "Stop Run"
    else:
        running = false
        %ToggleRunButton.text = "Start Run"


func _on_timer_timeout() -> void:
    var current = Time.get_ticks_msec()
    var delta = float(current - last_timer_time)
    last_timer_time = current

    var to_drop = []

    if running:
        if expeditions.size() == 0:
            print("All expeditions done")
            running = false
            %ToggleRunButton.text = "Start Run"

        for expedition in expeditions:
            print("\n\n")
            print(expedition)
            var continuing = expedition.traverse(delta / 1000)
            if not continuing:
                route_planner.unlock_path(expedition.route)
                to_drop.append(expedition)
                print("Expedition {0} is done".format([expedition]))
            print(expedition.caravan.summary())

        for drop in to_drop:
            expeditions.erase(drop)
