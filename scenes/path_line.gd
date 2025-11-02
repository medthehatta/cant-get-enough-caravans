extends Line2D
class_name PathLine


@onready var ahead = %PathLineAhead

@export var active_color: Color
@export var inactive_color: Color
@export var ahead_color: Color
@export var line_width: float = 1


func _ready():
    default_color = active_color
    ahead.default_color = ahead_color
    width = line_width
    ahead.width = line_width


func fade_out():
    default_color = inactive_color


func fade_in():
    default_color = active_color