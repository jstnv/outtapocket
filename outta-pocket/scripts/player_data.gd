# player_data.gd
class_name PlayerData
extends RefCounted

var player_name: String
var score: int = 0


func _init(new_name: String) -> void:
	player_name = new_name
