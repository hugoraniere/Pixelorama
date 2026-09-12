extends PanelContainer
## Vertical icon rail for the AI Tools dock. Shows one toggle button per
## category from AIToolsData.CATEGORY_ORDER and keeps exactly one pressed,
## using a runtime-built ButtonGroup (the buttons themselves are also built
## at runtime, so there is nothing to pre-wire in the .tscn). No real icon
## art exists yet, so buttons fall back to a single-letter label.

@onready var categories_container: VBoxContainer = %Categories

var _button_group := ButtonGroup.new()
var _buttons_by_category: Dictionary = {}


func _ready() -> void:
	for category_id in AIToolsData.CATEGORY_ORDER:
		_add_category_button(category_id)
	AIToolsData.active_category_changed.connect(_on_active_category_changed)


func _add_category_button(category_id: String) -> void:
	var button := Button.new()
	button.name = category_id
	button.toggle_mode = true
	button.button_group = _button_group
	button.custom_minimum_size = Vector2(56, 56)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var title: String = AIToolsData.CATEGORIES[category_id]["title"]
	button.tooltip_text = title
	# TODO: swap for a TextureRect + real icon once art exists.
	button.text = title.substr(0, 1)
	button.button_pressed = category_id == AIToolsData.active_category
	button.pressed.connect(AIToolsData.set_active_category.bind(category_id))
	categories_container.add_child(button)
	_buttons_by_category[category_id] = button


func _on_active_category_changed(category_id: String) -> void:
	var button: Button = _buttons_by_category.get(category_id)
	if button:
		button.button_pressed = true
