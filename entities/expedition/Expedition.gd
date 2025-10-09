extends Resource
class_name Expedition


@export var tile_size: int
@export var caravan: Caravan
@export var tiles: Array[MapTile]


var duration = 0

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


func _base_speed_for(tile):
    return {"biome": tile.biome, "speed": int(1000 / tile.density)}


func traverse(tile):
    # Calculate time accrued
    var initial_speed = _base_speed_for(tile)
    var modified_speed = caravan.collect("traverse_speed", initial_speed)
    var new_duration = tile_size / modified_speed
    duration += new_duration

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
    var base_consumption = {"biome": tile.biome, "duration": new_duration}
    var modified_consumption = caravan.collect("consume_caravan_resources", base_consumption)
    caravan.consume_caravan_resources(modified_consumption)

    # Drop loot
    # TODO


func traverse_next():
    if tiles.size() >= tile_index + 1:
        tile_index += 1
    else:
        assert(false) # die

    var tile = tiles[tile_index]
    traverse(tile)
    # DEBUG
    print(caravan.dynamic_stats())