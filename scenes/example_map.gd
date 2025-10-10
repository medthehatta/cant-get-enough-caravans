extends Node2D

var highlighted: Vector2i = Vector2i(0, 0)


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


func highlight_cell_tile(coords: Vector2i):
    %CellHighlight.erase_cell(highlighted)
    highlighted = coords
    %CellHighlight.set_cell(coords, 1, Vector2i(1, 0))


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
        highlight_cell_tile(Vector2i(map_prev.x, map_coords.y))
    else:
        var p = %BackgroundMap.map_to_local(Vector2i(map_coords.x, map_prev.y)) - %PathLineAhead.position - base
        %PathLineAhead.set_point_position(1, p)
        highlight_cell_tile(Vector2i(map_coords.x, map_prev.y))


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


func get_path_coords(tile_map_layer: TileMapLayer):
    var waypoints: Array[Vector2i] = []
    for i in range(0, %PathLine.get_point_count()):
        waypoints.append(tile_map_layer.local_to_map(%PathLine.get_point_position(i) + %PathLine.position - tile_map_layer.position))

    # Waypoints are constrained to differ from each other along exactly one
    # dimension at a time
    var coords: Array[Vector2i] = []

    for i in range(0, waypoints.size() - 1):
        var diff = waypoints[i + 1] - waypoints[i]
        var direction: Vector2i = Vector2i.ZERO
        if diff.x == 0 and diff.y > 0:
            direction = Vector2i(0, 1)
        elif diff.x == 0 and diff.y <= 0:
            direction = Vector2i(0, -1)
        elif diff.x > 0 and diff.y == 0:
            direction = Vector2i(1, 0)
        elif diff.x <= 0 and diff.y == 0:
            direction = Vector2i(-1, 0)
        else:
            print("What direction is {}??".format(diff))
            assert(false)
    
        for j in range(0, int(diff.length())):
            coords.append(waypoints[i] + j * direction)
    
    coords.append(waypoints[-1])

    return coords


func get_tile_path(tile_map_layer: TileMapLayer):
    var points = get_path_coords(tile_map_layer)
    var tile_data: Array[MapTile] = []

    for pt in points:
        var tile: MapTile
        var data = tile_map_layer.get_cell_tile_data(pt)

        if not (data and data.has_custom_data("map_tile")):
            tile = MapTile.new()
            tile.biome = "none"
            tile.density = 1
        else:
            tile = data.get_custom_data("map_tile")

        tile_data.append(tile)

    return tile_data


func _on_button_pressed() -> void:
    for p in get_tile_path(%BackgroundMap):
        print([p.biome, p.density])
