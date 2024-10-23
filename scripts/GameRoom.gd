class_name GameRoom

var name:String
var lang:String
var segments:String
var timeout:int
var rewardThreshold:int
var initialLife:int
var changeAfterFails:int
var players: Array[Player] = []
var spectators: Array[Player] = []
var usedWords: Array[String] = []
var currentPlayer:=0
var state:= "BEFORE_START"
var currentSegment:="?"
var currentFail:=0
var winner:=""
var timeLeft:=0

const BEFORE_START:="BEFORE_START"
const RUNNING:="RUNNING"
const ENDED:="ENDED"

static func from_dict(dict:Variant)->GameRoom:
	var x=GameRoom.new()
	if "players" not in dict:
		dict["players"]=[]
	if "spectators" not in dict:
		dict["spectators"]=[]
	if "usedWords" not in dict:
		dict["usedWords"]=[]
		
	for i in dict["players"]:
		var z=Player.new()
		for j in i:
			z[j]=i[j]
		x.players.append(z)
	for i in dict["spectators"]:
		var z=Player.new()
		for j in i:
			z[j]=i[j]
		x.spectators.append(z)
	for i in dict["usedWords"]:
		x.usedWords.append(i)
	
	dict.erase("players")
	dict.erase("spectators")
	dict.erase("usedWords")
	
	for i in dict:
		x[i]=dict[i]
	return x
	
