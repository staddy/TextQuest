extends Node2D

var quest: = {}
var states: = {}
var _current_state_key: = ""
var current_state: = {}
var actions: = []
var vars: = {}
var status: = []

func error(text: String):
	$Text.bbcode_text = "[color=#ff0000]ERROR\n"
	if not _current_state_key.empty():
		$Text.bbcode_text += ("State: '%s'\n" % _current_state_key)
	$Text.bbcode_text += (text + "[/color]")

func _ready():
	if not process_vars(quest):
		return
	if quest.has("status"):
		status = core.as_array(quest["status"])
	if not quest.has("states"):
		error("The quest doesn't have states")
		return
	states = quest["states"]
	if not quest.has("start"):
		error("The quest start state isn't set")
		return
	set_state(quest["start"])

func process_status():
	$Status.bbcode_text = ""
	for s in status:
		if s is String:
			$Status.bbcode_text += (core.fill_and_evaluate(s, vars) + "\n")
		elif s is Dictionary and s.has("text"):
			if core.condition_met(s, vars):
				$Status.bbcode_text += (core.fill_and_evaluate(s["text"], vars) + "\n")

func process_image():
	if current_state.has("image") and (current_state["image"] is String):
		if current_state["image"].empty():
			$Image.texture = null
		else:
			$Image.texture = load(core.path + current_state["image"])

func set_state(state_: String):
	_current_state_key = state_
	if not states.has(_current_state_key):
		error("The quest doesn't have the state")
		return
	current_state = states[_current_state_key]
	if not process_vars(current_state):
		return
	process_state()
	process_status()
	process_image()

func process_state():
	fill_text()
	fill_actions()

func fill_text():
	if not current_state.has("text"):
		error("The state doesn't have text")
		return
	$Text.bbcode_text = current_state["text"]

func fill_actions():
	$Actions.clear()
	if not current_state.has("actions"):
		error("The state doesn't have actions")
		return
	actions = core.as_array(current_state["actions"])
	for action in actions:
		if core.condition_met(action, vars):
			if not action.has("text"):
				error("An action doesn't have text")
				return
			if not action.has("results"):
				error("An action doesn't have results")
				return
			$Actions.add_item(action["text"])

func process_action(index):
	if not process_vars(actions[index]):
		return
	var results = core.as_array(actions[index]["results"])
	if results is String:
		set_state(results)
		return
	var possible_results = []
	var weights = []
	var sum = 0
	for result in results:
		if core.condition_met(result, vars):
			if (not result.has("weight")) or (result["weight"] == 0):
				process_result(result)
				return
			weights.append(sum + result["weight"])
			sum += result["weight"]
			possible_results.append(result)
	if len(possible_results) == 0:
		error("An action doesn't have possible results")
		return
	var r = randi() % int(sum)
	for i in range(0, len(weights)):
		if r < weights[i]:
			process_result(possible_results[i])
			return

func process_result(result):
	if not process_vars(result):
		return
	if not result.has("next"):
		error("An action result doesn't have next state")
		return
	set_state(result["next"])

func process_vars(result):
	if not result.has("vars"):
		return true
	var vs = result["vars"]
	if vs is Dictionary:
		if not vs.has("var"):
			for v in vs:
				if v != "":
					vars[v] = core.fill_and_evaluate(vs[v], vars)
			return true
		else:
			vs = [vs]
	for v in vs:
		if not core.condition_met(v, vars):
			continue
		if not core.probability_rolls(v):
			continue
		if (not v.has("var")) or (not v.has("value")):
			error("Error in vars")
			return false
		vars[v["var"]] = core.fill_and_evaluate(v["value"], vars)
	return true
