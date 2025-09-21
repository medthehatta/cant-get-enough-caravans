extends Node2D


func _ready():
    %PathLine.position = %BackgroundMap.map_to_local(%BackgroundMap.local_to_map(%PathLine.position))


func _input(event):
    if event is InputEventMouseButton:
        var pos = event.position
        if event.pressed and event.button_index == 1:
            add_point(pos)
        elif event.pressed and event.button_index == 2:
            remove_point()
    elif event is InputEventMouseMotion:
        var pos = event.position
        propose_point(pos)


func snap_to_map(pt: Vector2):
    return %BackgroundMap.map_to_local(%BackgroundMap.local_to_map(pt))


func propose_point(pt: Vector2):
    var base = %PathLine.position
    var count = %PathLine.get_point_count()
    var prev = base + %PathLine.get_point_position(count - 1)
    var map_prev = %BackgroundMap.local_to_map(prev)
    var map_coords = %BackgroundMap.local_to_map(pt)

    var map_diff = map_coords - map_prev

    if abs(map_diff.x) > 2 and abs(map_diff.y) > 2:
        return

    if abs(map_diff.x) < abs(map_diff.y):
        var p = %BackgroundMap.map_to_local(Vector2i(map_prev.x, map_coords.y)) - %PathLineAhead.position - base
        %PathLineAhead.set_point_position(1, p)
    else:
        var p = %BackgroundMap.map_to_local(Vector2i(map_coords.x, map_prev.y)) - %PathLineAhead.position - base
        %PathLineAhead.set_point_position(1, p)


func add_point(pt: Vector2):
    var base = %PathLine.position
    var count = %PathLine.get_point_count()
    var prev = base + %PathLine.get_point_position(count - 1)
    var map_prev = %BackgroundMap.local_to_map(prev)
    var map_coords = %BackgroundMap.local_to_map(pt)

    var map_diff = map_coords - map_prev

    if abs(map_diff.x) > 2 and abs(map_diff.y) > 2:
        print("Move in straight lines")
        return

    if abs(map_diff.x) < abs(map_diff.y):
        var p = %BackgroundMap.map_to_local(Vector2i(map_prev.x, map_coords.y)) - base
        %PathLine.add_point(p)
        %PathLineAhead.position = p
    else:
        var p = %BackgroundMap.map_to_local(Vector2i(map_coords.x, map_prev.y)) - base
        %PathLine.add_point(p)
        %PathLineAhead.position = p


func remove_point():
    var count = %PathLine.get_point_count()
    if count > 1:
        %PathLineAhead.position = %PathLine.get_point_position(count - 2)
        %PathLine.remove_point(count - 1)
    else:
        print("No more points to remove from path")
