extends Panel
class_name SimpleTextInputModal

@onready var label = %Label
@onready var confirm = %ConfirmButton
@onready var cancel = %CancelButton
@onready var input = %TextEdit

signal modal_done

var result: String
var output: String


func prompt_and_wait(p: String):
    label.text = p
    visible = true
    input.grab_focus()

    await modal_done

    visible = false

    get_tree().create_timer(5).timeout.connect(func(): queue_free())

    return result


func _ready():
    visible = false
    print("...modal...")


func _on_cancel_button_pressed() -> void:
    result = ""
    modal_done.emit()


func _on_confirm_button_pressed() -> void:
    result = input.text
    modal_done.emit()


func _on_text_edit_text_submitted(new_text: String) -> void:
    result = new_text
    modal_done.emit()
