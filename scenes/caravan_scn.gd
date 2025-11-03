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
    %Integrity.visible = false


func _process(_delta: float):
    if not resource:
        return

    %Integrity.visible = true
    if resource.leader:
        %LeaderIcon.texture = resource.leader.icon
    var min_integrity = 100
    for equip in resource.equipment:
        if equip.integrity < min_integrity:
            min_integrity = equip.integrity
    %Integrity.value = min_integrity
