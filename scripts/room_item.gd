extends Control

@onready var nameLabel=$Name
@onready var subLabel=$Sublabel
var id:String="Unknown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func loadData(name: String, _id: String, sub: String):
	nameLabel.text=name
	id=_id
	subLabel.text=sub

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
