extends Control

signal kickme

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Kick.visible=false
	$NoNet.visible=false

func set_net(ol: bool) -> void:
	$NoNet.visible=not ol

func set_kickable(b: bool):
	$Kick.visible=b

func set_life(life: int):
	$HP.text=str(life)
	
func set_data(username: String, hp: int, online: bool) -> void:
	$Username.text=username
	$HP.text=str(hp)
	$NoNet.visible=not online
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_kick_pressed() -> void:
	emit_signal("kickme",$Username.text)
