extends Resource
class_name StateDiffAggregate

var seq: Array[StateChangeDiff]
var originators: Dictionary[Resource, int]


func active(r: Resource):
    return originators.get(r, 0) > 0


func append(s: StateChangeDiff):
    seq.append(s)
    originators[s.originator] = originators.get(s.originator, 0) + 1


func remove(s: StateChangeDiff):
    if seq.has(s):
        seq.erase(s)
        originators[s.originator] -= 1