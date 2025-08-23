extends Control
signal action_selected(action: String)

@onready var attack_button: Button = $VBoxContainer/AttackButton
@onready var skill_button: Button = $VBoxContainer/SkillButton
@onready var item_button: Button = $VBoxContainer/ItemButton
@onready var guard_button: Button = $VBoxContainer/GuardButton
@onready var label: Label = %LogLabel
@onready var player_hp: Label = %PlayerHp
@onready var enemy_hp: Label = %EnemyHp
@onready var vip_hp: Label = %VIPHp



func _ready() -> void:
	attack_button.pressed.connect(func(): _emit("attack"))
	skill_button.pressed.connect(func(): _emit("skill"))
	item_button.pressed.connect(func(): _emit("item"))
	guard_button.pressed.connect(func(): _emit("guard"))
	
	
func _emit(name: String) -> void:
	emit_signal("action_selected", name)
	label.text = "Selected: %s" % name


func set_menu_enabled(on: bool) -> void:
	for b in [attack_button, skill_button, item_button, guard_button]:
		b.disabled = not on


func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	player_hp.text = "HP: %d/%d" % [current_hp, max_hp]
	
	
func _on_enemy_hp_changed(current_hp: int, max_hp: int) -> void:
	enemy_hp.text = "HP: %d/%d" % [current_hp, max_hp]


func _on_vip_hp_changed(current_hp: int, max_hp: int) -> void:
	vip_hp.text = "HP: %d/%d" % [current_hp, max_hp]
