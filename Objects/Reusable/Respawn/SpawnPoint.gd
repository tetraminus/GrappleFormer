extends Area2D

@export var default:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)
	if default:
		await SceneTransitionManager.PlayerLoaded
		get_tree().get_first_node_in_group("Player").SetSpawnpoint(self)

func on_body_entered(body):
	if body.is_in_group("Player"):
		(body as Player).SetSpawnpoint(self)

	
 
