# player_panel.gd
class_name PlayerPanel
extends Button

signal player_selected(player_index: int)

@onready var rank_label: Label = %RankLabel
@onready var name_label: Label = %NameLabel

var player_index: int


func setup(index: int, player: PlayerData) -> void:
	player_index = index
	rank_label.text = str(player.score)
	name_label.text = player.player_name


func _pressed() -> void:
	player_selected.emit(player_index)
