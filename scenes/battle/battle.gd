# Battle.gd
extends Node2D
# --- Assumes: -------------------------------------------------------------------------------------
# - Actor.gd: class_name Actor; signals: hp_changed(current,max), died(actor: Actor), attack_impact
# - HUD emits: signal action_selected(action: String)
# - Actors are tagged in the editor via Node→Groups: "allies", "enemies" and "vip"

@onready var hud: Control = $HUDLayer/HUD

# --- Tunables -------------------------------------------------------------------------------------
const DMG_PLAYER_ATTACK := 3
const DMG_ENEMY_ATTACK  := 2
const TURN_BREATH_SEC   := 0.15


# --- State  ---------------------------------------------------------------------------------------
var allies: Array[Actor] = []
var enemies: Array[Actor] = []
var vip: Actor = null
var order: Array[Actor] = []
var idx: int = 0
var running := false
var busy := false # used to gate UI during animations

# ==================================================================================================
func _ready() -> void:
	call_deferred("_start")
	
func _start() -> void:
	_collect_and_wire()
	run_battle_loop() # fire-and-forget (loop awaits internally)


# --- Discovery & Wiring  --------------------------------------------------------------------------
func _collect_and_wire() -> void:
	allies.clear()
	enemies.clear()
	vip = null

	for n in get_tree().get_nodes_in_group("allies"):
		if n is Actor:
			var a := n as Actor
			allies.append(a)
			a.died.connect(_on_actor_died)  # died(actor: Actor) -> single handler
	
	for n in get_tree().get_nodes_in_group("enemies"): 
		if n is Actor:
			var e := n as Actor
			enemies.append(e)
			e.died.connect(_on_actor_died)
	
	var vip_list := get_tree().get_nodes_in_group("vip")
	if not vip_list.is_empty() and vip_list[0] is Actor:
		vip = vip_list[0] as Actor
		vip.died.connect(_on_actor_died)

	print("Collected -> allies:", allies.size(), " enemies:", enemies.size())  #testing

	_rebuild_order()
	
	
func _rebuild_order() -> void:
	order.clear()
	
	# MVP ordering: allies first, then enemies (can replace with iniatiative and speed later)
	# loop through allies and add to order []
	for a in allies:
		if is_instance_valid(a) and a.current_hp > 0:
			order.append(a)
	
	# once allies are added to order, enemies follow looping through list
	for e in enemies:
		if is_instance_valid(e) and e.current_hp > 0:
			order.append(e)
	
	var names := [] 									# testing
	for a in order: 									# testing
		names.append(a.name) 							# testing
	print("ORDER:", names, " idx:", idx) 				# testing
	
	idx = 0

func _on_actor_died(actor: Actor) -> void:
	# prune from lists and current round
	allies.erase(actor)
	enemies.erase(actor)
	order.erase(actor)
	_log("%s is down." % actor.name)
	
# --- Main Loop ------------------------------------------------------------------------------------

func run_battle_loop() -> void:
	if running: return
	running = true
	
	while running:
		# win/lose checks
		if enemies.is_empty():
			_log("Victory!")
			_set_menu_enabled(false)
			break
		if allies.is_empty():
			_log("Defeat...")
			_set_menu_enabled(false)
			break
		
		# once all units have acted, reset the order
		if order.is_empty():
			_rebuild_order()
	
		# current is set by indexing the order array
		var current: Actor = order[idx]
		idx += 1
		if idx >= order.size():
			_rebuild_order()
		
		# skip invalid/dead entries (death, status, etc.)
		if current == null or not is_instance_valid(current) or current.current_hp <= 0:
			continue
		
		# check if current turn actor is in allies or enemies and call accordingly
		if current.is_in_group("allies"):
			await _run_player_turn(current)
		else:
			await _run_enemy_turn(current)
			
		await _pause(TURN_BREATH_SEC)
	
	
# --- Player turn ----------------------------------------------------------------------------------
func _run_player_turn(actor: Actor) -> void:
	busy = true
	_set_menu_enabled(true)
	_log("Your turn.")
	
	# wait for HUD to emit action_selected(String)
	var action: String = await hud.action_selected
	_set_menu_enabled(false)
	
	# after receiving HUD string, force to lowercase and call matching function
	match action.to_lower():
		"attack":
			var target := _first_living(enemies)
			if target == null:
				_log("No targets.")
				busy = false
				return
				
			# Start the attack timeline and wait for the impact moment mid-animation
			actor.play_attack() 
			await actor.attack_impact # damage lands at call-method key inside the timeline
			target.apply_damage(DMG_PLAYER_ATTACK)
			await actor.attack_finished
		"guard":
			# Example: set a guarded flag on the actor; play a tiny FX timeline if you have one.
			_log("%s is guarding." % actor.name)
			# TODO: actor.enter_guard_state()

		"item":
			_log("Items not implemented.")
		"skill":
			_log("Skills not implemented.")
		_:
			_log("Action not recognized.")
	
	busy = false
			
# --- Enemy turn -----------------------------------------------------------------------------------
func _run_enemy_turn(actor: Actor) -> void:
	busy = true
	_log("Enemy turn.")
	
	var target := _enemy_choose_target()
	if target == null:
		busy = false
		return
	
	actor.play_attack()
	await actor.attack_impact
	target.apply_damage(DMG_ENEMY_ATTACK)
	await actor.attack_finished

	
	busy = false


func _enemy_choose_target() -> Actor:
	# Prefer VIP if possible, else first living ally
	var vip_list := get_tree().get_nodes_in_group("vip")
	for n in vip_list:
		if n is Actor and (n as Actor).current_hp > 0:
			return n as Actor
	return _first_living(allies)
	

# --- Helpers --------------------------------------------------------------------------------------

func _first_living(list: Array[Actor]) -> Actor:
	for a in list:
		if is_instance_valid(a) and a.current_hp > 0:
			return a
	return null


func _pause(sec: float) -> void:
	await get_tree().create_timer(sec).timeout
	
	
func _set_menu_enabled(on: bool) -> void:
	if hud and hud.has_method("set_menu_enabled"):
		hud.set_menu_enabled(on)
		
		
func _log(text: String) -> void:
	if hud and hud.has_method("show_message"):
		hud.show_message(text)
		
		
# --- End ------------------------------------------------------------------------------------------
# ==================================================================================================


func _on_vip_died(actor: Actor) -> void:
	pass # Replace with function body.


func _on_vip_attack_impact() -> void:
	pass # Replace with function body.


func _on_guard_1_died(actor: Actor) -> void:
	pass # Replace with function body.


func _on_guard_1_attack_impact() -> void:
	pass # Replace with function body.
