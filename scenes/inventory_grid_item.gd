extends TextureRect
class_name InventoryGridItem

signal clicked(Resource)
signal hovered(Resource)
signal unhovered(Resource)

@onready var icon: TextureRect = %Icon

@export var validator: ResourceValidator
@export var empty_texture: Texture2D
@export var resource: Resource
@export var grid: InventoryGrid
@export var debug: bool = false


func debug_print(msg):
    if debug:
        print(msg)


func _ready():
    texture = empty_texture

    if resource:
        set_resource(resource)
    else:
        icon.texture = null


func set_texture_from_resource_icon(res):
    if not res:
        debug_print("No resource provided to inventory grid item %s" % self)
        icon.texture = null
        return

    if not "icon" in res:
        debug_print("Could not get icon from resource: %s" % res)
        icon.texture = null
        return

    debug_print("Assigning resource icon to slot %s" % self)
    icon.texture = res.icon


func set_resource(res):
    if validator:
        if res != null and not validator.validate(res):
            print("ERROR resource {r} is not valid in grid slot {s}".format({"r": res, "s": self}))
            return false
    resource = res
    set_texture_from_resource_icon(resource)
    return true


func unset_resource():
    resource = null
    icon.texture = null
    return true


func is_empty():
    return resource == null


func _on_button_button_up():
    debug_print("Clicked button %s" % self)
    clicked.emit(resource)


func _on_mouse_exited() -> void:
    unhovered.emit(resource)


func _on_mouse_entered() -> void:
    hovered.emit(resource)
