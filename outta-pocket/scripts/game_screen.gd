extends Control

enum GameState {
	VIEWING_CARD,
	SELECTING_PLAYER
}

@export var player_panel_scene: PackedScene

@onready var card_database: CardDatabase = %CardDatabase
@onready var card_display: OuttaPocketCard = %OuttaPocketCard

@onready var left_player_list: VBoxContainer = %LeftPlayerList
@onready var right_player_list: VBoxContainer = %RightPlayerList

@onready var assign_button: Button = %AssignButton
@onready var skip_button: Button = %SkipButton
@onready var cancel_button: Button = %CancelButton
@onready var end_game_button: Button = %EndGameButton

var current_state: GameState = GameState.VIEWING_CARD


func _ready() -> void:
	assign_button.pressed.connect(_on_assign_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	end_game_button.pressed.connect(_on_end_game_pressed)

	GameManager.card_changed.connect(_on_card_changed)
	GameManager.players_changed.connect(_on_players_changed)

	var cards: Array[CardData] = card_database.load_cards()
	GameManager.start_card_deck(cards)

	show_card_state()


func show_card_state() -> void:
	current_state = GameState.VIEWING_CARD

	left_player_list.hide()
	right_player_list.hide()
	cancel_button.hide()

	assign_button.show()
	skip_button.show()


func show_assign_state() -> void:
	if GameManager.current_card == null:
		return

	current_state = GameState.SELECTING_PLAYER

	assign_button.hide()
	skip_button.hide()

	rebuild_player_panels()

	left_player_list.show()
	right_player_list.show()
	cancel_button.show()


func rebuild_player_panels() -> void:
	_clear_container(left_player_list)
	_clear_container(right_player_list)

	if player_panel_scene == null:
		push_error("Player Panel Scene has not been assigned.")
		return

	for index: int in range(GameManager.players.size()):
		var panel: PlayerPanel = player_panel_scene.instantiate() as PlayerPanel

		if panel == null:
			push_error("Player Panel Scene root must use player_panel.gd.")
			return

		var player: PlayerData = GameManager.players[index]

		# Add the panel first so its @onready variables initialize.
		if index % 2 == 0:
			left_player_list.add_child(panel)
		else:
			right_player_list.add_child(panel)

		panel.setup(index, player)
		panel.player_selected.connect(_on_player_selected)


func _on_assign_pressed() -> void:
	if current_state != GameState.VIEWING_CARD:
		return

	show_assign_state()


func _on_skip_pressed() -> void:
	if current_state != GameState.VIEWING_CARD:
		return

	GameManager.skip_current_card()


func _on_cancel_pressed() -> void:
	if current_state != GameState.SELECTING_PLAYER:
		return

	show_card_state()


func _on_player_selected(player_index: int) -> void:
	if current_state != GameState.SELECTING_PLAYER:
		return

	# Immediately leave selection mode so the same card
	# cannot be assigned more than once.
	current_state = GameState.VIEWING_CARD

	GameManager.assign_current_card(player_index)
	show_card_state()


func _on_card_changed(card: CardData) -> void:
	if card_display == null:
		push_error("Card display was not found.")
		return

	card_display.display_card(card)


func _on_players_changed() -> void:
	if current_state == GameState.SELECTING_PLAYER:
		rebuild_player_panels()


func _on_end_game_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file(
		"res://scenes/player_setup.tscn"
	)


func _clear_container(container: Container) -> void:
	for child: Node in container.get_children():
		child.queue_free()
