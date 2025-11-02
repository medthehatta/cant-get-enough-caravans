extends TileMapLayer
class_name Map


@export var map_size = Vector2i(128, 64) # in tiles
@export var source_id = 0 # your TileSet AtlasSource id
@export var tiles: Array[Vector2i] = []

# Noise settings
@export var noise_seed = 1337
@export var frequency = 0.05 # larger = more variation per tile
@export var octaves = 3
@export var lacunarity = 2.0
@export var gain = 0.5


func _ready() -> void:
    randomize()
    _generate()


func _generate() -> void:
    clear()

    var noise = FastNoiseLite.new()
    noise.seed = noise_seed
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.frequency = frequency
    noise.fractal_type = FastNoiseLite.FRACTAL_FBM
    noise.fractal_octaves = octaves
    noise.fractal_lacunarity = lacunarity
    noise.fractal_gain = gain

    for y in map_size.y:
        for x in map_size.x:
            var v := (noise.get_noise_2d(float(x), float(y)) + 1.0) * 0.5
            var idx := int(v * tiles.size())
            set_cell(Vector2i(x, y), source_id, tiles[idx])


func snap_to_map(pt: Vector2):
    return map_tile_to_control(control_to_map_tile(pt))


func control_local_to_map(pt: Vector2) -> Vector2:
    return pt - position


func map_local_to_control(pt: Vector2) -> Vector2:
    return pt + position


func map_tile_to_control(pti: Vector2i) -> Vector2:
    return map_to_local(pti) + position


func control_to_map_tile(pt: Vector2) -> Vector2i:
    return local_to_map(control_local_to_map(pt))
