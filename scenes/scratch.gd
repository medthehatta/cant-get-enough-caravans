extends Control

@onready var cursor_inventory: CursorInventory = %cursor
@onready var inventory_grid: InventoryGrid = %inventory
@onready var editors: TabContainer = %Editors
@onready var route_planner: RoutePlanner = %RoutePlanner

@export var property_icons: PropertyIcons
@export var example_resources: Array[Resource]
@export var editor_scn: PackedScene
@export var simple_text_input_modal: PackedScene


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


func _on_editors_tab_selected(tab: int) -> void:
    if not editors:
        return

    if editors.current_tab >= 0:
        editors.get_child(editors.current_tab).disconnect_cursor_inventory(cursor_inventory)

    var active_editor = editors.get_child(tab)
    active_editor.connect_cursor_inventory(cursor_inventory)
    route_planner.edit_path(tab)


func _on_check_route_button_pressed() -> void:
    for tile in route_planner.route(editors.current_tab):
        print("{0} {1}".format([tile.biome, tile.density]))


func _on_new_caravan_button_pressed() -> void:
    print("pressed")
    var caravan_name = await single_text_prompt_modal("Caravan name")
    if not caravan_name:
        return

    var new_editor: CaravanEditor = editor_scn.instantiate()
    var next_tab = editors.get_child_count()
    new_editor.property_icons = %PropertyIcons
    new_editor.tooltip = %Tooltip
    editors.add_child(new_editor)
    route_planner.add_path(Vector2(60, 60))
    editors.current_tab = next_tab
    editors.set_tab_title(next_tab, caravan_name)
    if editors.get_child_count() > 0:
        %BigNewCaravanButton.visible = false


func single_text_prompt_modal(prompt: String):
    print("starting modal")
    var modal: SimpleTextInputModal = simple_text_input_modal.instantiate()
    %SmallModalSpawnPos.add_child(modal)
    return await modal.prompt_and_wait(prompt)


func _on_remove_caravan_button_pressed() -> void:
    var current_num = editors.current_tab
    route_planner.remove_path(current_num)
    editors.get_child(editors.current_tab).queue_free()
    if current_num == 0:
        %BigNewCaravanButton.visible = true
    else:
        editors.current_tab = current_num - 1


func _on_edit_route_button_pressed() -> void:
    if route_planner.editing:
        route_planner.editing = false
        %EditRouteButton.text = "Edit Route"
    else:
        route_planner.editing = true
        %EditRouteButton.text = "Stop Editing Route"
