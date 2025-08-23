extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died()
signal attack_impact()

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"
@export var block_animation: String = "block"

@export var max_hp: int = 15
@export var current_hp: int = 15

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	player_sprite.play("idle")
	# let listeneners (HUD) initialize from the current values.
	hp_changed.emit(current_hp, max_hp)

# --- Public Action API --- 
 
func play_attack() -> void:
	player_sprite.play("attack")
	animation_player.play("attack_timeline")
	await player_sprite.animation_finished
	player_sprite.play("idle")

# --- Public Health API --- 

func apply_damage(amount: int) -> void:
	set_hp(current_hp - amount) 

	
func on_hit_animation() -> void:
	if has_node("AnimationPlayer"):
		animation_player.play("hit")
		await player_sprite.animation_finished
		player_sprite.play("idle")

func heal(amount: int) -> void:
	set_hp(current_hp + amount)
	
# --- Internal setter that clamps + emits signals --- 

func set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit()
		
		
func _on_attack_impact() -> void:
	attack_impact.emit()
