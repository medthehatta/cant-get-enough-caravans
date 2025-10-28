extends Resource
class_name EventFactory


func caravan_damage(
    kinetic: float = 0,
    thermal: float = 0,
    electromagnetic: float = 0,
    explosive: float = 0,
):
    return CaravanDamageEvent.create(
        kinetic,
        thermal,
        electromagnetic,
        explosive,
    )


func equipment_damage(
    kinetic: float = 0,
    thermal: float = 0,
    electromagnetic: float = 0,
    explosive: float = 0,
):
    return EquipmentDamageEvent.create(
        kinetic,
        thermal,
        electromagnetic,
        explosive,
    )


func caravan_stress(stress: float = 0):
    return CaravanStressEvent.create(stress)


func personnel_stress(stress: float = 0):
    return PersonnelStressEvent.create(stress)


func caravan_xp_gain():
    return CaravanXPGainEvent.create()


func personnel_xp_gain():
    return PersonnelXPGainEvent.create()