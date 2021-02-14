extends Node

func _ready():
	print('world ready')
	
func _process(delta):
	pass
	
func add_player(player):
	self.get_node("players").add_child(player)
	
func remove_player(id):
	self.get_node("players").get_node(str(id)).queue_free()
