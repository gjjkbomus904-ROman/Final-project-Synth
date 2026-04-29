class_name Sequencer
extends Node

signal step_changed(step: int)
signal note_triggered(midi_note: int)

@export var bpm: float = 110.0
@export var steps: int = 16
@export var subdivision: int = 4
@export var gate: float = 0.7

var pattern: Array[int] = []
var current_step: int = 0
var playing: bool = false

var _time_acc: float = 0.0
var _step_duration: float = 0.0

func _ready() -> void:
	pattern.resize(steps)
	for i in steps:
		pattern[i] = -1
	_recalc_step_duration()

func set_bpm(new_bpm: float) -> void:
	bpm = max(20.0, new_bpm)
	_recalc_step_duration()

func _recalc_step_duration() -> void:
	_step_duration = 60.0 / bpm / float(subdivision)

func step_duration() -> float:
	return _step_duration

func set_step(idx: int, midi_note: int) -> void:
	if idx >= 0 and idx < pattern.size():
		pattern[idx] = midi_note

func clear() -> void:
	for i in pattern.size():
		pattern[i] = -1

func load_pattern(new_pattern: Array) -> void:
	for i in min(new_pattern.size(), pattern.size()):
		pattern[i] = int(new_pattern[i])

func start() -> void:
	playing = true
	current_step = 0
	_time_acc = 0.0
	_trigger_current_step()

func stop() -> void:
	playing = false

func _process(delta: float) -> void:
	if not playing:
		return
	_time_acc += delta
	while _time_acc >= _step_duration:
		_time_acc -= _step_duration
		current_step = (current_step + 1) % steps
		_trigger_current_step()

func _trigger_current_step() -> void:
	step_changed.emit(current_step)
	var midi: int = pattern[current_step]
	if midi >= 0:
		note_triggered.emit(midi)
