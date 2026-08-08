class_name CardData
extends Resource

@export var card_number: int
@export_multiline var prompt: String
@export var score: int


func _init(
	new_card_number: int = 0,
	new_prompt: String = "",
	new_score: int = 0
) -> void:
	card_number = new_card_number
	prompt = new_prompt
	score = new_score
