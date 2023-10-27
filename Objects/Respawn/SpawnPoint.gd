extends Node2D

@export var default := false
# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(0).body_entered.connect(on_body_entered)
	if default:
		get_tree().call_group("Player", "SetSpawnpoint", self)

func on_body_entered(body):
	if body.is_in_group("Player"):
		(body as Player).SetSpawnpoint(self)

	
