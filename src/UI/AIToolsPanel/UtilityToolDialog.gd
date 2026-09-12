extends ConfirmationDialog
## Confirmation dialog for the 4 "Utility" tools (unzoom, remove background,
## pixel art correction, reduce colors) — these call the real indie-gen-utils
## microservice (classic image processing, no generative AI, no API cost),
## unlike the other categories which still need a paid backend and stay
## stubbed. Applies the result to the current cel's image in place.

var _tool_id := ""

@onready var status_label: Label = %StatusLabel
@onready var num_colors_container: Container = %NumColorsContainer
@onready var num_colors_value: SpinBox = %NumColorsValue


func _ready() -> void:
	get_ok_button().text = "Apply"


func open_for_tool(tool_id: String, tool_title: String) -> void:
	_tool_id = tool_id
	title = tool_title
	num_colors_container.visible = tool_id == "reduce_colors"
	_set_status("")
	get_ok_button().disabled = false
	popup_centered()


func _on_confirmed() -> void:
	var image := AIUtilityBridge.get_current_cel_image()
	if image == null:
		_set_status("No active image to process.")
		return

	get_ok_button().disabled = true
	_set_status("Processing...")

	var params := {}
	if _tool_id == "reduce_colors":
		params["num_colors"] = int(num_colors_value.value)

	var result: Dictionary = await AIGenerationClient.generate_utility(_tool_id, image, params)

	if result.get("status") == "done":
		AIUtilityBridge.apply_image_to_current_cel(result["image"])
		hide()
	else:
		_set_status("Error: %s" % result.get("error", "unknown"))
		get_ok_button().disabled = false


func _set_status(text: String) -> void:
	status_label.text = text
	status_label.visible = not text.is_empty()
