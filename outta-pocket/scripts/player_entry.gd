# player_entry.gd
class_name PlayerEntry
extends HBoxContainer

signal delete_requested(entry: PlayerEntry)

@onready var name_input: LineEdit = %NameInput
@onready var delete_button: Button = %DeleteButton


func _ready() -> void:
	delete_button.pressed.connect(_on_delete_pressed)


func setup(can_delete: bool, placeholder_number: int) -> void:
	name_input.placeholder_text = "Player %d" % placeholder_number
	delete_button.visible = can_delete


func get_player_name() -> String:
	return name_input.text.strip_edges()


func _on_delete_pressed() -> void:
	delete_requested.emit(self)
