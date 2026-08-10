extends Control


func _ready() -> void:
	%PlayAgainButton.pressed.connect(_on_play_again_pressed)
	%MainMenuButton.pressed.connect(_on_main_menu_pressed)

	if GameManager.winner == null:
		push_warning("Winner screen opened without a winner.")
		get_tree().change_scene_to_file("res://scenes/startup_screen.tscn")
		return

	%WinnerNameLabel.text = GameManager.winner.player_name
	%WinnerScoreLabel.text = "%d points" % GameManager.winner.score


func _on_play_again_pressed() -> void:
	# reset_game intentionally preserves the selected mode.
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/player_setup.tscn")


func _on_main_menu_pressed() -> void:
	GameManager.reset_game()
	GameManager.selected_game_mode = GameManager.GameMode.INFINITE
	get_tree().change_scene_to_file("res://scenes/startup_screen.tscn")
