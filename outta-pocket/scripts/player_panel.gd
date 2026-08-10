class_name PlayerPanel
extends Button

signal player_selected(player_index: int)

const SCORE_DEFAULT: Texture2D = preload(
	"res://assets/ui/players/score_default.svg"
)
const SCORE_HOVER: Texture2D = preload(
	"res://assets/ui/players/score_current_turn.svg"
)
const SCORE_SELECTED: Texture2D = preload(
	"res://assets/ui/players/score_selected.svg"
)
const SCORE_DISABLED: Texture2D = preload(
	"res://assets/ui/players/score_disabled.svg"
)

@onready var rank_label: Label = %RankLabel
@onready var name_label: Label = %NameLabel
@onready var score_frame: TextureRect = %ScoreFrame

var player_index: int


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	_update_score_frame(SCORE_DISABLED if disabled else SCORE_DEFAULT)


func setup(index: int, player: PlayerData) -> void:
	player_index = index
	rank_label.text = str(player.score)
	name_label.text = player.player_name


func _pressed() -> void:
	player_selected.emit(player_index)


func _on_mouse_entered() -> void:
	_update_score_frame(SCORE_DISABLED if disabled else SCORE_HOVER)


func _on_mouse_exited() -> void:
	_update_score_frame(SCORE_DISABLED if disabled else SCORE_DEFAULT)


func _on_button_down() -> void:
	_update_score_frame(SCORE_DISABLED if disabled else SCORE_SELECTED)


func _on_button_up() -> void:
	_update_score_frame(
		SCORE_HOVER if is_hovered() and not disabled else SCORE_DEFAULT
	)


func _update_score_frame(texture: Texture2D) -> void:
	if score_frame != null:
		score_frame.texture = texture
