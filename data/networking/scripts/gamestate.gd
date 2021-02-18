extends Node

# NETWORK DATA
# Port Tip: Check the web for available ports that is not preoccupied by other important services
# Port Tip #2: If you are the server; you may want to open it (NAT, Firewall)
const SERVER_PORT = 31416
const MAX_PLAYERS = 30
const DEFAULT_SERVER_PLAYER_NAME = "SERVER"

# GAMEDATA
var world
var players = {} # Dictionary containing player names and their ID
var player_name # Your own player name

onready var player_scene = load("res://data/entities/player/player.tscn")
onready var camera_scene = load("res://data/entities/player/camera.tscn")

# SIGNALS to Main Menu (GUI)
signal refresh_lobby()
signal server_ended()
signal server_error()
signal connection_success()
signal connection_fail()

# Join a server
func join_game(name, ip_address):
	OS.set_window_title("CLIENT")
	print("join_game")
	# Store own player name
	player_name = name
	
	# Initializing the network as server
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip_address, SERVER_PORT)
	get_tree().set_network_peer(host)

# Host the server
func host_game():
	OS.set_window_title("SERVER")
	print("host_game")
	# Store own player name
	player_name = DEFAULT_SERVER_PLAYER_NAME
	
	# Initializing the network as client
	var host = NetworkedMultiplayerENet.new()
	var err = host.create_server(SERVER_PORT, MAX_PLAYERS) # Max 6 players can be connected
	if (err != OK):
		return
	get_tree().set_network_peer(host)

func _ready():
	print("_ready")
	# Networking signals (high level networking)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Client connected with you (can be both server or client)
func _player_connected(id):
	print("_player_connected")
	pass

# Client disconnected from you
func _player_disconnected(id):
	print("_player_disconnected")
	# If I am server, send a signal to inform that an player disconnected
	unregister_player(id)
	rpc("unregister_player", id)

# Successfully connected to server (client)
func _connected_ok():
	print("_connected_ok")
	# Send signal to server that we are ready to be assigned;
	# Either to lobby or ingame
	rpc_id(1, "user_ready", get_tree().get_network_unique_id(), player_name)
	pass

# Server receives this from players that have just connected
remote func user_ready(id, player_name):
	print("user_ready")
	# Only the server can run this!
	if(get_tree().is_network_server()):
		rpc_id(id, "register_in_game")

# Register yourself directly ingame
remote func register_in_game():
	print("register_in_game")
	rpc("register_new_player", get_tree().get_network_unique_id(), player_name)
	register_new_player(get_tree().get_network_unique_id(), player_name)

# Could not connect to server (client)
func _connected_fail():
	print("_connected_fail")
	get_tree().set_network_peer(null)
	emit_signal("connection_fail")

# Server disconnected (client)
func _server_disconnected():
	print("_server_disconnected")
	quit_game()
	emit_signal("server_ended")

# Register the player and jump ingame
remote func register_new_player(id, name):
	print("register_new_player")
	# This runs only once from server
	if(get_tree().is_network_server()):
		# Send info about server to new player
		rpc_id(id, "register_new_player", 1, player_name) 
		
		# Send the new player info about the other players
		for peer_id in players:
			rpc_id(id, "register_new_player", peer_id, players[peer_id]) 
	
	# Add new player to your player list
	players[id] = name
	
	spawn_player(id) 

# Register player the ol' fashioned way and refresh lobby
remote func register_player(id, name):
	print("register_player")
	# If I am the server (not run on clients)
	if(get_tree().is_network_server()):
		rpc_id(id, "register_player", 1, player_name) # Send info about server to new player
		
		# For each player, send the new guy info of all players (from server)
		for peer_id in players:
			rpc_id(id, "register_player", peer_id, players[peer_id]) # Send the new player info about others
			rpc_id(peer_id, "register_player", id, name) # Send others info about the new player
	
	players[id] = name # update player list

	# Notify lobby (GUI) about changes
	emit_signal("refresh_lobby")

# Unregister a player, whether he is in lobby or ingame
remote func unregister_player(id):
	print("unregister_player")
	world.remove_player(id)
	players.erase(id)
	emit_signal("refresh_lobby")

# Returns a list of players (lobby)
func get_player_list():
	return players.values()

# Returns your name
func get_player_name():
	return player_name

# Quits the game, will automatically tell the server you disconnected; neat.
func quit_game():
	print("quit_game")
	get_tree().set_network_peer(null)
	players.clear()

func start_game():
	print("start_game")
	spawn_player(1)
	pass

remote func spawn_player(id):
	print("spawn_player " + str(id))
	
	# If your game have already started, we get the current reference, 
	# else we create our instance and add it to root
	if(world == null):
		world = load("res://data/world/world.tscn").instance()
		get_tree().get_root().call_deferred("add_child", world)
		get_tree().get_root().get_node("main_menu").hide() # Away with the menu! AWAY I SAY!
#		world.get_node("hud/stats/name").set_text(player_name) # TODO
	
	# Create player instance
	var player = player_scene.instance()
	# Set Player ID as node name - Unique for each player!
	player.set_name(str(id))
	player.player_id = id
		
	# If the new player is you
	if (id == get_tree().get_network_unique_id()):
#		# Set as master on yourself
#		player.set_network_master(id)
#		player.control = true
		player.call_deferred("add_child", camera_scene.instance()) # Add camera to your player
	
	# Add the player (or you) to the world!
	world.add_player(player)

func rand(i):
	return randi() % i + 1
