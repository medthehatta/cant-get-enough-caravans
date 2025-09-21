extends Resource
class_name Person

@export var name: String
@export var icon: Texture2D
@export var max_personnel_as_leader: int = 1
@export var max_equipment_slots: int = 1
@export var daily_calories: int = 2000
@export var stress: int = 0
@export_multiline var flavor: String
@export var auras: Array[Aura] = []


func base_stats():
    return {
        "name": name,
        "_kind": "Person",
        "personnel_slots": max_personnel_as_leader,
        "equipment_slots": max_equipment_slots,
        "daily_calories": daily_calories,
    }


func dynamic_stats():
    return {
        "stress": stress,
        "auras": auras,
    }