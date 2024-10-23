class_name ModernWebSocket

var socket:WebSocketPeer
var url:String
var sendQueue: Array[String]
## Accept one parameter with type string
var on_receive: Callable = null_func1
## Accept two parameters
var on_close: Callable = null_func2

var still_polling: bool=true

func null_func1(_a):
	pass

func null_func2(_a,_b):
	pass

func _init():
	socket=WebSocketPeer.new()

func get_state() -> WebSocketPeer.State:
	return socket.get_ready_state()

func connect_to_url(_url:String) -> Error:
	url=_url
	var res=socket.connect_to_url(url)
	still_polling=true
	print("WS: Connect to ",url, " with result ",res)
	return res

func send(text: String):
	sendQueue.append(text)

func poll():
	if socket==null or not still_polling:
		return
	
	socket.poll()
	var state=socket.get_ready_state()
	
	#print(state,socket.get_available_packet_count())
	#print(socket.get_packet_error())
	
	if state==WebSocketPeer.STATE_OPEN:
		for i in sendQueue:
			print("WS: Send packet ",i)
			socket.send_text(i)
		sendQueue.clear()
		
		while socket.get_available_packet_count():
			var s=socket.get_packet().get_string_from_utf8()
			print("WS: New packet ",s)
			on_receive.call(s)
	elif state==WebSocketPeer.STATE_CLOSED:
		print("WS: Closed with ",socket.get_close_code()," and reason ", socket.get_close_reason())
		on_close.call(socket.get_close_code(),socket.get_close_reason())
		
		still_polling=false
