extends Node

func _ready():
	print('world ready')
	
func _process(delta):
	pass
	
func add_player(player):
	player.transform.origin = Vector3(rand(-15, 15), rand(10, 50), rand(-15, 15))
	self.get_node("players").call_deferred("add_child", player)
	
func remove_player(id):
	self.get_node("players").get_node(str(id)).queue_free()

func rand(a, b):
	randomize()
	return rand_range(a, b)
