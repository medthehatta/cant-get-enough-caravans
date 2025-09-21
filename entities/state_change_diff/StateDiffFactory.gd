extends Resource
class_name StateDiffFactory


func no_op(originator: Resource):
    var sd = NoOpStateDiff.new()
    sd.originator = originator
    return sd


func additive(originator: Resource, component: String, value: float):
    var sd = AdditiveStateDiff.new()
    sd.originator = originator
    sd.component = component
    sd.value = value
    return sd


func multiplicative(originator: Resource, component: String, value: float):
    var sd = MultiplicativeStateDiff.new()
    sd.originator = originator
    sd.component = component
    sd.value = value
    return sd


func override(originator: Resource, component: String, value: float):
    var sd = OverrideStateDiff.new()
    sd.originator = originator
    sd.component = component
    sd.value = value
    return sd


func add_aura(originator: Resource, aura: Aura, target: Resource):
    var sd = AddAuraStateDiff.new()
    sd.originator = originator
    sd.aura = aura
    sd.target = target
    return sd


func remove_aura(originator: Resource, aura: Aura, target: Resource):
    var sd = RemoveAuraStateDiff.new()
    sd.originator = originator
    sd.aura = aura
    sd.target = target
    return sd
