extends Resource
class_name LootTable


@export var table: Dictionary[Resource, float]


func _construct_drop_data(probability_dict: Dictionary[Resource, float]):
    var drop_resources: Array[Resource] = []
    var drop_probabilities: Array[float] = []
    var total: float = 0
    for res in probability_dict.keys():
        var prob = probability_dict[res]
        total += prob
        if total > 100:
            print("ERROR constructing drop ladder: probabilities add up to more than 100%")
            return {}

        drop_resources.append(res)
        drop_probabilities.append(prob)

    # Any leftover probability is a null drop-- you get nothing
    var remaining = 100 - total
    drop_resources.append(null)
    drop_probabilities.append(remaining)

    return {"resources": drop_resources, "probabilities": drop_probabilities}


func drop_from_table(probability_dict: Dictionary[Resource, float], rng: RandomNumberGenerator = null):
    var gen = rng if rng else RandomNumberGenerator.new()
    var data = _construct_drop_data(probability_dict)
    var index = gen.rand_weighted(PackedFloat32Array(data["probabilities"]))
    var resource = data["resources"][index]
    # null means no drop
    return resource
