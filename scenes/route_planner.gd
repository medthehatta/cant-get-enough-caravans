extends Node2D
class_name RoutePlanner


@export var background_map: TileMapLayer
@export var pathline_scene: PackedScene

@export var debug: bool = true


var pathlines: Dictionary[int, PathLine]
var pathline: PathLine
var editing: bool = false
var locked: Array[PathLine] = []

var generated_ids: Array = []


func debug_print(msg, anno = null):
    if debug:
        if anno:
            print("%s=%s" % [anno, msg])
        else:
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


func fade_out(pl: PathLine):
    pl.fade_out()


func fade_in(pl: PathLine):
    pl.fade_in()


func add_path(starting_pos: Vector2, path_id = null):
    if pathline:
        fade_out(pathline)
    path_id = path_id if path_id != null else get_unique_id()
    var new_path: PathLine = pathline_scene.instantiate()
    add_child(new_path)
    pathlines[path_id] = new_path
    new_path.position = snap_to_map(starting_pos)
    return path_id


func edit_path(path_id):
    if path_id == null:
        if pathline:
            fade_out(pathline)
        pathline = null

    elif pathlines.has(path_id):
        if pathline:
            fade_out(pathline)
        pathline = pathlines[path_id]
        fade_in(pathline)

    else:
        print("No pathline named {0}".format([path_id]))


func remove_path(path_id):
    if pathlines.has(path_id):
        if locked.has(pathlines[path_id]):
            unlock(path_id)
        pathlines[path_id].queue_free()
        pathlines.erase(path_id)
    else:
        print("Cannot delete pathline {0}, does not exist".format([path_id]))


func reset_path(path_id, pos: Vector2):
    remove_path(path_id)
    add_path(pos, path_id)


func _input(event):
    if not pathline:
        return

    if not editing:
        propose_point(last_point(pathline))
        return

    if is_locked_path(pathline):
        propose_point(last_point(pathline))
        return

    if event is InputEventMouseButton:
        var pos = to_local(event.global_position)
        if event.pressed and event.button_index == 1:
            add_point(pos)
            propose_point(last_point(pathline))
        elif event.pressed and event.button_index == 2:
            remove_point()

    elif event is InputEventMouseMotion:
        var pos = to_local(event.global_position)
        propose_point(pos)


func snap_to_map(pt: Vector2):
    return map_tile_to_control(control_to_map_tile(pt))


func control_local_to_map(pt: Vector2) -> Vector2:
    return pt - (background_map.position - position)


func map_local_to_control(pt: Vector2) -> Vector2:
    return pt + (background_map.position - position)


func map_tile_to_control(pti: Vector2i) -> Vector2:
    return background_map.map_to_local(pti) + (background_map.position - position)


func control_to_map_tile(pt: Vector2) -> Vector2i:
    return background_map.local_to_map(control_local_to_map(pt))


func last_point(pl: Line2D):
    var count = pl.get_point_count()
    return pl.position + pl.get_point_position(count - 1)


func propose_point(pt: Vector2):
    var prev = last_point(pathline)
    var map_prev = control_to_map_tile(prev)
    var map_coords = control_to_map_tile(pt)

    var map_diff = map_coords - map_prev

    if abs(map_diff.x) > 2 and abs(map_diff.y) > 2:
        return

    if abs(map_diff.x) < abs(map_diff.y):
        var p_local = map_tile_to_control(Vector2i(map_prev.x, map_coords.y))
        var p = p_local - pathline.ahead.position - pathline.position
        pathline.ahead.set_point_position(1, p)
    else:
        var p_local = map_tile_to_control(Vector2i(map_coords.x, map_prev.y))
        var p = p_local - pathline.ahead.position - pathline.position
        pathline.ahead.set_point_position(1, p)


func add_point(pt: Vector2):
    var prev = last_point(pathline)
    var map_prev = control_to_map_tile(prev)
    var map_coords = control_to_map_tile(pt)

    var map_diff = map_coords - map_prev

    if map_diff == Vector2i.ZERO:
        print("Duplicate point debounced")
        return

    if abs(map_diff.x) > 2 and abs(map_diff.y) > 2:
        print("Move in straight lines")
        return

    if abs(map_diff.x) < abs(map_diff.y):
        var p_local = map_tile_to_control(Vector2i(map_prev.x, map_coords.y))
        var p = p_local - pathline.position
        pathline.add_point(p)
        pathline.ahead.position = p
    else:
        var p_local = map_tile_to_control(Vector2i(map_coords.x, map_prev.y))
        var p = p_local - pathline.position
        pathline.add_point(p)
        pathline.ahead.position = p


func remove_point():
    var count = pathline.get_point_count()
    if count > 1:
        pathline.ahead.position = pathline.get_point_position(count - 2)
        pathline.remove_point(count - 1)
    else:
        print("No more points to remove from path")


func sliding_window(size, arr):
    var result = []
    for i in range(arr.size()):
        var batch = []
        for j in range(size):
            if i + j >= arr.size():
                return result
            batch.append(arr[i + j])
        result.append(batch)
    return result


func get_path_coords(pl: PathLine) -> Array[Vector2i]:
    var waypoints: Array[Vector2i] = []
    for i in range(0, pl.get_point_count()):
        waypoints.append(control_to_map_tile(pl.get_point_position(i) + pl.position))

    var adjacent = sliding_window(2, waypoints)

    # Waypoints are constrained to differ from each other along exactly one
    # dimension at a time
    var coords: Array[Vector2i] = []

    for adj in adjacent:
        var first = adj[0]
        var second = adj[1]
        var diff = second - first
        var direction: Vector2i = Vector2i.ZERO
        var num_tiles: int = 0
        if diff.x == 0 and diff.y > 0:
            direction = Vector2i(0, 1)
            num_tiles = diff.y
        elif diff.x == 0 and diff.y <= 0:
            direction = Vector2i(0, -1)
            num_tiles = - diff.y
        elif diff.x > 0 and diff.y == 0:
            direction = Vector2i(1, 0)
            num_tiles = diff.x
        elif diff.x <= 0 and diff.y == 0:
            direction = Vector2i(-1, 0)
            num_tiles = - diff.x
        else:
            print("What direction is {}??".format(diff))
            assert(false)

        for j in range(0, num_tiles):
            coords.append(first + j * direction)

    coords.append(waypoints[-1])

    debug_print(coords, "get_path_coords")
    return coords


func get_tile_path(pl: PathLine):
    var points = get_path_coords(pl)
    var tile_data: Array[MapTile] = []

    for pt in points:
        var tile := MapTile.new()
        var data = background_map.get_cell_tile_data(pt)

        if not (data and data.has_custom_data("map_tile")):
            tile.biome = "none"
            tile.density = 1
        else:
            var cust = data.get_custom_data("map_tile")
            tile.biome = cust.biome
            tile.density = cust.density

        tile.map_position = pt
        tile_data.append(tile)

    debug_print(tile_data, "get_tile_path")
    return tile_data


func route(path_id):
    if pathlines.has(path_id):
        var result = get_tile_path(pathlines[path_id])
        debug_print(result, "planner route says path")
        return result
    else:
        return null
