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
