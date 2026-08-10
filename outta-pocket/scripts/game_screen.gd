extends Control

enum GameState {
	VIEWING_CARD,
	SELECTING_PLAYER
}

const PLAYER_SLIDE_DISTANCE: float = 280.0
const PLAYER_SLIDE_DURATION: float = 0.34
const RIGHT_LIST_DELAY: float = 0.06
const CARD_SELECT_SCALE: Vector2 = Vector2(0.72, 0.72)
const CARD_SCALE_DURATION: float = 0.30

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
var player_list_tween: Tween
var card_scale_tween: Tween
var left_player_rest_x: float
var right_player_rest_x: float


func _ready() -> void:
	assign_button.pressed.connect(_on_assign_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	end_game_button.pressed.connect(_on_end_game_pressed)

	GameManager.card_changed.connect(_on_card_changed)
	GameManager.players_changed.connect(_on_players_changed)
	GameManager.game_won.connect(_on_game_won)
	card_display.resized.connect(_update_card_pivot)
	_update_card_pivot()

	left_player_rest_x = left_player_list.position.x
	right_player_rest_x = right_player_list.position.x

	var cards: Array[CardData] = card_database.load_cards()
	GameManager.start_card_deck(cards)

	show_card_state()


func show_card_state() -> void:
	current_state = GameState.VIEWING_CARD
	_reset_player_list_animation()
	_animate_card_scale(Vector2.ONE)

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

	_animate_player_lists_in()
	_animate_card_scale(CARD_SELECT_SCALE)


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


func _on_game_won(_player: PlayerData) -> void:
	get_tree().change_scene_to_file("res://scenes/winner_screen.tscn")


func _on_end_game_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file(
		"res://scenes/player_setup.tscn"
	)


func _animate_player_lists_in() -> void:
	if player_list_tween != null and player_list_tween.is_valid():
		player_list_tween.kill()

	# Capture the responsive anchor result each time. Only x is animated;
	# VBoxContainer remains responsible for vertical centering and height.
	left_player_rest_x = left_player_list.position.x
	right_player_rest_x = right_player_list.position.x

	left_player_list.position.x = (
		left_player_rest_x - PLAYER_SLIDE_DISTANCE
	)
	right_player_list.position.x = (
		right_player_rest_x + PLAYER_SLIDE_DISTANCE
	)
	left_player_list.modulate.a = 0.0
	right_player_list.modulate.a = 0.0

	player_list_tween = create_tween()
	player_list_tween.set_parallel(true)

	player_list_tween.tween_property(
		left_player_list,
		"position:x",
		left_player_rest_x,
		PLAYER_SLIDE_DURATION
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	player_list_tween.tween_property(
		left_player_list,
		"modulate:a",
		1.0,
		PLAYER_SLIDE_DURATION * 0.65
	)
	player_list_tween.tween_property(
		right_player_list,
		"position:x",
		right_player_rest_x,
		PLAYER_SLIDE_DURATION
	).set_delay(RIGHT_LIST_DELAY).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	player_list_tween.tween_property(
		right_player_list,
		"modulate:a",
		1.0,
		PLAYER_SLIDE_DURATION * 0.65
	).set_delay(RIGHT_LIST_DELAY)


func _reset_player_list_animation() -> void:
	if player_list_tween != null and player_list_tween.is_valid():
		player_list_tween.kill()

	left_player_list.position.x = left_player_rest_x
	right_player_list.position.x = right_player_rest_x
	left_player_list.modulate = Color.WHITE
	right_player_list.modulate = Color.WHITE


func _animate_card_scale(target_scale: Vector2) -> void:
	if card_scale_tween != null and card_scale_tween.is_valid():
		card_scale_tween.kill()

	_update_card_pivot()
	card_scale_tween = create_tween()
	card_scale_tween.tween_property(
		card_display,
		"scale",
		target_scale,
		CARD_SCALE_DURATION
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_card_pivot() -> void:
	card_display.pivot_offset = card_display.size * 0.5


func _clear_container(container: Container) -> void:
	for child: Node in container.get_children():
		child.queue_free()
