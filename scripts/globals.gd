extends Node

var username: String = "test_godot_"+str(randf())
var host: String = "bomb.hellholestudios.top"
var protocol: String = "wss"
var room_id: String = "4fa5fd80-b682-428f-8e6c-9c0644f1c27e"
const clientVersion = "4"

## Build protocol+host+route. You do not need to write /rooms. rooms is suffice.
func build_url(route:String)->String:
	return protocol+"://"+host+"/"+route

func build_http(route:String)->String:
	if protocol=="ws":
		return "http://"+host+"/"+route
	else:
		return "https://"+host+"/"+route

## Build dictionary without @path or @subpath
func to_dict_clean(x) -> Dictionary:
	var y=inst_to_dict(x)
	y.erase("@path")
	y.erase("@subpath")
	return y

func to_json(x) -> String:
	return JSON.stringify(to_dict_clean(x))
