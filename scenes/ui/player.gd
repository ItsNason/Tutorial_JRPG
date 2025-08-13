extends AnimatedSprite2D

@export var attack_animation: String = "attack"
@export var idle_animation: String = "idle"
@onready var button: Button = $"../Button"

func _ready():
	play(idle_animation)
	# Connect the button's pressed signal
	var button = get_node("../Button") # adjust path if needed
	button.pressed.connect(_on_button_pressed)
	# Connect the AnimatedSprite2D's own animation_finished signal
	animation_finished.connect(_on_animation_finished)

func _on_button_pressed():
	play(attack_animation)

func _on_animation_finished():
	if animation == attack_animation:
		play(idle_animation)
