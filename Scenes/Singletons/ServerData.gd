extends Node
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


