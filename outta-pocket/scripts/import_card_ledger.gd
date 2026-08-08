@tool
extends EditorScript

const CSV_PATH := "res://data/card_ledger.csv"
const OUTPUT_PATH := "res://data/card_library.tres"


func _run() -> void:
	if not FileAccess.file_exists(CSV_PATH):
		push_error("CSV not found: %s" % CSV_PATH)
		return

	var file := FileAccess.open(CSV_PATH, FileAccess.READ)

	if file == null:
		push_error("Could not open CSV.")
		return

	var library := CardLibrary.new()

	# Skip header.
	if not file.eof_reached():
		file.get_csv_line()

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()

		if row.size() < 3:
			continue

		var number_text: String = row[0].strip_edges()
		var prompt_text: String = row[1].strip_edges()
		var score_text: String = row[2].strip_edges()

		if number_text.is_empty():
			continue

		var cleaned_number := number_text.trim_prefix("#")

		if not cleaned_number.is_valid_int():
			push_warning("Invalid card number: %s" % number_text)
			continue

		if prompt_text.is_empty():
			continue

		if not score_text.is_valid_int():
			push_warning("Invalid score: %s" % score_text)
			continue

		var card := CardData.new(
			cleaned_number.to_int(),
			prompt_text,
			score_text.to_int()
		)

		library.cards.append(card)

	var result := ResourceSaver.save(
		library,
		OUTPUT_PATH
	)

	if result != OK:
		push_error(
			"Failed to save card library. Error: %s"
			% result
		)
		return

	print(
		"Imported %d cards into %s"
		% [library.cards.size(), OUTPUT_PATH]
	)
