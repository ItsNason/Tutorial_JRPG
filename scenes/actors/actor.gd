class_name Actor
extends Node2D


# --- Signals  -------------------------------------------------------------------------------------
signal hp_changed(current_hp: int, max_hp: int)
signal died(actor: Actor)
signal attack_impact() # fired by AP call-method key ~80%
signal attack_finished() # relayed from AnimationPlayer when attack clip ends

# --- Faction / placement --------------------------------------------------------------------------
enum Faction { ALLY, ENEMY, NEUTRAL }
@export var faction: Faction = Faction.ALLY
@export var is_vip: bool = false
var side: String = "allies"
var row: String = "FRONT"
var slot_index: int = 0

# --- Stats  ---------------------------------------------------------------------------------------
@export var max_hp: int = 15
@export var current_hp: int = 1

# --- Animation names & Timeline  ------------------------------------------------------------------
@export var attack_timeline_name: StringName = "attack_timeline"
@export var idle_animation: StringName = "idle"
@export var guard_animation: StringName = "guard"


# --- Nodes  ---------------------------------------------------------------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# --- State ----------------------------------------------------------------------------------------
var guarding := false

func _ready() -> void:
	# auto-tag groups
	add_to_group("all_actors")
	match faction:
		Faction.ALLY: add_to_group("allies"); side = "allies"
		Faction.ENEMY: add_to_group("enemies"); side = "enemies"
		_:
			pass
	if is_vip: add_to_group("vip")

	# show idle if available
	_play_if_exists(idle_animation)

	# relay AP finished -> attack_finished
	animation_player.animation_finished.connect(_on_ap_finished)  # AnimationPlayer signal
		
	# clamp/init HP and broadcast once so HUD can sync
	current_hp = clamp(current_hp, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)


# --- Public API --------------------------------------------------------------------------------
func play_attack() -> void:
	_play_if_exists("attack") 
	animation_player.play(attack_timeline_name)
	

func apply_damage(amount: int) -> void:
	var dmg := int(ceil(amount * 0.5)) if guarding else amount
	guarding = false
	_set_hp(current_hp - dmg)
	_play_hit_react() # small tweened flinch
	
	
# --- Helpers ----------------------------------------------------------------------------------
func _set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit(self)

		
func _on_attack_impact() -> void:
	# called by Animation Player
	attack_impact.emit()

	
func _on_ap_finished(animation_name: StringName) -> void:
	if animation_name == attack_timeline_name:
		attack_finished.emit()
		if not guarding:
			_play_if_exists(idle_animation)

func _play_if_exists(animation_name: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
		
		
func _play_hit_react(duration := 0.18) -> void:
	# tiny squash + fade, then restore; shows guard pose during flinch
	var start_scale := sprite.scale
	var start_mod := sprite.modulate
	_play_if_exists(guard_animation)
	var tw := create_tween()
	tw.tween_property(sprite, "scale", start_scale * Vector2(1.08, 0.92), duration * 0.45)
	tw.tween_property(sprite, "scale", start_scale,                     duration * 0.55)
	tw.parallel().tween_property(sprite, "modulate", Color(1,1,1,0.7),  duration * 0.30)
	tw.parallel().tween_property(sprite, "modulate", start_mod,         duration * 0.70) 
	
