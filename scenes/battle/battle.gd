extends Node2D

@onready var player: Node2D = $Actors/Player
@onready var enemy: Node2D = $Actors/Enemy
@onready var hud: Control = $HUDLayer/HUD

const DAMAGE := 3

func _ready() -> void:
	# Connect HUD -> Battle using a signal (decoupled)
	hud.action_selected.connect(_on_action)
	
func _on_action(action: String) -> void:
	match action:
		"attack":
			_do_player_attack_and_damage()
			print("Player attacked")
		"skill":
			print("Player used (skill)")
		"item":
			print("Player used (item)")
		"guard":
			print("Player guarded")
			
			
func _do_player_attack_and_damage() -> void:
	hud.set_menu_enabled(false)
	if player.has_method("play_attack"):
			await player.play_attack()
	hud.set_menu_enabled(true)


func _on_player_attack_impact() -> void:
	if enemy.has_method("apply_damage"):
		enemy.apply_damage(DAMAGE)


func _on_enemy_died() -> void:
	hud.get_node("LogLabel").text = "Enemy Died"
