class_name Keyboard
extends Node

signal note_on(midi_note: int)
signal note_off(midi_note: int)

const KEY_MAP: Dictionary = {
	KEY_Z: 48, KEY_S: 49, KEY_X: 50, KEY_D: 51, KEY_C: 52,
	KEY_V: 53, KEY_G: 54, KEY_B: 55, KEY_H: 56, KEY_N: 57,
	KEY_J: 58, KEY_M: 59,
	KEY_Q: 60, KEY_2: 61, KEY_W: 62, KEY_3: 63, KEY_E: 64,
	KEY_R: 65, KEY_5: 66, KEY_T: 67, KEY_6: 68, KEY_Y: 69,
	KEY_7: 70, KEY_U: 71, KEY_I: 72,
}

var _pressed: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event
	if not KEY_MAP.has(key_event.keycode):
		return
	var note: int = KEY_MAP[key_event.keycode]
	if key_event.pressed and not key_event.echo:
		if not _pressed.has(note):
			_pressed[note] = true
			note_on.emit(note)
	elif not key_event.pressed:
		if _pressed.has(note):
			_pressed.erase(note)
			note_off.emit(note)
