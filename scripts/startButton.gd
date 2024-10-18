extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var username:String=get_node("../Username").text
	var host:String=get_node("../Host").text
	var wss:bool=get_node("../CheckBox").button_pressed
	
	if username=="" or host=="":
		var menu:AcceptDialog=$"../../PopupMenu"
		menu.show()
	else:
		Globals.host=host
		Globals.username=username
		if wss:
			Globals.protocol="wss"
		else:
			Globals.protocol="ws"
		get_tree().change_scene_to_file("res://scenes/roomList.tscn")
