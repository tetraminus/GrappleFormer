extends Node

var loadedlevel = null
var LevelPath = ""
var playerprefab = preload("res://player.tscn")

signal LevelLoaded
signal PlayerLoaded




func GoToLevel(player: Node2D, prevLevel: Node2D) -> void:
	# level should be loaded by now
	player.get_parent().remove_child(player)
	prevLevel.queue_free()
	var level

	if loadedlevel != null:
		level = loadedlevel.instantiate()
		add_level(level)
	elif ResourceLoader.load_threaded_get_status(LevelPath) == ResourceLoader.THREAD_LOAD_LOADED or ResourceLoader.load_threaded_get_status(LevelPath) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		level = ResourceLoader.load_threaded_get(LevelPath)
		level = level.instantiate()
		add_level(level)
	else:
		print("Level not loaded, Aborting")
		var spawnpoint = get_tree().get_first_node_in_group("PlayerSpawn")
		player.set_position(spawnpoint.get_position())
		return
	
	
	#queue_free prevLevel except for player
	

	# add player to new level
	

	
	level.position = Vector2(0,0)

	add_player.call_deferred(level, player, prevLevel)

	
	
	
	

func add_player(level, player, prevLevel):
	var spawnpoint = get_tree().get_nodes_in_group("PlayerSpawn")
	for i in spawnpoint:
		print(i.get_name())
		if !prevLevel.is_ancestor_of(i):
			spawnpoint = i
			break
		else:
			spawnpoint = null
	level.add_child(player)
	PlayerLoaded.emit()
	if spawnpoint == null:
		print("No spawnpoint found, defaulting to 0,0")
		player.global_position = Vector2(0,0)
	else:
		player.global_position = spawnpoint.global_position

func add_level(level):
	get_tree().get_root().add_child.call_deferred(level)
	level.set_name("Level")
	loadedlevel = null
	LevelPath = ""

func LoadLevel(levelname: String) -> void:
	loadedlevel = null
	print("Loading level: " + levelname)
	LevelPath = "res://Rooms/"+ levelname + ".tscn"

	#test if file exists
	if ResourceLoader.exists(LevelPath):
		ResourceLoader.load_threaded_request(LevelPath, "PackedScene")
		print("requested load of: " + LevelPath)
	else:
		print("Level not found: " + LevelPath)
		LevelPath = ""
		return

func _process(delta):

	#fail safe if player doesn't exist
	if get_tree().get_first_node_in_group("Player") == null:
		var player = playerprefab.instantiate()
		get_tree().get_root().add_child(player)
		player.set_name("Player")
		
		var spawnpoint = get_tree().get_first_node_in_group("PlayerSpawn")
		if spawnpoint:
			player.set_position(spawnpoint.get_position())
			print("Player spawned")
			PlayerLoaded.emit()
		return
		
	

	if LevelPath != "" and ResourceLoader.load_threaded_get_status(LevelPath) == ResourceLoader.THREAD_LOAD_LOADED and loadedlevel == null:
		loadedlevel = ResourceLoader.load_threaded_get(LevelPath)
		LevelLoaded.emit()
		print("Level loaded: " + LevelPath)
		
	
