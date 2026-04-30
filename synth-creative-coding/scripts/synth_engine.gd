class_name SynthEngine
extends Node

const SAMPLE_RATE: float = 44100.0
const MAX_VOICES: int = 16
const SCOPE_SIZE: int = 1024
const DELAY_BUFFER_SECONDS: float = 2.0

@export var master_volume: float = 0.25
@export var wave_type: int = Oscillator.WaveType.SINE
@export var attack: float = 0.02
@export var decay: float = 0.15
@export var sustain: float = 0.7
@export var release: float = 0.4
@export var delay_enabled: bool = true
@export var delay_time: float = 0.30
@export var delay_feedback: float = 0.45
@export var delay_mix: float = 0.35

signal note_started(midi_note: int)
signal note_stopped(midi_note: int)

var _voices: Array[Voice] = []
var _note_to_voice: Dictionary = {}

var _delay_buffer: PackedFloat32Array = PackedFloat32Array()
var _delay_write: int = 0

var _scope_buffer: PackedFloat32Array = PackedFloat32Array()
var _scope_write: int = 0

func _ready() -> void:
	for i in MAX_VOICES:
		_voices.append(Voice.new())
	_delay_buffer.resize(int(SAMPLE_RATE * DELAY_BUFFER_SECONDS))
	_scope_buffer.resize(SCOPE_SIZE)

func note_on(midi_note: int, velocity: float = 1.0) -> void:
	if _note_to_voice.has(midi_note):
		return  # ignore retrigger of held key
	var v: Voice = _find_free_voice()
	v.oscillator.wave_type = wave_type
	v.oscillator.reset()
	v.envelope.attack = attack
	v.envelope.decay = decay
	v.envelope.sustain = sustain
	v.envelope.release = release
	v.note_on(midi_note, velocity)
	_note_to_voice[midi_note] = v
	note_started.emit(midi_note)

func note_off(midi_note: int) -> void:
	if not _note_to_voice.has(midi_note):
		return
	var v: Voice = _note_to_voice[midi_note]
	v.note_off()
	_note_to_voice.erase(midi_note)
	note_stopped.emit(midi_note)

func panic() -> void:
	# Hard stop on every voice (for live performance emergencies).
	for v in _voices:
		v.envelope.stage = Envelope.Stage.IDLE
		v.envelope.current_value = 0.0
		v.active = false
	_note_to_voice.clear()

func _find_free_voice() -> Voice:
	for v in _voices:
		if not v.active:
			return v
	# Voice steal: use the one with lowest envelope value (about to fade).
	var quietest: Voice = _voices[0]
	for v in _voices:
		if v.envelope.current_value < quietest.envelope.current_value:
			quietest = v
	return quietest

func generate_sample() -> float:
	# Sum active voices.
	var dry: float = 0.0
	for v in _voices:
		if v.active:
			# Allow live wave_type swap (safe — phase keeps running).
			v.oscillator.wave_type = wave_type
			dry += v.sample(SAMPLE_RATE)
	dry *= master_volume

	var out: float = dry
	if delay_enabled:
		out = _process_delay(dry)

	# Soft clip to keep things from blowing up.
	out = _soft_clip(out)

	_scope_buffer[_scope_write] = out
	_scope_write = (_scope_write + 1) % SCOPE_SIZE
	return out

func _process_delay(dry: float) -> float:
	var size: int = _delay_buffer.size()
	var offset: int = clamp(int(delay_time * SAMPLE_RATE), 1, size - 1)
	var read_idx: int = (_delay_write - offset + size) % size
	var delayed: float = _delay_buffer[read_idx]
	_delay_buffer[_delay_write] = clamp(dry + delayed * delay_feedback, -1.5, 1.5)
	_delay_write = (_delay_write + 1) % size
	return dry + delayed * delay_mix

func _soft_clip(x: float) -> float:
	# tanh-style soft saturation, cheaper approximation
	if x > 1.0: return 1.0 - 1.0 / (1.0 + (x - 1.0))
	if x < -1.0: return -1.0 + 1.0 / (1.0 + (-1.0 - x))
	return x

func get_scope_buffer() -> PackedFloat32Array:
	return _scope_buffer

func get_scope_write_position() -> int:
	return _scope_write

# --- preset serialization ---
func to_preset() -> Dictionary:
	return {
		"master_volume": master_volume,
		"wave_type": wave_type,
		"attack": attack,
		"decay": decay,
		"sustain": sustain,
		"release": release,
		"delay_enabled": delay_enabled,
		"delay_time": delay_time,
		"delay_feedback": delay_feedback,
		"delay_mix": delay_mix,
	}

func from_preset(p: Dictionary) -> void:
	master_volume = float(p.get("master_volume", master_volume))
	wave_type = int(p.get("wave_type", wave_type))
	attack = float(p.get("attack", attack))
	decay = float(p.get("decay", decay))
	sustain = float(p.get("sustain", sustain))
	release = float(p.get("release", release))
	delay_enabled = bool(p.get("delay_enabled", delay_enabled))
	delay_time = float(p.get("delay_time", delay_time))
	delay_feedback = float(p.get("delay_feedback", delay_feedback))
	delay_mix = float(p.get("delay_mix", delay_mix))
