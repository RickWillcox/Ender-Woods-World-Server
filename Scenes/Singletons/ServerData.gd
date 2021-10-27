extends Node

const SQLite  = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
const DB_PATH = "user://PlayerData"
var Players
var PlayerInventories
var query
var si = ServerInterface


var woodcutting_data = {
	"T1":{ #tree node
		si.TYPE: si.OAK_TREE, #type
		si.HITS_HP: 3, #hits to CUT
		si.CURRENT_HITS: 0, #current hits
		si.RESPAWN: 5, #respawn
		si.ACTIVE: 1 #active
	}
}

var mining_data = {
	"O1":{ #Gold
		si.TYPE: si.GOLD_ORE, #type
		si.HITS_HP: 3, #hits to mine
		si.CURRENT_HITS: 0, #current hits
		si.RESPAWN: 5, #respawn
		si.ACTIVE: 1 #active
	},
	"O2":{
		si.TYPE: si.SILVER_ORE,
		si.HITS_HP: 3,
		si.CURRENT_HITS: 0,
		si.RESPAWN: 5,
		si.ACTIVE: 1
	},
	"O3":{
		si.TYPE: si.TIN_ORE,
		si.HITS_HP: 3,
		si.CURRENT_HITS: 0,
		si.RESPAWN: 5,
		si.ACTIVE: 1
	}
}


func _ready():
	pass
		
func RefreshPlayers():
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	db.query("select * from Players")
	Players = db.query_result
	print(Players)

func RefreshPlayerInventories():
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	db.query("select * from PlayerInventories")
	PlayerInventories = db.query_result 
	
func query():
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
#	db.query("select * from Players left join PlayerInventories on Players.id = PlayerInventories.player_id where Players.player_name = 'rick'")
	db.query("select player_name from Players")
	query = db.query_result


