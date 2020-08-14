extends Node
class_name Core

const path = "res://quests/ru/"
const QuestWindow = preload("./QuestWindow.tscn")

static func get_files(path_, ext):
	var ret_val = []
	var dir = Directory.new()
	if dir.open(path_) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and \
			file_name.get_extension().to_lower() in ext:
				ret_val.append(file_name)
			file_name = dir.get_next()
	return ret_val
