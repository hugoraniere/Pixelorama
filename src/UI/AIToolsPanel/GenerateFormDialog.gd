extends ConfirmationDialog
## Simple generate form for the AI Tools dock. The actual generation call is
## isolated in AIGenerationClient.generate() so it can be swapped for a real,
## asynchronous API call later without touching the rest of this UI.

enum State { IDLE, GENERATING }

var _tool_id := ""

@onready var description_edit: TextEdit = %DescriptionEdit
@onready var width_value: SpinBox = %WidthValue
@onready var height_value: SpinBox = %HeightValue
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	get_ok_button().text = "Generate"


func open_for_tool(tool_id: String, tool_title: String) -> void:
	_tool_id = tool_id
	title = tool_title
	_set_state(State.IDLE)
	popup_centered()


func _on_about_to_popup() -> void:
	description_edit.text = ""


func _on_confirmed() -> void:
	var params := {
		"description": description_edit.text,
		"width": int(width_value.value),
		"height": int(height_value.value),
	}
	_set_state(State.GENERATING)
	AIGenerationClient.generate(_tool_id, params)
	# The stub above is synchronous; once it's a real API call, await its
	# `generation_finished` signal here instead of calling this directly.
	_set_state(State.IDLE)


func _set_state(state: State) -> void:
	var generating := state == State.GENERATING
	status_label.visible = generating
	description_edit.editable = not generating
	width_value.editable = not generating
	height_value.editable = not generating
	get_ok_button().disabled = generating
