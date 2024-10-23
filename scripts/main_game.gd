extends Control

var socket:=ModernWebSocket.new()
var first:=true
var room:GameRoom
var am_i_admin:=false
var user_scene=preload("res://scenes/user.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	socket.connect_to_url(Globals.build_url("join/"+Globals.room_id))
	socket.send(Globals.clientVersion)
	socket.send(Globals.username)
	
	socket.on_close=close
	socket.on_receive=receive
	$Loading.visible=true
	$Status.text=""

func updateArrow():
	$Arrow.visible=room.state==GameRoom.RUNNING
	
	if len(room.players)>0:
		$Arrow.rotation=2*PI*room.currentPlayer/len(room.players)+PI/2

func updateButtons():
	$StartButton.visible=am_i_admin and room.state!=GameRoom.RUNNING
	$CloseButton.visible=am_i_admin
	for i in $CenterRing.get_children():
		i.set_kickable(am_i_admin)

func updateLabel():
	if room.state==GameRoom.BEFORE_START:
		$Hint.visible=false
		$Timer.visible=false
	elif room.state==GameRoom.RUNNING:
		$Hint.visible=true
		$Timer.visible=true
	else:
		$Timer.visible=false
		$Hint.visible=true
		$Hint.text="Last Winner: "+room.winner+"!!"

func do_kick(username):
	socket.send("kick#"+username)

func initRoom():
	for i in $CenterRing.get_children():
		$CenterRing.remove_child(i)
		i.queue_free()
	
	for i in room.players:
		var obj=user_scene.instantiate()
		$CenterRing.add_child(obj)
		obj.set_data(i.name,i.life,i.online)
		obj.connect("kickme",do_kick)
		
	$Hint.text=room.currentSegment
	$RoomName.text=room.name
	%UsedWords.text="Used Words:\n"+"\n".join(room.usedWords)
	$Timer.text=str(room.timeLeft/10)
	am_i_admin=len(room.players)>=1 and room.players[0].name==Globals.username
	
	updateArrow()
	updateButtons()
	updateLabel()

func get_index_from_username(name: String) -> int:
	for i in range(len(room.players)):
		if name==room.players[i].name:
			return i
	return -1

func change_status(text: String, color: Color):
	$Status.text=text
	$Status.set("theme_override_colors/font_color",color)
	
func receive(str:String) -> void:
	if first:
		#serialization of game room
		var res=JSON.parse_string(str)
		room=GameRoom.from_dict(res)
		
		#print(res)
		#room=dict_to_inst(res)
		initRoom()
		first=false
		$Loading.visible=false
		return
	
	var cmd=str.split(" ")[0]
	var para=" ".join(str.split(" ").slice(1))
	print(cmd,"=",para)
	
	if cmd=="startRoom":
		room.currentPlayer=0
		room.timeLeft=room.timeout
		room.state=GameRoom.RUNNING
		room.usedWords.clear()
		for i in room.players:
			i.life=room.initialLife
		initRoom()
	elif cmd=="close":
		pass
	elif cmd=="countdown":
		room.timeLeft=int(para)
		$Timer.text=str(int(para)/10)
	elif cmd=="new_player":
		var pl=Player.new()
		pl.life=room.initialLife
		pl.name=para
		pl.online=true
		room.players.append(pl)
		
		var obj=user_scene.instantiate()
		$CenterRing.add_child(obj)
		obj.set_data(para,room.initialLife,true)
		obj.connect("kickme",do_kick)
		
		#reset is admin
		am_i_admin=len(room.players)>=1 and room.players[0].name==Globals.username
		updateButtons()
		
	elif cmd=="disconnect":
		var index=get_index_from_username(para)
		if index!=-1:
			room.players[index].online=false
			$CenterRing.get_child(index).set_net(false)
	elif cmd=="connect":
		var index=get_index_from_username(para)
		if index!=-1:
			room.players[index].online=true
			$CenterRing.get_child(index).set_net(true)
	elif cmd=="new_spectator":
		pass
	elif cmd=="type":
		change_status("%s is now typing: 「%s」"%[room.players[room.currentPlayer].name,para],Color.WHITE)
	elif cmd=="success":
		room.usedWords.append(para)
		%UsedWords.text+="\n"+para
		change_status("「%s」 is correct!"%para,Color.LAWN_GREEN)
	elif cmd=="fail":
		change_status("「%s」 is invalid!"%para,Color.DEEP_PINK)
	elif cmd=="used":
		change_status("「%s」 is already used!"%para,Color.ROSY_BROWN)
	elif cmd=="heal":
		var index=get_index_from_username(para)
		
		$HealParticle.position=$CenterRing.get_child(index).global_position
		$HealParticle.restart()
		
		room.players[index].life+=1
		$CenterRing.get_child(index).set_life(room.players[index].life)
	elif cmd=="loseLife":
		var index=get_index_from_username(para)
		
		$HurtParticle.position=$CenterRing.get_child(index).global_position-Vector2(32,41)
		$HurtParticle.restart()
		
		room.players[index].life-=1
		$CenterRing.get_child(index).set_life(room.players[index].life)
	elif cmd=="new":
		room.currentSegment=para
		$Hint.text=para
	elif cmd=="start":
		var index=get_index_from_username(para)
		room.currentPlayer=index
		updateArrow()
	elif cmd=="win":
		room.winner=para
		room.state=GameRoom.ENDED
		updateButtons()
		updateArrow()
		updateLabel()
	elif cmd=="kick":
		var index=get_index_from_username(para)
		var child=$CenterRing.get_child(index)
		room.players.remove_at(index)
		$CenterRing.remove_child(child)
		child.queue_free()
		
		am_i_admin=len(room.players)>0 and room.players[0].name==Globals.username
		updateArrow()
		updateButtons()
		
	else:
		print("Invalid command: ",cmd)
		assert(false)

func close(code, reason) -> void:
	$AcceptDialog.dialog_text="Server Connection Lost:\n %s(%d)"%[reason,code]
	$AcceptDialog.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#pass
	socket.poll()

func _on_accept_dialog_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/roomList.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/roomList.tscn")


func _on_start_button_pressed() -> void:
	socket.send("start")

func _on_close_button_pressed() -> void:
	socket.send("closeRoom")


func _on_input_text_changed(new_text: String) -> void:
	if len(new_text)<=50 and "#" not in new_text:
		socket.send("type#"+new_text)

func _on_input_text_submitted(new_text: String) -> void:
	if len(new_text)<=50 and "#" not in new_text:
		socket.send("confirm#"+new_text)
