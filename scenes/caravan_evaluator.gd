extends Node
class_name CaravanEvaluator


@export var leader: Person
@export var personnel: Array[Person]
@export var equipment: Array[Equipment]


# Helpers


func _sum(prop, acc, x):
    if prop in x:
        return acc + x.get(prop)
    else:
        return 0


func sum_property(prop: String, arr: Array[Variant]):
    return arr.reduce(func(acc, x): return _sum(prop, acc, x), 0)


# Node Methods


func setup(leader_: Person, personnel_: Array[Person], equipment_: Array[Equipment]):
    set_leader(leader_)
    set_personnel(personnel_)
    set_equipment(equipment_)


# Node Getters / Setters


func set_leader(who: Person):
    leader = who


func set_personnel(people: Array[Person]):
    personnel = people


func add_personnel(people: Array[Person]):
    personnel.append_array(people)


func remove_personnel(people: Array[Person]):
    for person in people:
        if personnel.has(person):
            personnel.erase(person)


func set_equipment(devices: Array[Equipment]):
    equipment = devices


func add_equipment(devices: Array[Equipment]):
    equipment.append_array(devices)


func remove_equipment(devices: Array[Equipment]):
    for device in devices:
        if equipment.has(device):
            equipment.erase(device)


# Evaluated Caravan Properties


func get_is_personnel_count_valid():
    var personnel_size = personnel.size()
    var valid_size = get_num_personnel_slots()
    return personnel_size <= valid_size


func get_is_equipment_count_valid():
    var equipment_size = equipment.size()
    var valid_size = get_num_equipment_slots()
    return equipment_size <= valid_size


func get_weight():
    return sum_property("weight", equipment)


func get_daily_calories():
    if not leader:
        return 0
    return leader.daily_calories + sum_property("daily_calories", personnel)


func get_num_personnel_slots():
    if not leader:
        return 0
    return leader.max_personnel_as_leader


func get_num_equipment_slots():
    return (1 if leader else 0) + sum_property("max_equipment_slots", personnel)


func get_cargo_capacity():
    return sum_property("cargo_capacity", personnel) + sum_property("cargo_capacity", equipment)


func emit_caravan():
    var caravan = Caravan.new()
    caravan.leader = leader
    caravan.personnel = personnel
    caravan.equipment = equipment
    caravan.food_calories = 900 # temp
    caravan.equipment_power = 900 # temp
    caravan.weight = get_weight()
    return caravan
