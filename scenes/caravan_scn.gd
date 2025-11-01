extends Node2D
class_name CaravanScn


@onready var icon := %CaravanIcon


@export var resource: Caravan
@export var color_replace_shader: Shader
@export var color: Color = Color.from_hsv(1, 1, 1)


func _ready():
    var mat := ShaderMaterial.new()
    mat.shader = color_replace_shader
    print(mat.shader)
    icon.material = mat
    mat.set_shader_parameter("new_color", color)
