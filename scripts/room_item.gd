extends Control

@onready var nameLabel=$Name
@onready var subLabel=$Sublabel
var id:String="Unknown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_data(name: String, _id: String, sub: String):
	nameLabel.text=name
	id=_id
	subLabel.text=sub



func _on_join_button_pressed() -> void:
	Globals.room_id=id
	get_tree().change_scene_to_file("res://scenes/mainGame.tscn")
