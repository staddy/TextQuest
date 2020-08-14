tool
extends EditorPlugin

var gui = null
var path = Core.path

func json_to_res():
	var files = Core.get_files(path, ["json"])
	for file_name in files:
		var file = File.new()
		file.open(path + file_name, File.READ)
		var content = file.get_as_text()
		file.close()
		var res = JSON.parse(content)
		if res.error == OK:
			var quest = Quest.new()
			quest.data = res.result
			ResourceSaver.save(path + file_name.get_basename() + \
			(".tres" if gui.get_node("CheckBox").pressed else ".res"), \
			quest, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS | \
			ResourceSaver.FLAG_COMPRESS)
		else:
			print("%d: %s" % [res.error_line, res.error_string])

func _enter_tree():
	gui = preload("./JSONConverterGUI.tscn").instance()
	gui.get_node("Convert").connect("pressed", self, "json_to_res")
	add_control_to_container(CONTAINER_PROPERTY_EDITOR_BOTTOM, gui)

func _exit_tree():
	remove_control_from_container(CONTAINER_PROPERTY_EDITOR_BOTTOM, gui)
