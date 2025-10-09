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


# Override because we need to talk to our children
func modify(event: String, initial: Variant):
    var responses = []

    responses.append_array(leader.modify(event, initial))

    for person in personnel:
        responses.append_array(person.modify(event, initial))

    for device in equipment:
        responses.append_array(device.modify(event, initial))

    # Do self last
    responses.append_array(super.modify(event, initial))

    return responses


func inflict_damage_to_caravan(damage):
    for child in equipment:
        var modified_damage = child.collect("inflict_damage", damage)
        child.inflict_damage(modified_damage)


func inflict_stress_to_caravan(stress):
    for child in [leader] + personnel:
        var modified_stress = child.collect("inflict_stress", stress)
        child.inflict_stress(modified_stress)


func contribute_xp_to_caravan(xp):
    for child in [leader] + personnel:
        var modified_xp = child.collect("contribute_xp", xp)
        child.contribute_xp(modified_xp)


func consume_caravan_resources(consumption):
    var consumed_calories = 0
    var consumed_power = 0
    var generated_power = 0

    # Calculate food calories consumed
    for child in [leader] + personnel:
        var modified_consumption = child.collect("consume_calories", consumption)
        consumed_calories += modified_consumption

    # Consume food calories
    # TODO: This should actually consume inventory items, but we're not modeling that yet
    if food_calories >= consumed_calories:
        food_calories -= consumed_calories
    else:
        assert(false) # die, for now

    # Calculate power consumed
    for child in equipment:
        var modified_consumption = child.collect("consume_power", consumption)
        consumed_power += modified_consumption

    # Consume power
    if equipment_power >= consumed_power:
        equipment_power -= consumed_power
    else:
        assert(false) # die, for now

    # Calculate power generated
    for child in equipment:
        var modified_generation = child.collect("generate_power", consumption)
        generated_power += modified_generation

    # Generate power
    equipment_power += generated_power