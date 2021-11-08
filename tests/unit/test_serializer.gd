extends "res://addons/gut/test.gd"

func test_serialize_deserialize_int64():
	var packet_bundle = Serializer.PacketBundle.new()
	for i in range(30):
		var x = int(pow(2, i))
		packet_bundle.serialize_int_64(x)
		var y = packet_bundle.deserialize_int_64()
		assert_eq(x, y)

func test_serialize_simple_packets():
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK }]
	packet_bundle.serialize_packets(packets)
	var packets2 = packet_bundle.deserialize_packets()
		
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])

func test_serialize_complex_packets():
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 100000000,
					  "attacker" : 2021},
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 4 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 80 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 30 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 3,
					  "attacker" : 2021}]
	packet_bundle.serialize_packets(packets)
	var packets2 = packet_bundle.deserialize_packets()
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		
func test_serialize_send_data_only():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 100000000,
					  "attacker" : 2021},
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 4 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 80 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 30 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 3,
					  "attacker" : 2021}]
	packet_bundle.serialize_packets(packets)
	
	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets()
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])

func test_compress_and_serialize():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 100000000,
					  "attacker" : 2021},
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 4 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 80 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_OK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.REMOVE_ITEM, "item_name": 30 },
					{ "op_code": ServerInterface.Opcodes.INVENTORY_NOK },
					{ "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 3,
					  "attacker" : 2021}]
	packet_bundle.serialize_packets(packets)
	
	var original_size = packet_bundle.buffer.size()
	# compress the buffer
	packet_bundle.compress()
	var bytes = packet_bundle.buffer
	packet_bundle.free()
	_lgr.log("Compare size: %d > %d" % [original_size, bytes.size()])
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = bytes
	new_packet_bundle.decompress(original_size)
	
	var packets2 = new_packet_bundle.deserialize_packets()
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		

func test_serialize_one():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [{  "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 3,
					  "attacker" : 2021}]
	packet_bundle.serialize_packets(packets)

	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets()
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		


func test_serialize_two():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [{  "op_code": ServerInterface.Opcodes.TAKE_DAMAGE, 
					  "damage" : 3,
					  "attacker" : 2021},
					  {"op_code": ServerInterface.Opcodes.INVENTORY_NOK}]
	packet_bundle.serialize_packets(packets)

	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets()
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		

