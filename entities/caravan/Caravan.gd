extends Actor
class_name Caravan


@export var leader: Person
@export var personnel: Array[Person] = []
@export var equipment: Array[Equipment] = []
# TODO: Temporary measures of food and power consumption
@export var food_calories: int
@export var equipment_power: int


func base_stats():
    return {
        "name": name,
        "_kind": "Caravan",
    }


func dynamic_stats():
    return {
        "remaining_food_calories": food_calories,
        "remaining_equipment_power": equipment_power,
        "auras": auras,
    }