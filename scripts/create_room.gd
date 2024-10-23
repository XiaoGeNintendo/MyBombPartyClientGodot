extends Control

var socket:=ModernWebSocket.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()

func validate() -> String:
	if $Name.text=="":
		return "Please enter room name"
	return "OK"
	
func on_close(code, reason) -> void:
	if code==1000 and reason=="OK":
		get_tree().change_scene_to_file("res://scenes/roomList.tscn")
	else:
		if reason=="":
			reason="No Info"
		
		$AcceptDialog.dialog_text="Could not create room:\n%s(%d)"%[reason,code]
		$AcceptDialog.show()
		$Button.disabled=false

func _on_button_pressed() -> void:
	var res:=validate()
	if res!="OK":
		$AcceptDialog.dialog_text=res
		$AcceptDialog.show()
		return
	
	$Button.disabled=true
	
	var x:=GameRoomPreview.new()
	x.name=$Name.text
	x.lang=$Segment.text.substr(0,2)
	x.segments=$Segment.text
	x.playerCount=0
	x.timeout=$Timeout.value*10
	x.rewardThreshold=$RewardThreshold.value
	x.initialLife=$InitialLife.value
	x.changeAfterFails=$ChangeAfterFail.value
	x.state="BEFORE_START"
	
	socket.connect_to_url(Globals.build_url("createRoom"))
	socket.send(Globals.clientVersion)
	socket.send(Globals.to_json(x))
	socket.on_close=on_close


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/roomList.tscn")
