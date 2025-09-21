extends ResourceValidator
class_name ScriptTypeValidator


@export var script_type: Script


func validate(resource: Resource):
    debug_print(script_type)
    return script_parents(resource.get_script()).has(script_type)


func script_parents(script: Script) -> Array[Script]:
    debug_print(script)
    var script_parent = script.get_base_script()
    var res: Array[Script] = []
    res.append(script)
    if script_parent != null:
        res.append_array(script_parents(script_parent))
    return res
