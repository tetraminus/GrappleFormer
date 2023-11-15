extends Area2D

@export var levelName: String





func _ready():
	SceneTransitionManager.LoadLevel(levelName)
	body_entered.connect(_body_entered)


func _body_entered(body):
	if body.is_in_group("Player"):
		SceneTransitionManager.GoToLevel(body, get_tree().get_first_node_in_group("Level"))

