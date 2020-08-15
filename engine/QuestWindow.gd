extends Node2D

var quest: = {}
var states: = {}
var _current_state_key: = ""
var current_state: = {}
var actions: = []
var vars: = {}

func _ready():
	if not quest.has("states"):
		$Text.bbcode_text = \
		"[color=#ff0000]The quest doesn't have 'states' property[/color]"
		return
	states = quest["states"]
	if not quest.has("start"):
		$Text.bbcode_text = \
		"[color=#ff0000]The quest start state isn't set[/color]"
		return
	set_state(quest["start"])

func set_state(state_: String):
	_current_state_key = state_
	if not states.has(_current_state_key):
		$Text.bbcode_text = \
		"[color=#ff0000]The quest doesn't have state '%s'[/color]" \
		% state_
		return
	current_state = states[_current_state_key]
	process_state()

func process_state():
	fill_text()
	fill_actions()

func fill_text():
	if not current_state.has("text"):
		$Text.bbcode_text = \
		"[color=#ff0000]State '%s' doesn't have text[/color]" % _current_state_key
		return
	$Text.bbcode_text = current_state["text"]

func fill_actions():
	$Actions.clear()
	if not current_state.has("actions"):
		$Text.bbcode_text = \
		"[color=#ff0000]State '%s' doesn't have actions[/color]" \
		% _current_state_key
		return
	actions = core.as_array(current_state["actions"])
	for action in actions:
		if core.condition_met(action, vars):
			if not action.has("text"):
				$Text.bbcode_text = \
				"[color=#ff0000]Action in state '%s' doesn't have text[/color]" \
				% _current_state_key
				return
			if not action.has("results"):
				$Text.bbcode_text = \
				"[color=#ff9999]Action in state '%s' doesn't have results[/color]" \
				% _current_state_key
				return
			$Actions.add_item(action["text"])

func process_action(index):
	var results = core.as_array(actions[index]["results"])
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
		$Text.bbcode_text = \
		"[color=#ff9999]Action in state '%s' doesn't have possible results[/color]" \
		% _current_state_key
		return
	var r = randi() % int(sum)
	for i in range(0, len(weights)):
		if r < weights[i]:
			process_result(possible_results[i])
			return

func process_result(result):
	process_vars(result)
	if not result.has("next"):
		$Text.bbcode_text = \
		"[color=#ff9999]Action result in state '%s' doesn't have next state[/color]" \
		% _current_state_key
	set_state(result["next"])

func process_vars(result):
	if not result.has("vars"):
		return
	var vs = result["vars"]
	if vs is Dictionary:
		if not vs.has("var"):
			for v in vs:
				if v != "":
					vars[v] = core.fill_and_evaluate(vs[v], vars)
			return
		else:
			vs = [vs]
	for v in vs:
		if not core.condition_met(v, vars):
			continue
		if not core.probability_rolls(v):
			continue
		if (not v.has("var")) or (not v.has("value")):
			$Text.bbcode_text = \
			"[color=#ff9999]Action result in state '%s' has error in vars[/color]" \
			% _current_state_key
			return
		vars[v["var"]] = core.fill_and_evaluate(v["value"], vars)
