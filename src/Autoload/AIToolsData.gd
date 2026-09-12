extends Node
## The AIToolsData autoload of Pixelorama.
##
## Static source of truth for the AI Tools dock's categories and tools, and
## the shared "active category" state that keeps the icon rail dock and the
## content panel dock in sync (they are separate DockableContainer children
## and cannot reach each other via unique names or groups).

signal active_category_changed(category_id: String)

## Category order also defines icon rail button order.
const CATEGORY_ORDER := ["create", "transform", "animate", "utility"]

## category_id -> {title: String, tools: Array[Dictionary{id, title, description}]}
const CATEGORIES := {
	"create": {
		"title": "Create",
		"tools": [
			{
				"id": "create_image",
				"title": "Create image",
				"description": "Generate a new pixel art image from a text prompt.",
			},
			{
				"id": "image_to_pixel_art",
				"title": "Image to pixel art",
				"description": "Convert a reference image into pixel art.",
			},
		],
	},
	"transform": {
		"title": "Transform",
		"tools": [
			{
				"id": "edit_image",
				"title": "Edit image",
				"description": "Edit the current image using a text instruction.",
			},
			{
				"id": "image_to_image",
				"title": "Image to image",
				"description": "Restyle the current image using a reference image.",
			},
		],
	},
	"animate": {
		"title": "Animate",
		"tools": [
			{
				"id": "animate_with_text",
				"title": "Animate with text",
				"description": "Generate an animation from a text prompt.",
			},
			{
				"id": "interpolate",
				"title": "Interpolate",
				"description": "Generate in-between frames between two keyframes.",
			},
		],
	},
	"utility": {
		"title": "Utility",
		"tools": [
			{
				"id": "unzoom",
				"title": "Unzoom",
				"description": "Reduce the image to its real pixel grid size.",
			},
			{
				"id": "remove_background",
				"title": "Remove background",
				"description": "Remove the background from the current image.",
			},
			{
				"id": "pixel_art_correction",
				"title": "Pixel art correction",
				"description": "Clean up stray pixels and jagged edges.",
			},
			{
				"id": "reduce_colors",
				"title": "Reduce colors",
				"description": "Reduce the image's palette to a target color count.",
			},
		],
	},
}

var active_category: String = CATEGORY_ORDER[0]


func set_active_category(category_id: String) -> void:
	if category_id == active_category or not CATEGORIES.has(category_id):
		return
	active_category = category_id
	active_category_changed.emit(category_id)


func get_tools(category_id: String) -> Array:
	return CATEGORIES.get(category_id, {}).get("tools", [])


## Linear search is fine: at most ~10 tools total.
func find_tool(tool_id: String) -> Dictionary:
	for category_id in CATEGORIES:
		for tool_info in CATEGORIES[category_id]["tools"]:
			if tool_info["id"] == tool_id:
				return tool_info
	return {}
