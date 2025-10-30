extends Actor
class_name Person

@export var icon: Texture2D
@export var max_personnel_as_leader: int = 1
@export var max_equipment_slots: int = 1
@export var daily_calories: int = 2000
@export var stress: float = 0.01
@export_multiline var flavor: String


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


func inflict_stress(stress_):
    var s = stress_.stress
    # The stress is gonna be sigmoid, but we will not store the underlying "x"
    # value.  So this formula inverts the sigmoid, adds the incoming stress,
    # then re-sigmoids it
    var denom = 1 + (1 / stress - 1) * exp(-s)
    stress = 1 / denom


func contribute_xp(_xp_):
    pass