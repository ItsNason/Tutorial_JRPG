extends Node2D
signal action_selected(action: String)

@onready var attack_button: Button = $VBoxContainer/AttackButton
@onready var skill_button: Button = $VBoxContainer/SkillButton
@onready var item_button: Button = $VBoxContainer/ItemButton
@onready var guard_button: Button = $VBoxContainer/GuardButton
@onready var label: Label = $Label

func _ready() -> void:
	attack_button.pressed.connect(func(): _emit("attack"))
	skill_button.pressed.connect(func(): _emit("Skill"))
	item_button.pressed.connect(func(): _emit("Item"))
	guard_button.pressed.connect(func(): _emit("guard"))
	
func _emit(name: String) -> void:
	emit_signal("action_selected", name)
	label.text = "Selected: %s" % name
