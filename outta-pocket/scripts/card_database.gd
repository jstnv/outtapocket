class_name CardDatabase
extends Node

const card_library: CardLibrary = preload(
	"res://data/card_library.tres"
)


func load_cards() -> Array[CardData]:
	if card_library == null:
		push_error("Card library could not be loaded.")
		return []

	var loaded_cards: Array[CardData] = card_library.cards.duplicate()

	print("Loaded %d cards." % loaded_cards.size())

	return loaded_cards
