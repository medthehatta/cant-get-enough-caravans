extends RefCounted
class_name DebugPrinter


var debug_owner


func setup(owner):
    debug_owner = owner
    return self


func print(msg):
    if not debug_owner:
        return

    if not "debug" in debug_owner:
        return

    if debug_owner.debug:
        print(msg)