extends Actor
class_name Equipment

@export var weight: int
@export var cargo_capacity: int
@export var icon: Texture2D
@export_multiline var flavor: String
@export var durability: int = 1
@export var integrity: int = 100
@export var power_demand: int = 0


func base_stats():
    return {
        "name": name,
        "_kind": "Equipment",
        "weight": weight,
        "cargo_capacity": cargo_capacity,
        "durability": durability,
        "power_demand": power_demand,
    }


func dynamic_stats():
    return {
        "integrity": integrity,
        "auras": auras,
    }