class_name ToolCard
extends Button
## A single clickable tool entry in the AI Tools content panel. Modeled on
## ExtensionEntry.tscn's card, with a short Label description instead of a
## read-only TextEdit, and the whole card (a flat Button) as the click
## target instead of an inner button.

signal tool_pressed(tool_id: String)

var tool_id := ""

@onready var title_label: Label = %Title
@onready var description_label: Label = %Description


func _ready() -> void:
	pressed.connect(func() -> void: tool_pressed.emit(tool_id))


func set_info(id: String, title: String, description: String) -> void:
	tool_id = id
	title_label.text = title
	description_label.text = description
