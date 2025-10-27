extends Resource
class_name Expedition


@export var caravan: Caravan
@export var route: Array[MapTile]


var remaining_tile_progress = null

var tile_index = 0


func _base_damage_for(tile):
    if tile.biome == "volcanic":
        return {"thermal": 50}
    else:
        return {"kinetic": 10}


func _base_stress_for(_tile):
    return {"stress": 10}


func _base_xp_for(tile):
    return {tile.biome: 10}


func _progress_required_for(tile):
    return tile.density


# Return bool for now: whether to continue or whether the expedition is over
func traverse(delta: float) -> bool:
    var tile: MapTile

    if remaining_tile_progress != null and remaining_tile_progress <= 0:
        remaining_tile_progress = null

        # FIXME: should this be route.size() - 1?
        if tile_index < route.size():
            tile_index += 1
        else:
            tile_index = 0
            return false

    tile = route[tile_index]

    if remaining_tile_progress == null:
        remaining_tile_progress = _progress_required_for(tile)

    var initial_speed = {"speed": 1}
    var modified_speed = caravan.collect("traverse_speed", initial_speed)
    remaining_tile_progress -= modified_speed["speed"] * delta

    # Inflict integrity damage
    var base_damage = _base_damage_for(tile)
    var modified_damage = caravan.collect("inflict_damage_to_caravan", base_damage)
    caravan.inflict_damage_to_caravan(modified_damage)

    # Inflict stress
    var base_stress = _base_stress_for(tile)
    var modified_stress = caravan.collect("inflict_stress_to_caravan", base_stress)
    caravan.inflict_stress_to_caravan(modified_stress)

    # Contribute XP
    var base_xp = _base_xp_for(tile)
    var modified_xp = caravan.collect("contribute_xp_to_caravan", base_xp)
    caravan.contribute_xp_to_caravan(modified_xp)

    # Consume resources
    var base_consumption = {
        "biome": tile.biome,
        "speed": modified_speed,
        "calories": 0,
        "power": 0,
    }
    var modified_consumption = caravan.collect("consume_caravan_resources", base_consumption)
    caravan.consume_caravan_resources(modified_consumption)

    # Drop loot
    # TODO

    return true
