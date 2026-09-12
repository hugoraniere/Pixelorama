extends Node
## The AIUtilityBridge autoload of Pixelorama.
##
## Isolates access to the currently active cel's pixels, so
## UtilityToolDialog doesn't need to know Pixelorama's internal
## Project/Cel/ImageExtended structure — mirrors the pattern already used by
## AIToolsData/AIGenerationClient for the rest of the AI Tools dock.
##
## No undo/redo support yet: existing filter dialogs (see ImageEffect.gd)
## already have a reusable pattern for that (project.undo_redo +
## serialize_cel_undo_data); left for a follow-up since a first pass should
## be enough to prove the round trip works.


func get_current_cel_image() -> Image:
	var cel := Global.current_project.get_current_cel()
	if not (cel is PixelCel):
		return null
	return cel.get_image()


func apply_image_to_current_cel(new_image: Image) -> void:
	var cel := Global.current_project.get_current_cel() as PixelCel
	if cel == null:
		return
	var current_image := cel.get_image()
	current_image.copy_from_custom(new_image, current_image.is_indexed)
	cel.update_texture()
	Global.canvas.queue_redraw()
	Global.current_project.has_changed = true
