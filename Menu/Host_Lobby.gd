extends Node2D

var players = Array()
var count_players = 0

func _ready():
	var network = NetworkedMultiplayerENet.new()
	network.create_server(8080,10)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(id):
	$labelPlayers.text += str(id)
	$labelUserCount.text = "Total Players: " + str(get_tree().get_network_connected_peers().size())
	get_tree().multiplayer.send_bytes($labelUserCount.text.to_ascii())


func _peer_disconnected(id):
	var text = $labelPlayers.text.replace(str(id), "")
	$labelPlayers.text = text
	$labelUserCount.text = "Total Players: " + str(get_tree().get_network_connected_peers().size())

func _on_Start_pressed():
	get_tree().change_scene("res://Map/Map1.tscn")
