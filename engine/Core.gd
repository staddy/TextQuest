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

static func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	var obj = Reference.new()
	obj.set_script(script)
	return obj.eval()

static func fill_and_evaluate(input, vars):
	return evaluate(fill_vars(str(input), vars))

static func fill_vars(input: String, vars: Dictionary):
	var ret_val = input
	for i in range(0, 2):
		for v in vars:
			ret_val = ret_val.replace("{" + v + "}", str(vars[v]))
	return ret_val

static func condition_met(object: Dictionary, vars: Dictionary):
	if (not object.has("condition")) or (object["condition"] == ""):
		return true
	return fill_and_evaluate(object["condition"], vars)

static func probability_rolls(object: Dictionary):
	if (not object.has("p")) or (object["p"] >= 1.0):
		return true
	return randf() < object["p"]

static func as_array(object):
	var ret_val = object
	if not (ret_val is Array):
		ret_val = [ret_val]
	return ret_val
