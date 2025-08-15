extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died()

@export var	max_hp: int = 8
@export var current_hp: int = 8

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"
@onready var enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	enemy_sprite.play("idle")

# --- Public Action API --- 

func play_attack() -> void:
	enemy_sprite.play("attack")
	await enemy_sprite.animation_finished
	enemy_sprite.play("idle")

# --- Public Health API --- 

func apply_damage(amount: int) -> void:
	set_hp(current_hp - amount)
	
func heal(amount: int) -> void:
	set_hp(current_hp + amount)
	
# --- Internal setter that clamps + emits signals --- 

func set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit()
		
