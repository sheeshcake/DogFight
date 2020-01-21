extends Node2D

var other_name = ""


func _ready():
  #First create ourself
	var thisPlayer = preload("res://Player/Player.tscn").instance()
	thisPlayer.set_label_name(globals.PlayerName)
	var tar_pos = thisPlayer.get_node("Target").position
	if globals.player_type == "Host":
		thisPlayer.setPosition($Host.position,"right",tar_pos)
	else:
		thisPlayer.setPosition($Client.position,"left",tar_pos)
	thisPlayer.set_this_camera(true)
	thisPlayer.set_name(str(get_tree().get_network_unique_id()))
	thisPlayer.set_network_master(get_tree().get_network_unique_id())
	add_child(thisPlayer)
  
  #Now create the other player
	var otherPlayer = preload("res://Player/Player.tscn").instance()
	otherPlayer.set_name(str(globals.otherPlayerId))
	tar_pos = otherPlayer.get_node("Target").position
	if globals.player_type == "Host":
		otherPlayer.setPosition($Host.position, "right",tar_pos)
	else:
		otherPlayer.setPosition($Client.position,"left",tar_pos)
	otherPlayer.set_this_camera(false)
	otherPlayer.set_network_master(globals.otherPlayerId)
	add_child(otherPlayer)

