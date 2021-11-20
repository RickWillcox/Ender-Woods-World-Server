extends "res://addons/gut/test.gd"

var si = ServerInterface
var packet_descriptor = Serializer.get_server_client_descriptor()

# a big list of packets to test correct serialization in a packet bundle
var test_packet_list = [ si.create_inventory_nok_packet(),
					si.create_inventory_ok_packet(),
					si.create_take_damage_packet(-2021, 3000, 100000000),
					si.create_inventory_ok_packet(),
					si.create_remove_item_packet(4),
					si.create_enemy_died_packet(-321312),
					si.create_inventory_ok_packet(),
					si.create_item_craft_nok_packet(),
					si.create_inventory_update_packet(10000, 0, 1),
					si.create_initial_inventory_packet(1, 1, 2, 3, 4, 5),
					si.create_inventory_ok_packet(),
					si.create_player_despawn_packet(23132),
					si.create_attack_swing_packet(-2000, 2000),
					si.create_remove_item_packet(80),
					si.create_item_craft_ok_packet(3, 323),
					si.create_enemy_died_packet(31231),
					si.create_player_despawn_packet(23132),
					si.create_inventory_ok_packet(),
					si.create_inventory_nok_packet(),
					si.create_inventory_nok_packet(),
					si.create_player_chat_packet(231, "rick HELLO WorLD ąłęęąśłą ąłęęąśłą ąłęęąśłą HELOOOL 98347191asd98723hdjw78h239onrfd79283hfd8923fsdf"),
					si.create_inventory_update_packet(10000, 0, 1),
					si.create_remove_item_packet(30),
					si.create_inventory_slot_update_packet(3, 13, 2),
					si.create_smelter_started_packet(),
					si.create_smelter_stopped_packet(),
					si.create_initial_inventory_packet(1, 1, 2, 3, 4, 5),
					si.create_inventory_nok_packet(),
					si.create_take_damage_packet(-2021, 3000, 3),
					si.create_attack_swing_packet(-2000, 2000),
					si.create_enemy_died_packet(-321312),
					si.create_enemy_died_packet(31231),
					si.create_player_chat_packet(231, "HELLO WorLD ąłęęąśłą ąłęęąśłą ąłęęąśłą HELOOOL 98347191083123123100097891283 3894758935dsdsfsdfsdf"),
					si.create_item_craft_nok_packet(),
					si.create_item_craft_ok_packet(3, 323)]

func test_serialize_string():
	var packet_bundle = Serializer.PacketBundle.new()
	var string = "ąłęęąśłą"
	packet_bundle.serialize_string(string)
	_lgr.log(packet_bundle.buffer.hex_encode())
	assert_eq(packet_bundle.deserialize_string(), string)

func test_serialize_deserialize_int64():
	var packet_bundle = Serializer.PacketBundle.new()
	for i in range(30):
		var x = int(pow(2, i))
		packet_bundle.serialize_int_64(x)
		var y = packet_bundle.deserialize_int_64()
		assert_eq(x, y)

func test_serialize_simple_packets():
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [ si.create_inventory_nok_packet(),
					si.create_inventory_ok_packet()]
	packet_bundle.serialize_packets(packets, packet_descriptor)
	var packets2 = packet_bundle.deserialize_packets(packet_descriptor)
		
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])

func test_serialize_complex_packets():
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = test_packet_list
	packet_bundle.serialize_packets(packets, packet_descriptor)
	var packets2 = packet_bundle.deserialize_packets(packet_descriptor)
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		
func test_serialize_send_data_only():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = test_packet_list
	packet_bundle.serialize_packets(packets, packet_descriptor)
	
	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets(packet_descriptor)
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])

func test_compress_and_serialize():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = test_packet_list
	packet_bundle.serialize_packets(packets, packet_descriptor)
	
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
	
	var packets2 = new_packet_bundle.deserialize_packets(packet_descriptor)
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		

func test_serialize_one():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [si.create_take_damage_packet(-2021, 3000, 3)]
	packet_bundle.serialize_packets(packets, packet_descriptor)

	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets(packet_descriptor)
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		


func test_serialize_two():
	
	# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [si.create_take_damage_packet(-2021, 3000, 3),
					si.create_inventory_nok_packet()]
	packet_bundle.serialize_packets(packets, packet_descriptor)

	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets(packet_descriptor)
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])
		

func test_serialize_attack_swing():
	# test serialization of the new packet
		# Server encodes the data
	var packet_bundle =  Serializer.PacketBundle.new()
	var packets = [si.create_attack_swing_packet(-2000, 2000),
					si.create_inventory_nok_packet()]
	packet_bundle.serialize_packets(packets, packet_descriptor)

	var bytes = packet_bundle.buffer
	packet_bundle.free()
	
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = bytes
	
	var packets2 = new_packet_bundle.deserialize_packets(packet_descriptor)
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])


func test_serialize_float():
	var packet_bundle = Serializer.PacketBundle.new()
	var x = 1.2456
	packet_bundle.serialize_float(x)
	
	var y = packet_bundle.deserialize_float()
	
	assert_almost_eq(x, y, 0.01)


func test_serialize_vec2():
	var packet_bundle = Serializer.PacketBundle.new()
	var x = Vector2(213.321321, 321312.322)	
	packet_bundle.serialize_vec2(x)
	
	var y = packet_bundle.deserialize_vec2()
	
	assert_almost_eq(x.x, y.x, 0.01)
	assert_almost_eq(x.y, y.y, 0.01)
	


func test_serialize_enemy_spawn():
	var packet_bundle = Serializer.PacketBundle.new()
	var packet = si.create_enemy_spawn_packet(1, 1, 3, 4, Vector2(23123.55, 23313.231235))
	packet_bundle.serialize_packet_into_bundle(packet, packet_descriptor)
	
	var res = packet_bundle.deserialize_packet_from_bundle(packet_descriptor)
	
	assert_almost_eq(res["position"].x, packet["position"].x, 0.01)
	assert_almost_eq(res["position"].y, packet["position"].y, 0.01)
	res.erase("position")
	packet.erase("position")
	assert_eq_deep(res, packet)

# test automatic serializer
func test_auto_serialization():
	var packet_bundle = Serializer.PacketBundle.new()
	var field_types = Serializer.PacketBundle.FieldType
	var input_packet_descriptor = {
		ServerInterface.Opcodes.INVENTORY_OK : [],
		ServerInterface.Opcodes.ENEMY_DIED: [{ "name" : "enemy_id", "type" : field_types.INT64 }]
	}	
		
	var packets = [si.create_inventory_ok_packet(),
					si.create_enemy_died_packet(32)]
	
	# automatic serialization
	for packet in packets:
		packet_bundle.serialize_int_8(packet["op_code"])
		packet_bundle._serialize_packet(packet, packet["op_code"], input_packet_descriptor)
		
	# Client reads it, allocates a new PacketBundle
	var new_packet_bundle = Serializer.PacketBundle.new()
	# perform decompression
	new_packet_bundle.buffer = packet_bundle.buffer
	
	var packets2 = []
	packets2.append(
		new_packet_bundle._deserialize_packet(
			new_packet_bundle.deserialize_int_8(), input_packet_descriptor))
	packets2.append(
		new_packet_bundle._deserialize_packet(
			new_packet_bundle.deserialize_int_8(), input_packet_descriptor))
	
	assert_eq(packets.size(), packets2.size())
	for i in range(packets.size()):
		assert_eq_deep(packets[i], packets2[i])


func test_serialize_player_spawn():
	var packet_bundle = Serializer.PacketBundle.new()
	var packet = si.create_player_spawn_packet(1, Vector2(23123.55, 23313.231235))
	packet_bundle.serialize_packet_into_bundle(packet, packet_descriptor)
	
	var res = packet_bundle.deserialize_packet_from_bundle(packet_descriptor)
	
	assert_almost_eq(res["position"].x, packet["position"].x, 0.01)
	assert_almost_eq(res["position"].y, packet["position"].y, 0.01)
	res.erase("position")
	packet.erase("position")
	assert_eq_deep(res, packet)


func test_stress():
	var packets = []
	for _x in range(100):
		packets.append_array(test_packet_list)
		
	_lgr.log("Testing serializing " + str(packets.size()) + " packets")
	var packet_bundle = Serializer.PacketBundle.new()
	var start = OS.get_ticks_usec()
	
	for packet in packets:
		packet_bundle.serialize_packet_into_bundle(packet, packet_descriptor)
	
	var end = OS.get_ticks_usec()
	
	_lgr.log("Serialization took " + str(float(end - start)/1000) + " msec")
	
	var original_size = packet_bundle.buffer.size()
	start = OS.get_ticks_usec()
	packet_bundle.compress()
	end = OS.get_ticks_usec()
	_lgr.log("Compare size: %d > %d" % [original_size, packet_bundle.buffer.size()])
	

	_lgr.log("Compression took " + str(float(end - start)/1000) + " msec")
	
	start = OS.get_ticks_usec()
	packet_bundle.decompress(original_size)
	end = OS.get_ticks_usec()

	_lgr.log("Decompression took " + str(float(end - start)/1000) + " msec")
	
	start = OS.get_ticks_usec()
	var packets2 = packet_bundle.deserialize_packets(packet_descriptor)
	end = OS.get_ticks_usec()
	
	_lgr.log("Deserialization took " + str(float(end - start)/1000) + " msec")
	
	assert_eq_deep(packets, packets2)
	
