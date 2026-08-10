extends Node

signal card_changed(card: CardData)
signal players_changed
signal game_won(player: PlayerData)

enum GameMode {
	INFINITE,
	FIRST_TO_10
}

var selected_game_mode: GameMode = GameMode.INFINITE
var winner: PlayerData = null

var players: Array[PlayerData] = []

var all_cards: Array[CardData] = []
var draw_pile: Array[CardData] = []

var current_card: CardData = null


func set_players(names: Array[String]) -> void:
	players.clear()
	winner = null

	for entered_name: String in names:
		var cleaned_name: String = entered_name.strip_edges()

		if cleaned_name.is_empty():
			continue

		players.append(PlayerData.new(cleaned_name))

	players_changed.emit()


func start_card_deck(cards: Array[CardData]) -> void:
	all_cards = cards.duplicate()

	_refill_draw_pile()
	draw_next_card()


func draw_next_card() -> void:
	if draw_pile.is_empty():
		_refill_draw_pile()

	if draw_pile.is_empty():
		current_card = null
		card_changed.emit(null)
		return

	current_card = draw_pile.pop_back()
	card_changed.emit(current_card)


func assign_current_card(player_index: int) -> void:
	if current_card == null:
		return

	if player_index < 0 or player_index >= players.size():
		push_warning("Invalid player index: %d" % player_index)
		return

	var selected_player: PlayerData = players[player_index]
	selected_player.score += current_card.score

	# Prevent the current card from being assigned twice.
	current_card = null

	players_changed.emit()

	if selected_game_mode == GameMode.FIRST_TO_10 \
			and selected_player.score >= 10:
		winner = selected_player
		game_won.emit(selected_player)
		return

	draw_next_card()


func skip_current_card() -> void:
	if current_card == null:
		return

	current_card = null
	draw_next_card()


func _refill_draw_pile() -> void:
	draw_pile = all_cards.duplicate()
	draw_pile.shuffle()

func reset_game() -> void:
	players.clear()
	all_cards.clear()
	draw_pile.clear()
	current_card = null
	winner = null

	players_changed.emit()
	card_changed.emit(null)
