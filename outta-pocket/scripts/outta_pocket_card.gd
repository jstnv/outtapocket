class_name OuttaPocketCard
extends Control

@onready var prompt_label: Label = %PromptLabel
@onready var score_label: Label = %ScoreLabel
@onready var card_number_label: Label = %CardNumberLabel


func display_card(card: CardData) -> void:
	if card == null:
		clear_card()
		return

	prompt_label.text = card.prompt
	score_label.text = str(card.score)
	card_number_label.text = "%03d" % card.card_number

	_resize_prompt_text(card.prompt.length())


func clear_card() -> void:
	prompt_label.text = ""
	score_label.text = ""
	card_number_label.text = ""


func _resize_prompt_text(prompt_length: int) -> void:
	var font_size: int = 72

	if prompt_length > 110:
		font_size = 44
	elif prompt_length > 80:
		font_size = 52
	elif prompt_length > 50:
		font_size = 62

	prompt_label.add_theme_font_size_override(
		"font_size",
		font_size
	)
