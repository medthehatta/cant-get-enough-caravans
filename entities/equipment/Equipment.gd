extends Actor
class_name Equipment

@export var weight: float
@export var cargo_capacity: float
@export var icon: Texture2D
@export_multiline var flavor: String
@export var durability: float = 1
@export var integrity: float = 100
@export var power_demand: float = 0


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


func inflict_damage(damage):
    var diff = (
        damage.get("kinetic", 0)
        + damage.get("thermal", 0)
        + damage.get("electromagnetic", 0)
        + damage.get("explosive", 0)
    )
    integrity = max(0, integrity - diff)