class_name Envelope
extends RefCounted

enum Stage { IDLE, ATTACK, DECAY, SUSTAIN, RELEASE }

var attack: float = 0.02   
var decay: float = 0.15    
var sustain: float = 0.7   
var release: float = 0.4   

var stage: Stage = Stage.IDLE
var time_in_stage: float = 0.0
var current_value: float = 0.0
var release_start_value: float = 0.0

func note_on() -> void:
	stage = Stage.ATTACK
	time_in_stage = 0.0

func note_off() -> void:
	if stage == Stage.IDLE:
		return
	release_start_value = current_value
	stage = Stage.RELEASE
	time_in_stage = 0.0

func process(dt: float) -> float:
	time_in_stage += dt
	match stage:
		Stage.ATTACK:
			if attack <= 0.0001:
				current_value = 1.0
				stage = Stage.DECAY
				time_in_stage = 0.0
			else:
				current_value = clamp(time_in_stage / attack, 0.0, 1.0)
				if current_value >= 1.0:
					stage = Stage.DECAY
					time_in_stage = 0.0
		Stage.DECAY:
			if decay <= 0.0001:
				current_value = sustain
				stage = Stage.SUSTAIN
			else:
				var t: float = clamp(time_in_stage / decay, 0.0, 1.0)
				current_value = lerp(1.0, sustain, t)
				if t >= 1.0:
					stage = Stage.SUSTAIN
		Stage.SUSTAIN:
			current_value = sustain
		Stage.RELEASE:
			if release <= 0.0001:
				current_value = 0.0
				stage = Stage.IDLE
			else:
				var t: float = clamp(time_in_stage / release, 0.0, 1.0)
				current_value = lerp(release_start_value, 0.0, t)
				if t >= 1.0:
					stage = Stage.IDLE
					current_value = 0.0
	return current_value

func is_active() -> bool:
	return stage != Stage.IDLE
