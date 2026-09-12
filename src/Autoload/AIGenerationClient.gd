extends Node
## The AIGenerationClient autoload of Pixelorama.
##
## Two kinds of tools, two backends:
## - "Utility" tools (unzoom, remove background, pixel art correction, reduce
##   colors) call the real indie-gen-utils microservice — classic image
##   processing, no generative AI, no API cost. See generate_utility().
## - Every other category (Create/Transform/Animate) needs a paid generative
##   backend (Retro Diffusion via Replicate) that isn't wired up here yet —
##   generate() stays a stub so the rest of the UI has something to call
##   without crashing, but it no longer pretends to succeed.

signal generation_started(tool_id: String, params: Dictionary)
signal generation_finished(tool_id: String, result: Dictionary)

## Base URL of the indie-gen-utils FastAPI service (`uvicorn app.main:app`,
## default port). Override via the PIXELORAMA_UTILS_URL environment variable
## if it's running elsewhere.
const DEFAULT_UTILS_URL := "http://127.0.0.1:8000"

const UTILITY_ENDPOINTS := {
	"unzoom": "unzoom",
	"remove_background": "remove-background",
	"pixel_art_correction": "correct-pixelart",
	"reduce_colors": "reduce-colors",
}


func generate(tool_id: String, params: Dictionary) -> Dictionary:
	print("AIGenerationClient: '%s' needs a generative backend, not implemented yet (params: %s)" % [tool_id, params])
	generation_started.emit(tool_id, params)
	var result := {
		"status": "error",
		"error": "This tool needs a generative AI backend (Retro Diffusion/Replicate), not configured yet.",
	}
	generation_finished.emit(tool_id, result)
	return result


## Sends `image` (a Godot Image) to the indie-gen-utils endpoint for
## `tool_id`, as a multipart/form-data upload, and returns
## {"status": "done", "image": Image} or {"status": "error", "error": String}.
func generate_utility(tool_id: String, image: Image, params: Dictionary = {}) -> Dictionary:
	if not UTILITY_ENDPOINTS.has(tool_id):
		return {"status": "error", "error": "'%s' is not a utility tool." % tool_id}

	var png_bytes := image.save_png_to_buffer()
	if png_bytes.is_empty():
		return {"status": "error", "error": "Failed to encode the current image as PNG."}

	var base_url := OS.get_environment("PIXELORAMA_UTILS_URL")
	if base_url.is_empty():
		base_url = DEFAULT_UTILS_URL
	var url := "%s/%s" % [base_url, UTILITY_ENDPOINTS[tool_id]]
	if tool_id == "reduce_colors":
		var num_colors: int = clampi(int(params.get("num_colors", 16)), 2, 256)
		var dither: bool = bool(params.get("dither", false))
		url += "?num_colors=%d&dither=%s" % [num_colors, "true" if dither else "false"]

	generation_started.emit(tool_id, params)

	var boundary := "PixeloramaBoundary%d" % Time.get_ticks_msec()
	var body := _build_multipart_body(boundary, "file", "image.png", "image/png", png_bytes)
	var headers := ["Content-Type: multipart/form-data; boundary=%s" % boundary]

	var http := HTTPRequest.new()
	add_child(http)
	var request_error := http.request_raw(url, headers, HTTPClient.METHOD_POST, body)
	if request_error != OK:
		http.queue_free()
		var error_result := {"status": "error", "error": "Could not reach %s (is it running?)." % base_url}
		generation_finished.emit(tool_id, error_result)
		return error_result

	var response: Array = await http.request_completed
	http.queue_free()

	var response_code: int = response[1]
	var response_body: PackedByteArray = response[3]

	if response_code != 200:
		var error_result := {
			"status": "error",
			"error": "%s returned HTTP %d." % [base_url, response_code],
		}
		generation_finished.emit(tool_id, error_result)
		return error_result

	var result_image := Image.new()
	var load_error := result_image.load_png_from_buffer(response_body)
	if load_error != OK:
		var error_result := {"status": "error", "error": "Response wasn't a valid PNG."}
		generation_finished.emit(tool_id, error_result)
		return error_result

	var success_result := {"status": "done", "image": result_image}
	generation_finished.emit(tool_id, success_result)
	return success_result


func _build_multipart_body(
	boundary: String, field_name: String, filename: String, content_type: String, data: PackedByteArray
) -> PackedByteArray:
	var body := PackedByteArray()
	var header := (
		"--%s\r\nContent-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\nContent-Type: %s\r\n\r\n"
		% [boundary, field_name, filename, content_type]
	)
	body.append_array(header.to_utf8_buffer())
	body.append_array(data)
	var footer := "\r\n--%s--\r\n" % boundary
	body.append_array(footer.to_utf8_buffer())
	return body
