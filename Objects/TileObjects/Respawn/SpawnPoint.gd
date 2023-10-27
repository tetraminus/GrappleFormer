extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body.is_in_group("Player"):
		(body as Player).SetSpawnpoint(self)

	
