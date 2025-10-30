extends Node2D
class_name RoutePlanner


@onready var background_map = %BackgroundMap
@onready var cell_highlight = %CellHighlight

@export var pathline_scene: PackedScene

@export var debug: bool = true


var highlighted: Vector2i = Vector2i(0, 0)

var pathlines: Dictionary[int, PathLine]
var pathline: PathLine
var editing: bool = false
var locked: Array[PathLine] = []

var generated_ids: Array = []


func debug_print(msg):
    if debug:
        print(msg)


func get_unique_id():
    var rng = RandomNumberGenerator.new()
    var path_id = rng.randi()
    while generated_ids.has(path_id):
        path_id = rng.randi()
    generated_ids.append(path_id)
    return path_id


func is_locked_path(path):
    return locked.has(path)


func is_locked(path_id):
    var path = pathlines.get(path_id)
    return is_locked_path(path)


func lock(path_id):
    var path = pathlines.get(path_id)
    if not locked.has(path):
        locked.append(path)


func unlock(path_id):
    var path = pathlines.get(path_id)
    if locked.has(path):
        locked.erase(path)


func unlock_path(path):
    if locked.has(path):
        locked.erase(path)


func lock_all():
    for path_id in pathlines.keys():
        lock(path_id)


func unlock_all():
    for path_id in pathlines.keys():
        unlock(path_id)


func add_path(starting_pos: Vector2):
    if pathline:
        pathline.visible = false
    var path_id = get_unique_id()
    var new_path: PathLine = pathline_scene.instantiate()
    debug_print(new_path)
    add_child(new_path)
    debug_print(new_path)
    pathlines[path_id] = new_path
    new_path.position = snap_to_map(starting_pos)
    return path_id


func edit_path(path_id):
    if path_id == null:
        if pathline:
            pathline.visible = false
        pathline = null

    elif pathlines.has(path_id):
        if pathline:
            pathline.visible = false
        pathline = pathlines[path_id]
        pathline.visible = true

    else:
        print("No pathline named {0}".format([path_id]))


func remove_path(path_id):
    if pathlines.has(path_id):
        if locked.has(pathlines[path_id]):
            unlock(path_id)
        pathlines[path_id].queue_free()
        pathlines.erase(path_id)
        cell_highlight.erase_cell(highlighted)
    else:
        print("Cannot delete pathline {0}, does not exist".format([path_id]))


func _input(event):
    if not pathline:
        return

    if not editing:
        propose_point(last_point(pathline))
        cell_highlight.erase_cell(highlighted)
        return

    if is_locked_path(pathline):
        propose_point(last_point(pathline))
        cell_highlight.erase_cell(highlighted)
        return

    if event is InputEventMouseButton:
        var pos = event.position - position
        var tile_rect = background_map.get_used_rect()
        var pixel_rect = Rect2(
            background_map.map_to_local(tile_rect.position),
            tile_rect.size * background_map.tile_set.tile_size,
        )
        var global_rect = Rect2(
            background_map.to_global(pixel_rect.position),
            pixel_rect.size
        )
        if not global_rect.has_point(to_global(pos)):
            return
        if event.pressed and event.button_index == 1:
            add_point(pos)
        elif event.pressed and event.button_index == 2:
            remove_point()

    elif event is InputEventMouseMotion:
        var pos = event.position - position
        var tile_rect = background_map.get_used_rect()
        var pixel_rect = Rect2(
            background_map.map_to_local(tile_rect.position),
            tile_rect.size * background_map.tile_set.tile_size,
        )
        var global_map_rect = Rect2(
            background_map.to_global(pixel_rect.position),
            pixel_rect.size
        )
        if not global_map_rect.has_point(to_global(pos)):
            propose_point(last_point(pathline))
        else:
            propose_point(pos)


func snap_to_map(pt: Vector2):
    return background_map.map_to_local(background_map.local_to_map(pt))


func last_point(pl: Line2D):
    var count = pl.get_point_count()
    return pl.position + pl.get_point_position(count - 1)


func highlight_cell_tile(coords: Vector2i):
    const highlight_atlas_coord = Vector2i(12, 1)
    cell_highlight.erase_cell(highlighted)
    highlighted = coords
    cell_highlight.set_cell(coords, 1, highlight_atlas_coord)


func propose_point(pt: Vector2):
    var base = pathline.position
    var count = pathline.get_point_count()
    var prev = base + pathline.get_point_position(count - 1)
    var map_prev = background_map.local_to_map(prev)
    var map_coords = background_map.local_to_map(pt)

    var map_diff = map_coords - map_prev

    if abs(map_diff.x) > 2 and abs(map_diff.y) > 2:
        return

    if abs(map_diff.x) < abs(map_diff.y):
        var p = background_map.map_to_local(Vector2i(map_prev.x, map_coords.y)) - pathline.ahead.position - base
        pathline.ahead.set_point_position(1, p)
        highlight_cell_tile(Vector2i(map_prev.x, map_coords.y))
    else:
        var p = background_map.map_to_local(Vector2i(map_coords.x, map_prev.y)) - pathline.ahead.position - base
        pathline.ahead.set_point_position(1, p)
        highlight_cell_tile(Vector2i(map_coords.x, map_prev.y))


func add_point(pt: Vector2):
    var base = pathline.position
    var count = pathline.get_point_count()
    var prev = base + pathline.get_point_position(count - 1)
    var map_prev = background_map.local_to_map(prev)
    var map_coords = background_map.local_to_map(pt)

    var map_diff = map_coords - map_prev

    if abs(map_diff.x) > 2 and abs(map_diff.y) > 2:
        print("Move in straight lines")
        return

    if abs(map_diff.x) < abs(map_diff.y):
        var p = background_map.map_to_local(Vector2i(map_prev.x, map_coords.y)) - base
        pathline.add_point(p)
        pathline.ahead.position = p
    else:
        var p = background_map.map_to_local(Vector2i(map_coords.x, map_prev.y)) - base
        pathline.add_point(p)
        pathline.ahead.position = p


func remove_point():
    var count = pathline.get_point_count()
    if count > 1:
        pathline.ahead.position = pathline.get_point_position(count - 2)
        pathline.remove_point(count - 1)
    else:
        print("No more points to remove from path")


func get_path_coords(tile_map_layer: TileMapLayer, pl: PathLine):
    var waypoints: Array[Vector2i] = []
    for i in range(0, pl.get_point_count()):
        waypoints.append(tile_map_layer.local_to_map(pl.get_point_position(i) + pl.position - tile_map_layer.position))

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


func get_tile_path(tile_map_layer: TileMapLayer, pl: PathLine):
    var points = get_path_coords(tile_map_layer, pl)
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


func route(path_id):
    if pathlines.has(path_id):
        return get_tile_path(background_map, pathlines[path_id])
    else:
        return null
