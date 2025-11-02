extends Control

@onready var cursor_inventory: CursorInventory = %cursor
@onready var inventory_grid: InventoryGrid = %inventory
@onready var editors: TabContainer = %Editors
@onready var route_planner: RoutePlanner = %RoutePlanner
@onready var last_timer_time = Time.get_ticks_msec()
@onready var caravans = %Caravans
@onready var map = %Map

@export var property_icons: PropertyIcons
@export var example_resources: Array[Resource]
@export var editor_scn: PackedScene
@export var simple_text_input_modal: PackedScene
@export var debug: bool = true
@export var caravan_scn: PackedScene
@export var expedition_scn: PackedScene

var editor_to_route_idx: Dictionary = {}
var editor_to_caravan: Dictionary = {}
var incrementing: int = 0
var running: bool = false
var expeditions: Array[Expedition] = []


# TODO: Hacky player controller built in to this scene
@export var player_speed: float = 10.0
var player_velocity: Vector2 = Vector2.ZERO


func debug_print(msg, anno = null):
    if debug:
        if anno:
            print("%s=%s" % [anno, msg])
        else:
            print(msg)


# Called when the node enters the scene tree for the first time.
func _ready():
    inventory_grid.populate_from_array(example_resources)
    inventory_grid.resource_hovered.connect(_on_item_hovered)
    inventory_grid.resource_unhovered.connect(_on_item_unhovered)
    inventory_grid.visible = false
    cursor_inventory.visible = true
    editors.visible = false


func _physics_process(delta: float):
    if Input.is_action_pressed("move_left"):
        player_velocity.x = -1
    elif Input.is_action_pressed("move_right"):
        player_velocity.x = 1
    else:
        player_velocity.x = 0

    if Input.is_action_pressed("move_up"):
        player_velocity.y = -1
    elif Input.is_action_pressed("move_down"):
        player_velocity.y = 1
    else:
        player_velocity.y = 0

    %Player.position += player_speed * player_velocity.normalized() * delta


func _input(event):
    if event.is_action_released("clear_cursor"):
        cursor_inventory.clear_cursor()
    elif event.is_action_released("toggle_inventory"):
        toggle_inventory()


func toggle_inventory():
    inventory_grid.position.y = editors.position.y + 20
    inventory_grid.position.x = editors.position.x + editors.size.x + 20
    inventory_grid.visible = not inventory_grid.visible


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


func current_caravan_scn():
    var editor = current_caravan_editor()
    if editor:
        return editor_to_caravan.get(editor)
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

    var new_caravan = caravan_scn.instantiate()
    var rng = RandomNumberGenerator.new()
    new_caravan.color = Color.from_hsv(
        float(rng.randi_range(0, 20)) / 21,
        1,
        float(rng.randi_range(1, 2)) / 2,
    )
    caravans.add_child(new_caravan)
    new_caravan.position = route_planner.snap_to_map(%Player.position - route_planner.position)

    var new_editor: CaravanEditor = editor_scn.instantiate()
    new_editor.property_icons = %PropertyIcons
    new_editor.tooltip = %Tooltip
    editors.add_child(new_editor)
    new_editor.icon.texture = new_caravan.icon.texture
    new_editor.icon.material = new_caravan.icon.material
    editors.set_tab_title(next_tab, caravan_name)

    editor_to_caravan[new_editor] = new_caravan

    var route_idx = route_planner.add_path(new_caravan.position)

    editor_to_route_idx[new_editor] = route_idx

    editors.current_tab = next_tab
    if editors.get_child_count() > 0:
        editors.visible = true


func single_text_prompt_modal(prompt: String, default: String = ""):
    var modal: SimpleTextInputModal = simple_text_input_modal.instantiate()
    add_child(modal)
    return await modal.prompt_and_wait(prompt, default)


func _on_remove_caravan_button_pressed() -> void:
    var current_editor = current_caravan_editor()
    var current_route_id_ = current_route_id()
    var current_caravan_scn_ = current_caravan_scn()

    if current_caravan_scn_:
        current_caravan_scn_.queue_free()
        editor_to_caravan.erase(current_editor)

    if current_route_id_ != null:
        route_planner.remove_path(current_route_id_)

    if current_editor:
        current_editor.queue_free()
        editor_to_route_idx.erase(current_editor)
        editors.select_previous_available() or editors.select_next_available()
        if editor_to_route_idx.size() == 0:
            editors.visible = false


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
        if not expeditions:
            route_planner.lock_all()
            for editor in editor_to_route_idx.keys():
                var route_id = editor_to_route_idx[editor]
                var route = route_planner.route(route_id)
                var expedition = expedition_scn.instantiate()
                expedition.route_id = route_id
                expedition.map = map
                expedition.caravan_scn = editor_to_caravan[editor]
                expedition.caravan = editor.caravan()
                expedition.route = route
                expeditions.append(expedition)
                debug_print(expeditions, "expeditions")
        running = true
        %ToggleRunButton.text = "Stop Run"
    else:
        running = false
        %ToggleRunButton.text = "Start Run"


func _on_timer_timeout() -> void:
    var current = Time.get_ticks_msec()
    var delta = float(current - last_timer_time)
    last_timer_time = current

    var to_drop: Array[Expedition] = []

    if running:
        if expeditions.size() == 0:
            print("All expeditions done")
            running = false
            %ToggleRunButton.button_pressed = false
            %ToggleRunButton.text = "Start Run"

        for expedition in expeditions:
            var continuing = expedition.traverse(delta / 1000)
            if not continuing:
                route_planner.unlock_path(expedition.route)
                to_drop.append(expedition)
                print("Expedition {0} is done".format([expedition]))
            print(expedition.caravan.summary())

        for drop in to_drop:
            debug_print("exp={0} pid={1}".format([drop, drop.route_id]))
            route_planner.reset_path(drop.route_id, drop.caravan_scn.position)
            expeditions.erase(drop)
