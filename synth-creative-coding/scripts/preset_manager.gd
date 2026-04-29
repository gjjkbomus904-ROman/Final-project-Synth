class_name PresetManager
extends RefCounted

const PRESET_PATH: String = "user://presets.json"

static func save_preset(name: String, payload: Dictionary) -> bool:
	if name.strip_edges() == "":
		return false
	var presets: Dictionary = load_all()
	presets[name] = payload
	var f := FileAccess.open(PRESET_PATH, FileAccess.WRITE)
	if f == null:
		push_error("PresetManager: could not open %s for writing" % PRESET_PATH)
		return false
	f.store_string(JSON.stringify(presets, "  "))
	f.close()
	return true

static func load_preset(name: String) -> Dictionary:
	var presets: Dictionary = load_all()
	var got = presets.get(name, {})
	return got if got is Dictionary else {}

static func delete_preset(name: String) -> bool:
	var presets: Dictionary = load_all()
	if not presets.has(name):
		return false
	presets.erase(name)
	var f := FileAccess.open(PRESET_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(presets, "  "))
	f.close()
	return true

static func load_all() -> Dictionary:
	if not FileAccess.file_exists(PRESET_PATH):
		return {}
	var f := FileAccess.open(PRESET_PATH, FileAccess.READ)
	if f == null:
		return {}
	var content: String = f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(content) != OK:
		return {}
	var data = json.data
	return data if data is Dictionary else {}

static func list_names() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for k in load_all().keys():
		names.append(str(k))
	names.sort()
	return names
