extends Node

const SQLite  = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
const DB_PATH = "user://PlayerData"
var Players
var PlayerInventories
var query

#TREES
const OAK_TREE = "O"

#ORES
const GOLD_ORE = "G"
const SILVER_ORE = "S"
const TIN_ORE = "T"

const TYPE = "T"
const HITS_HP = "H"
const CURRENT_HITS = "C"
const RESPAWN = "R"
const ACTIVE = "A"

#ENEMIES
const ENEMY_TYPE = "T"
const ENEMY_LOCATION = "L"
const ENEMY_CURRENT_HEALTH = "H"
const ENEMY_MAX_HEALTH = "M"
const ENEMY_STATE = "S"
const ENEMY_TIME_OUT = "O"

#WORLD STATE
const TIMESTAMP = "T"
const ENEMIES = "E"
const ORES = "O"

#PLAYER
const PLAYER_ANIMATION_VECTOR = "A"
const PLAYER_POSITION = "P"
const PLAYER_TIMESTAMP = "T"


var woodcutting_data = {
	"T1":{ #tree node
		TYPE: OAK_TREE, #type
		HITS_HP: 3, #hits to CUT
		CURRENT_HITS: 0, #current hits
		RESPAWN: 5, #respawn
		ACTIVE: 1 #active
	}
}

var mining_data = {
	"O1":{ #Gold
		TYPE: GOLD_ORE, #type
		HITS_HP: 3, #hits to mine
		CURRENT_HITS: 0, #current hits
		RESPAWN: 5, #respawn
		ACTIVE: 1 #active
	},
	"O2":{
		TYPE: SILVER_ORE,
		HITS_HP: 3,
		CURRENT_HITS: 0,
		RESPAWN: 5,
		ACTIVE: 1
	},
	"O3":{
		TYPE: TIN_ORE,
		HITS_HP: 3,
		CURRENT_HITS: 0,
		RESPAWN: 5,
		ACTIVE: 1
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


