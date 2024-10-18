class_name NewWebsocket

var socket:WebSocketPeer
var url:String
var sendQueue: Array[String]
var on_receive: Callable = null_func
var on_close: Callable = null_func

var still_polling: bool=true

func null_func():
	pass
func _init():
	socket=WebSocketPeer.new()

func get_state() -> WebSocketPeer.State:
	return socket.get_ready_state()

func connect_to_url(_url:String) -> Error:
	url=_url
	var res=socket.connect_to_url(url)
	still_polling=true
	return res

func send(text: String):
	sendQueue.append(text)

func poll():
	if socket==null or not still_polling:
		return
	
	socket.poll()
	
	var state=socket.get_ready_state()
	
	if state==WebSocketPeer.STATE_OPEN:
		for i in sendQueue:
			print("Send packet",i)
			socket.send_text(i)
		sendQueue.clear()
		
		while socket.get_available_packet_count():
			var s=socket.get_packet().get_string_from_utf8()
			print("New packet",s)
			on_receive.call(s)
	elif state==WebSocketPeer.STATE_CLOSED:
		on_close.call()
		still_polling=false
