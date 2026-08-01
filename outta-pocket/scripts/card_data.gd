class_name CardData
extends RefCounted

var card_number: int
var prompt: String
var score: int


func _init(
	new_card_number: int,
	new_prompt: String,
	new_score: int
) -> void:
	card_number = new_card_number
	prompt = new_prompt
	score = new_score
