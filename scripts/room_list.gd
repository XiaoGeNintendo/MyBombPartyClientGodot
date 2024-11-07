extends Control

@onready var http:=$HTTPRequest
var scene:=preload("res://scenes/roomItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()

func refresh():
	print("Refreshing...")
	$Refresh.disabled=true
	
	var url:String = Globals.build_http("rooms")
	
	#url="https://bomb.hellholestudios.top"
	print(url)
	http.request(url)
	
	# Remove Children
	for i in %RoomList.get_children():
		%RoomList.remove_child(i)
		i.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_new_room_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/createRoom.tscn")


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Finished")
	$Refresh.disabled=false
	if result==HTTPRequest.RESULT_SUCCESS and response_code==200:
		var json=JSON.parse_string(body.get_string_from_utf8())
		print(json)
		for i in json:
			var x=json[i]
			var obj=scene.instantiate()
			$"%RoomList".add_child(obj)
			
			var subtitle="ID: %s | %s | T %d R %d HP %d C %d"%[i,x["segments"],x["timeout"],x["rewardThreshold"],x["initialLife"],x["changeAfterFails"]]
			obj.load_data(x["name"],i,subtitle)
		
	else:
		$AcceptDialog.dialog_text="Internet Connection Failed with result %d and response code %d"%[result,response_code]
		$AcceptDialog.show()


func _on_refresh_pressed() -> void:
	refresh()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn")
