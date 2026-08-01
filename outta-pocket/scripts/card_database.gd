class_name CardDatabase
extends Node

const LEDGER_PATH: String = "res://data/card_ledger.csv"

var cards: Array[CardData] = []


func load_cards() -> Array[CardData]:
	cards.clear()

	if not FileAccess.file_exists(LEDGER_PATH):
		push_error("Card ledger not found: %s" % LEDGER_PATH)
		return cards

	var file: FileAccess = FileAccess.open(
		LEDGER_PATH,
		FileAccess.READ
	)

	if file == null:
		push_error(
			"Could not open card ledger. Error code: %s"
			% FileAccess.get_open_error()
		)
		return cards

	# Skip the header row.
	if not file.eof_reached():
		file.get_csv_line()

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		print(row)
		if row.size() < 3:
			continue

		var number_text: String = row[0].strip_edges()
		var prompt_text: String = row[1].strip_edges()
		var score_text: String = row[2].strip_edges()

		# Allow card numbers formatted like "#001".
		var cleaned_number: String = number_text.trim_prefix("#")

		if not cleaned_number.is_valid_int():
			push_warning("Invalid card number: %s" % number_text)
			continue

		if not score_text.is_valid_int():
			continue

		var card: CardData = CardData.new(
			number_text.to_int(),
			prompt_text,
			score_text.to_int()
		)
		cards.append(card)

	print("Loaded %d cards." % cards.size())

	return cards
