extends Node
class_name Expedition


@export var caravan_scn: CaravanScn
@export var caravan: Caravan
@export var route: Array[MapTile]
@export var route_id: int

@export var map: Map

@export var debug: bool = true


var remaining_tile_progress = null

var tile_index = 0

var events = EventFactory.new()


func debug_print(msg, anno = null):
    if debug:
        if anno:
            print("%s=%s" % [anno, msg])
        else:
            print(msg)


func _base_damage_for(tile):
    if tile.biome == "volcanic":
        return events.caravan_damage.create({"thermal": 40})
    else:
        return events.caravan_damage.create({"kinetic": 20})


func _base_stress_for(_tile):
    return events.caravan_stress.create(10)


func _base_xp_for(tile):
    # TODO
    return events.caravan_xp_gain.create()


func _base_consumption_for(_tile):
    var base_consumption = {
        "calories": 0,
        "power": 0,
    }
    return events.caravan_resource_consumption.create()


func _base_loot_for(_tile):
    return events.loot.create()


func _progress_required_for(tile):
    return tile.density


func _base_progress_for(_tile):
    return events.caravan_tile_progress.create()


func caravan_map_pos() -> Vector2i:
    return route[tile_index].map_position


# Return bool for now: whether to continue or whether the expedition is over
func traverse(delta: float) -> bool:
    var tile: MapTile

    if route.size() < 1:
        print("No route")
        return false

    if remaining_tile_progress != null and remaining_tile_progress <= 0:
        remaining_tile_progress = null

        # FIXME: should this be route.size() - 1?
        if tile_index < route.size() - 1:
            tile_index += 1
        else:
            tile_index = (route.size() - 1)
            print("Reached end of route at tile index {0}".format([tile_index]))
            return false

    tile = route[tile_index]
    caravan_scn.position = map.map_tile_to_control(tile.map_position)
    print(
        "idx={} map_pos={} pos={}".format(
            [tile_index, tile.map_position, caravan_scn.position],
            "{}",
        )
    )

    if remaining_tile_progress == null:
        remaining_tile_progress = _progress_required_for(tile)
        print("remaining_tile_progress={0}".format([remaining_tile_progress]))

    # Make progress on the tile
    var initial_progression = _base_progress_for(tile)
    var modified_progression = caravan.modify(initial_progression)
    remaining_tile_progress -= modified_progression.speed * delta

    # Inflict integrity damage
    var base_damage = _base_damage_for(tile)
    var modified_damage = caravan.modify(base_damage)
    caravan.inflict_damage_to_caravan(modified_damage)

    # Inflict stress
    var base_stress = _base_stress_for(tile)
    var modified_stress = caravan.modify(base_stress)
    caravan.inflict_stress_to_caravan(modified_stress)

    # Contribute XP
    var base_xp = _base_xp_for(tile)
    var modified_xp = caravan.modify(base_xp)
    caravan.contribute_xp_to_caravan(modified_xp)

    # Consume resources
    var base_consumption = _base_consumption_for(tile)
    var modified_consumption = caravan.modify(base_consumption)
    caravan.consume_caravan_resources(modified_consumption)

    # Drop loot
    var base_loot = _base_loot_for(tile)
    var modified_loot = caravan.modify(base_loot)
    caravan.receive_loot(modified_loot)

    return true
