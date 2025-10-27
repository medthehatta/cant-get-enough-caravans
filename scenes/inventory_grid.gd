extends Control
class_name InventoryGrid

signal resource_clicked(item: InventoryGridItem, resource: Resource)
signal resource_hovered(item: InventoryGridItem, resource: Resource)
signal resource_unhovered(item: InventoryGridItem, resource: Resource)

@onready var grid: GridContainer = %Grid
@onready var item_scn: PackedScene = preload("res://scenes/inventory_grid_item.tscn")

@export var validator: ResourceValidator
@export var num_columns: int = 1
@export var num_slots: int = 1
@export var columns_from_square: bool = false
@export var debug: bool = true


func _ready():
    debug_print("num_slots=%d" % num_slots)
    if num_columns:
        set_num_columns(num_columns)
    if num_slots:
        set_num_slots(num_slots)


func debug_print(msg):
    if debug:
        print(msg)


func _insert_new_slot():
    var slot = item_scn.instantiate() as InventoryGridItem
    grid.add_child(slot)
    slot.grid = self
    if validator and not slot.validator:
        slot.validator = validator
    slot.clicked.connect(func(res): resource_clicked.emit(slot, res))
    slot.hovered.connect(func(res): resource_hovered.emit(slot, res))
    slot.unhovered.connect(func(res): resource_unhovered.emit(slot, res))
    return slot


func set_num_slots(n: int):
    debug_print("setting slots")
    var existing_num_slots = grid.get_children().size()

    # Slots are already equal, do nothing
    if n == existing_num_slots:
        debug_print("set_num_slots to the same as the existing number, {n}=={k}, doing nothing".format({"n": n, "k": existing_num_slots}))
        return []

    # Only adding slots, add them
    elif n > existing_num_slots:
        debug_print("set_num_slots wants {n} but has {k}, adding {nk}".format({"n": n, "k": existing_num_slots, "nk": n - existing_num_slots}))
        var added: Array[InventoryGridItem] = []
        for i in range(n - existing_num_slots):
            added.append(_insert_new_slot())
        num_slots = n
        return added

    # Otherwise, we do removal, the hard case, because there could be occupied
    # slots we don't want to evict
    debug_print("set_num_slots wants {n} but has {k}, attempting to remove {nk}".format({"n": n, "k": existing_num_slots, "nk": existing_num_slots - n}))
    var to_remove = existing_num_slots - n
    var unoccupied: Array[InventoryGridItem]
    for child in grid.get_children():
        var slot = child as InventoryGridItem
        if slot.is_empty():
            unoccupied.append(slot)

    # If we have more available slots than slots we want to remove, remove the
    # appropriate number of available slots and we're done.
    var num_unoccupied = unoccupied.size()
    if num_unoccupied >= to_remove:
        debug_print("set_num_slots want to remove {nk} and we have {u} unoccupied slots.  Removing".format({"nk": existing_num_slots - n, "u": num_unoccupied}))
        for i in range(to_remove):
            unoccupied[i].queue_free()
        num_slots = n
        return []

    # Otherwise, we abort because we don't want to evict anything
    print("ERROR: Unable to set {n} slots because only {k} slots are unoccupied and we would have to remove {r}".format({"n": n, "k": num_unoccupied, "r": to_remove}))


func set_num_columns(n: int):
    if columns_from_square:
        size.x = size.y * n
    num_columns = n
    grid.columns = n


func populate_from_array(resources: Array[Resource]):
    var slots = grid.get_children()

    for i in range(slots.size()):
        debug_print(i)
        if i >= resources.size():
            break
        debug_print("Assign %s" % resources[i].name)
        slots[i].set_resource(resources[i])
