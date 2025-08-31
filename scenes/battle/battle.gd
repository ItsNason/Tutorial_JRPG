extends Node2D

@onready var hud: Control = $HUDLayer/HUD
@onready var guard_green: Actor = %GuardGreen
@onready var enemy_guard_red: Actor = %Enemy_GuardRed
@onready var VIP: Node2D = $Actors/VIP

enum Turn {
	GUARD_GREEN,
	GUARD_ORANGE, 
	ENEMY_GUARD_RED 
}

var turn : Turn = Turn.GUARD_GREEN
var busy := false

const DMG_GUARD_GREEN_TO_ENEMY := 3
const DMG_PARTY_MEMBER_B_TO_ENEMY := 4
const DMG_ENEMY_TO_ALLIES := 2

var cover_active := false  # if true, next enemy impact hits Player instead of VIP

func _ready() -> void:
	# Connect HUD -> Battle using a signal (decoupled)
	hud.action_selected.connect(_on_action)
	
func _on_action(action: String) -> void:
	#if busy or turn != Turn.guard_green:
		#return
	match action:
		"attack":
			_do_player_attack_and_damage()
			print("Player attacked")
		"skill":
			print("Player used (skill)")
		"item":
			print("The item has killed the VIP")
		"guard":
			print("Player guarded")
			
			
# -------------- Player Party Handling --------------- //

func _do_player_attack_and_damage() -> void:
	hud.set_menu_enabled(false)
	if guard_green.has_method("play_attack"):
			guard_green.play_attack()
	hud.set_menu_enabled(true)

func _enemy_turn() -> void:
	if enemy_guard_red.has_method("play_attack"):
		await enemy_guard_red.play_attack()
		
func _on_guard_green_attack_impact() -> void:
	if enemy_guard_red.has_method("apply_damage"):
		enemy_guard_red.apply_damage(DMG_GUARD_GREEN_TO_ENEMY)

func _on_guard_orange_attack_impact() -> void:
	if enemy_guard_red.has_method("apply_damage"):
		enemy_guard_red.apply_damage(DMG_PARTY_MEMBER_B_TO_ENEMY)

func _on_vip_attack_impact() -> void:
	if enemy_guard_red.has_method("apply_damage"):
		enemy_guard_red.apply_damage(DMG_GUARD_GREEN_TO_ENEMY)

func _on_enemy_guard_red_attack_impact() -> void:
	if guard_green.has_method("on_hit_animation"):
		guard_green.on_hit_animation()
	if guard_green.has_method("apply_damage"):
		guard_green.apply_damage(DMG_ENEMY_TO_ALLIES)

func _on_vip_died() -> void:
	hud.get_node("LogLabel").text = "GAME OVER"
	pass

func _on_enemy_guard_red_died() -> void:
	hud.get_node("LogLabel").text = "Enemy Died"

func _on_guard_green_died() -> void:
	hud.get_node("LogLabel").text = "Party Member A Died"


func _on_guard_orange_died() -> void:
	hud.get_node("LogLabel").text = "Party Member B Died"
