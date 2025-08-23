extends Node2D

@onready var hud: Control = $HUDLayer/HUD
@onready var player: Node2D = $Actors/Player
@onready var enemy: Node2D = $Actors/Enemy
@onready var VIP: Node2D = $Actors/VIP

enum Turn {
	PLAYER, 
	ENEMY 
}

var turn : Turn = Turn.PLAYER
var busy := false

const DMG_PLAYER_TO_ENEMY := 3
const DMG_ENEMY_TO_ALLIES := 2

var cover_active := false  # if true, next enemy impact hits Player instead of VIP

func _ready() -> void:
	# Connect HUD -> Battle using a signal (decoupled)
	hud.action_selected.connect(_on_action)
	
func _on_action(action: String) -> void:
	if busy or turn != Turn.PLAYER:
		return
	match action:
		"attack":
			_do_player_attack_and_damage()
			print("Player attacked")
			await _do_player_attack_and_damage()
			_enemy_turn()
		"skill":
			print("Player used (skill)")
		"item":
			print("The item has killed the VIP")
		"guard":
			print("Player guarded")
			

func _do_player_attack_and_damage() -> void:
	hud.set_menu_enabled(false)
	if player.has_method("play_attack"):
			await player.play_attack()
	hud.set_menu_enabled(true)

func _enemy_turn() -> void:
	if enemy.has_method("play_attack"):
		await enemy.play_attack()

func _on_player_attack_impact() -> void:
	if enemy.has_method("apply_damage"):
		enemy.apply_damage(DMG_PLAYER_TO_ENEMY)

func _on_vip_attack_impact() -> void:
	if enemy.has_method("apply_damage"):
		enemy.apply_damage(DMG_PLAYER_TO_ENEMY)

func _on_enemy_attack_impact() -> void:
	if player.has_method("on_hit_animation"):
		player.on_hit_animation()
	if player.has_method("apply_damage"):
		player.apply_damage(DMG_ENEMY_TO_ALLIES)

func _on_vip_died() -> void:
	hud.get_node("LogLabel").text = "GAME OVER"
	pass

func _on_enemy_died() -> void:
	hud.get_node("LogLabel").text = "Enemy Died"


func _on_player_died() -> void:
	hud.get_node("LogLabel").text = "Player Died"
