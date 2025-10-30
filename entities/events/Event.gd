extends Resource
class_name Event


static func check_dictionary(keys: Array, dict: Dictionary):
    for k in dict.keys():
        if not keys.has(k):
            print("Unexpected key: {0}".format([k]))
            assert(false)