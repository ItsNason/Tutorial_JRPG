extends Node2D
signal attack_finished(action: String)

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	player_sprite.play("idle")
	
func play_attack() -> void:
	player_sprite.play("attack")
	await player_sprite.animation_finished
	player_sprite.play("idle")
	_emit("attack_finished")
	
func _emit(name: String) -> void:
	emit_signal("", name)
