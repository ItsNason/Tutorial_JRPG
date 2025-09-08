# HUD.gd
extends Control
signal action_selected(action: String)

@onready var _attack_btn: Button = %AttackButton
@onready var _guard_btn: Button = %GuardButton
@onready var _skill_btn: Button = %SkillButton
@onready var _item_btn: Button = %ItemButton

@onready var _log: Label = %LogLabel

# --- Player UI ------------------------------------------------------------------------------------
@onready var _p_label: Label = %PlayerHpLabel
@onready var _p_bar: ProgressBar = %PlayerHpBar

# --- Enemy UI -------------------------------------------------------------------------------------
@onready var _e_label: Label = %EnemyHpLabel
@onready var _e_bar: ProgressBar = %EnemyHpBar



# --- VIP UI ---------------------------------------------------------------------------------------
@onready var _vip_label: Label       = %VipHpLabel
@onready var _vip_bar:   ProgressBar = %VipHpBar


func _ready() -> void:
	# Wires buttons to emite a single, decouple signal Battle awaits.
	_attack_btn.pressed.connect(func(): action_selected.emit("attack"))
	_guard_btn.pressed.connect(func(): action_selected.emit("guard"))
	_skill_btn.pressed.connect(func(): action_selected.emit("skill"))
	_item_btn.pressed.connect(func(): action_selected.emit("item"))
	
	set_menu_enabled(true)
	
	show_message("")

	
# --- Public API  ----------------------------------------------------------------------------------
func show_message(text: String) -> void:
	if _log:
		_log.text = text
			
			
func set_menu_enabled(on: bool) -> void:
	_attack_btn.disabled = not on
	_guard_btn.disabled = not on
	_skill_btn.disabled = not on
	_item_btn.disabled = not on
	

# Change the visible names near the bars, if you display them
func set_player_name(display_name: String) -> void:
	if _p_label:
		_p_label.text = "%s  HP: %d/%d" % [display_name, int(_p_bar.value), int(_p_bar.max_value)]


func set_enemy_name(display_name: String) -> void:
	if _e_label:
		_e_label.text = "%s  HP: %d/%d" % [display_name, int(_e_bar.value), int(_e_bar.max_value)]


# --- Signal handlers connected in the editor ------------------------------------------------------
func _on_guard_1_hp_changed(current_hp: int, max_hp: int) -> void:
	_update_bar_and_label(_p_bar, _p_label, current_hp, max_hp)

func _on_enemy_guard_red_hp_changed(current_hp: int, max_hp: int) -> void:
	_update_bar_and_label(_e_bar, _e_label, current_hp, max_hp)

# If you added VIP UI, you can hook this up too
func _on_vip_hp_changed(current_hp: int, max_hp: int) -> void:
	if _vip_bar and _vip_label:
		_update_bar_and_label(_vip_bar, _vip_label, current_hp, max_hp)


# --- Helpers --------------------------------------------------------------------------------------
func _update_bar_and_label(bar: ProgressBar, label: Label, current_hp: int, max_hp: int) -> void:
	if not bar or not label:
		return
	# Update bar first
	bar.max_value = max(1, max_hp)  # avoid 0 max
	bar.value = clamp(current_hp, 0, max_hp)
	# Then label text
	label.text = "HP: %d/%d" % [current_hp, max_hp]
