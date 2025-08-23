extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died()
signal attack_impact()

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"
@export var block_animation: String = "block"


@export var max_hp: int = 20
@export var current_hp: int = 20

@onready var VIP_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_VIP: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	VIP_sprite.play("idle")
	# let listeneners (HUD) initialize from the current values.
	hp_changed.emit(current_hp, max_hp)

# --- Public Action API --- 
 
func play_attack() -> void:
	VIP_sprite.play("attack")
	animation_VIP.play("attack_timeline")
	await VIP_sprite.animation_finished
	VIP_sprite.play("idle")

# --- Public Health API --- 

func apply_damage(amount: int) -> void:
	VIP_sprite.play("block")
	await VIP_sprite.animation_finished
	set_hp(current_hp - amount)
	
	
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
