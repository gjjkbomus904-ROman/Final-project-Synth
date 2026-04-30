class_name Voice
extends RefCounted

var oscillator: Oscillator
var envelope: Envelope
var frequency: float = 440.0
var note: int = 69
var velocity: float = 1.0
var active: bool = false

func _init() -> void:
	oscillator = Oscillator.new()
	envelope = Envelope.new()

func note_on(midi_note: int, vel: float = 1.0) -> void:
	note = midi_note
	frequency = midi_to_freq(midi_note)
	velocity = clamp(vel, 0.0, 1.0)
	active = true
	envelope.note_on()

func note_off() -> void:
	envelope.note_off()

func sample(sample_rate: float) -> float:
	if not envelope.is_active():
		active = false
		return 0.0
	var osc_value: float = oscillator.sample(frequency, sample_rate)
	var env_value: float = envelope.process(1.0 / sample_rate)
	return osc_value * env_value * velocity

static func midi_to_freq(midi_note: int) -> float:
	return 440.0 * pow(2.0, (midi_note - 69) / 12.0)
