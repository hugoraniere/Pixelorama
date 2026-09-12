extends ScrollContainer
## Content panel for the AI Tools dock. Lists the current category's tools
## (from AIToolsData) as ToolCard entries and opens the generate form when
## one is pressed.

const TOOL_CARD_TSCN := preload("res://src/UI/AIToolsPanel/ToolCard.tscn")

@onready var content: VBoxContainer = %Content
@onready var generate_form_dialog: ConfirmationDialog = %GenerateFormDialog


func _ready() -> void:
	AIToolsData.active_category_changed.connect(_populate)
	_populate(AIToolsData.active_category)


func _populate(category_id: String) -> void:
	for child in content.get_children():
		child.queue_free()
	for tool_info in AIToolsData.get_tools(category_id):
		var card: ToolCard = TOOL_CARD_TSCN.instantiate()
		content.add_child(card)
		card.set_info(tool_info["id"], tool_info["title"], tool_info["description"])
		card.tool_pressed.connect(_on_tool_pressed)


func _on_tool_pressed(tool_id: String) -> void:
	var tool_info := AIToolsData.find_tool(tool_id)
	generate_form_dialog.open_for_tool(tool_id, tool_info.get("title", tool_id))
