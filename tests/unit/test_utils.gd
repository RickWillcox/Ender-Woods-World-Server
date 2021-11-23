extends "res://addons/gut/test.gd"

# Integer keys represented as floats or strings should be converted to int
func test_convert_dict_keys_string_float():
	var dict : Dictionary = { 2.0 : "word", "2" : "word"}
	Utils.convert_keys_to_int(dict)
	for key in dict.keys():
		assert_eq(typeof(key), TYPE_INT)
	

# float values that can be represented as integers are converted
func test_convert_dict_values_float():
	var dict : Dictionary = { 2.0 : 4.0 }
	Utils.convert_keys_to_int(dict)
	for key in dict.keys():
		assert_eq(typeof(key), TYPE_INT)
	assert_eq(typeof(dict[2]), TYPE_INT)


# Float values that have decimal part arent converted
func test_convert_dict_values_float_no_conversion():
	var dict : Dictionary = { 2.0 : 4.5 }
	Utils.convert_keys_to_int(dict)
	for key in dict.keys():
		assert_eq(typeof(key), TYPE_INT)
	assert_eq(typeof(dict[2]), TYPE_REAL)


# Nested dictionaries should also be converted
func test_convert_dict_nested_dicts():
	var dict : Dictionary = {
		2.0 : {
			"2": 4.5,
			3.0 : {
				"5" : 4.0
			}
		},
		"5" : {
			4 : 10.0
		}
	}
	Utils.convert_keys_to_int(dict)
	
	var expected_dict : Dictionary = {
		2 : {
			2 : 4.5,
			3 : {
				5 : 4
			}
		},
		5 : {
			4 : 10
		}
	}
	
	assert_eq_deep(dict, expected_dict)


func test_convert_dict_invalid_string():
	var dict : Dictionary = {
		"wd" : 2.0
	}
	Utils.convert_keys_to_int(dict)
	
	var expected_dict : Dictionary = {
		"wd" : 2
	}
	
	assert_eq_deep(dict, expected_dict)
