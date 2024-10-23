extends Container

	
func _on_sort_children() -> void:
	print("Sorting ",get_child_count()," children!")
	if get_child_count()==0:
		return
	var angle_delta=2*PI/get_child_count()
	const RADIUS = 100
	
	var count=0
	for child in get_children():
		var x=cos(angle_delta*count)*RADIUS
		var y=sin(angle_delta*count)*RADIUS
		child.position=Vector2(x,y)
		count+=1
	
