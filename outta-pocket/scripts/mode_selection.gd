extends Control


func _ready() -> void:
	%InfiniteButton.pressed.connect(_on_infinite_pressed)
	%FirstTo10Button.pressed.connect(_on_first_to_10_pressed)
	%BackButton.pressed.connect(_on_back_pressed)


func _select_mode(mode: GameManager.GameMode) -> void:
	GameManager.selected_game_mode = mode
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/player_setup.tscn")


func _on_infinite_pressed() -> void:
	_select_mode(GameManager.GameMode.INFINITE)


func _on_first_to_10_pressed() -> void:
	_select_mode(GameManager.GameMode.FIRST_TO_10)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/startup_screen.tscn")
