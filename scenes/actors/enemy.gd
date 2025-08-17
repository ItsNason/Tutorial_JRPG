extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died()

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"

@export var	max_hp: int = 10
@export var current_hp: int = 8

@onready var enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	enemy_sprite.play("idle")
	# let listeneners (HUD) initialize from the current values.
	hp_changed.emit(current_hp, max_hp)
	
# --- Public Action API --- 

func play_attack() -> void:
	enemy_sprite.play("attack")
	await enemy_sprite.animation_finished
	enemy_sprite.play("idle")

# --- Public Health API --- 

func apply_damage(amount: int) -> void:
	set_hp(current_hp - amount)
	if has_node("AnimationPlayer"):
		animation_player.play("hit")
		
		
func heal(amount: int) -> void:
	set_hp(current_hp + amount)
	
# --- Internal setter that clamps + emits signals --- 


func set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit()
		
