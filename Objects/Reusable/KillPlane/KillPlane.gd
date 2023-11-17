extends Node2D
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	await SceneTransitionManager.PlayerLoaded
	player = get_tree().get_first_node_in_group("Player") as Player



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		if player.global_position.y > global_position.y:
			player.die()
	else:
		player = get_tree().get_first_node_in_group("Player") as Player
		
