extends Node2D

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"
@onready var enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	enemy_sprite.play("idle")

func play_attack() -> void:
	enemy_sprite.play("attack")
	await enemy_sprite.animation_finished
	enemy_sprite.play("idle")
