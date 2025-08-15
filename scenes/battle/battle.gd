extends Node2D

@onready var player: Node2D = $Actors/Player
@onready var enemy: Node2D = $Actors/Enemy
@onready var hud: Node2D = $HUDLayer/HUD


func _ready() -> void:
	# Connect HUD -> Battle using a signal (decoupled)
	hud.action_selected.connect(_on_action)
	
func _on_action(action: String) -> void:
	match action:
		"attack":
			if player.has_method("play_attack"):
				player.play_attack()
								
			print("Player attacked")
		"skill":
			print("Player used (stub)")
		"item":
			print("Player used (stub)")
		"guard":
			print("Player guarded")
