extends MarginContainer
class_name CursorInventory


signal placed(resource: Resource, dest: InventoryGridItem)
signal picked(resource: Resource, src: InventoryGridItem)


@onready var slot: InventoryGridItem = %Item

@export var src_slot: InventoryGridItem
@export var debug: bool = false


func debug_print(msg):
    if debug:
        print(msg)


func _process(_delta):
    var pos = get_global_mouse_position()
    global_position = pos


func set_resource_from_slot(src: InventoryGridItem, res: Resource):
    src_slot = src
    slot.set_resource(res)


func unset_resource():
    src_slot = null
    slot.unset_resource()


func get_resource():
    return slot.resource


func on_grid_item_clicked(item: InventoryGridItem, resource: Resource):
    var from_cursor = get_resource()
    var from_item = item.resource

    debug_print(
        "Found click on {a} with resource {b}.  Cursor had resource {c}".format(
            {"a": item, "b": resource, "c": from_cursor}
        )
    )

    if from_item and from_cursor:
        slot.set_resource(from_item)
        if item.set_resource(from_cursor):
            picked.emit(from_item, item)
            placed.emit(from_cursor, item)
            src_slot = item

    elif from_item:
        src_slot = item
        slot.set_resource(from_item)
        item.unset_resource()
        picked.emit(from_item, item)

    elif from_cursor:
        if item.set_resource(from_cursor):
            src_slot = null
            slot.unset_resource()
            placed.emit(from_cursor, item)


func clear_cursor():
    var from_cursor = get_resource()
    if from_cursor:
        src_slot.set_resource(from_cursor)
        unset_resource()
