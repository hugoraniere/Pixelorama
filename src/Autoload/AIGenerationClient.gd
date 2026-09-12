extends Node
## The AIGenerationClient autoload of Pixelorama.
##
## Stubbed client for AI-assisted generation. Currently logs and returns
## a fake "generating" state; intended to be replaced with real backend calls
## (e.g. to indie-gen-utils or a Retro Diffusion endpoint) without requiring
## any change to the UI code that calls generate().

signal generation_started(tool_id: String, params: Dictionary)
signal generation_finished(tool_id: String, result: Dictionary)


func generate(tool_id: String, params: Dictionary) -> Dictionary:
	print("AIGenerationClient: generating for tool '%s' with params: %s" % [tool_id, params])
	generation_started.emit(tool_id, params)
	var result := {"status": "generating", "tool_id": tool_id}
	generation_finished.emit(tool_id, result)
	return result
