extends Node3D

var port = 9999
var address = "127.0.0.1"

func _ready():
	var network = ENetMultiplayerPeer.new()
	
	network.create_server(9999)
	network.create_client("127.0.0.1", 9999)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
