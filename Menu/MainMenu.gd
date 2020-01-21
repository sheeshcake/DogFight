extends Node2D

var ip = ""
var host


func find_and_display_ip_addr():
	for address in IP.get_local_addresses():
		if "192.168" in address:
			ip += address
			return

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")

func _player_connected(id):
	globals.Players += 1
	globals.otherPlayerId = id
	find_and_display_ip_addr()

sync func ready_player():
	$Ready.disabled = true
	globals.PlayersReady += 1


func _on_HostLobby_pressed():
	print("Hosting network")
	$Ready.hide()
	globals.player_type = "Host"
	host = NetworkedMultiplayerENet.new()
	var res = host.create_server(8080,2)
	globals.PlayerName = $NickName.text
	if res != OK:
		print("Error creating server")
		return

	$JoinLobby.hide()
	$HostLobby.disabled = true
	get_tree().set_network_peer(host)
	if (get_tree().is_network_server()):
		find_and_display_ip_addr()
		$Label3.text = "Your Ip Address is: " + ip
	$Start.disabled = true


func _on_JoinLobby_pressed():
	print("Joining network")
	globals.PlayerName = $NickName.text
	globals.player_type = "Client"
	host = NetworkedMultiplayerENet.new()
	host.create_client($IpAddress.text,8080)
	get_tree().set_network_peer(host)
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_recieved")
	$Ready.disabled = false
	$Start.hide()
	$Label3.set_text("Connected!!! to " + ip)
	$HostLobby.hide()
	$JoinLobby.disabled = true


func _process(delta):
	if str(globals.Players) == str(globals.PlayersReady):
		$Start.disabled = false



func _on_Start_pressed():
	
	#Game on!
	print(globals.PlayersReady , " " , globals.Players)
	if globals.Players == globals.PlayersReady:
		get_tree().multiplayer.send_bytes("Game!".to_ascii())
		var game = preload("res://Map/Map1.tscn").instance()
		get_tree().get_root().add_child(game)
		hide()
	
func _on_packet_recieved(id, packet):
	if str(id) != str(host.get_unique_id()):
		var game = preload("res://Map/Map1.tscn").instance()
		get_tree().get_root().add_child(game)
		hide()

func _on_Ready_pressed():
	var id = get_tree().get_network_unique_id()
	rpc("ready_player")
	pass