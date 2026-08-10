extends Control

const MINIMUM_PLAYERS: int = 3

@export var game_scene: PackedScene
@export var player_input_scene: PackedScene

@onready var player_input_list: VBoxContainer = %PlayerInputList
@onready var add_player_button: Button = %AddPlayerButton
@onready var start_game_button: Button = %StartGameButton
@onready var warning_label: Label = %WarningLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	add_player_button.pressed.connect(_on_add_player_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	back_button.pressed.connect(_on_back_pressed)

	warning_label.hide()

	for index: int in range(MINIMUM_PLAYERS):
		add_player_entry(false)


func add_player_entry(can_delete: bool = true) -> void:
	if player_input_scene == null:
		push_error("Player Input Scene has not been assigned.")
		return

	var entry: PlayerEntry = player_input_scene.instantiate() as PlayerEntry

	if entry == null:
		push_error("Player Input Scene root must use player_entry.gd.")
		return

	player_input_list.add_child(entry)

	var player_number: int = player_input_list.get_child_count()
	entry.setup(can_delete, player_number)
	entry.delete_requested.connect(_on_entry_delete_requested)


func collect_player_names() -> Array[String]:
	var names: Array[String] = []

	for child: Node in player_input_list.get_children():
		if child is PlayerEntry:
			var entry: PlayerEntry = child as PlayerEntry
			var entered_name: String = entry.get_player_name()

			if not entered_name.is_empty():
				names.append(entered_name)

	return names


func _on_add_player_pressed() -> void:
	add_player_entry(true)


func _on_entry_delete_requested(entry: PlayerEntry) -> void:
	if player_input_list.get_child_count() <= MINIMUM_PLAYERS:
		return

	entry.queue_free()


func _on_start_game_pressed() -> void:
	var names: Array[String] = collect_player_names()

	if names.size() < MINIMUM_PLAYERS:
		warning_label.text = "Enter at least 3 players."
		warning_label.show()
		return

	if game_scene == null:
		push_error("No game scene has been assigned.")
		return

	GameManager.set_players(names)
	get_tree().change_scene_to_packed(game_scene)


func _on_back_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/mode_selection.tscn")
