extends Node2D

var files = []

func _ready():
	files = core.get_files(Core.path, ["res", "tres"])
	for file in files:
		$Quests.add_item(file)

func _on_Quests_item_activated(index):
	var quest_window = core.QuestWindow.instance()
	quest_window.quest = ResourceLoader.load(core.path + files[index]).data
	queue_free()
	get_tree().root.add_child(quest_window)
