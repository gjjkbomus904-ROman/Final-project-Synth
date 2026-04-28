class_name Oscillator
extends RefCounted

enum WaveType { SINE, SQUARE, TRIANGLE, SAW }

var wave_type: WaveType = WaveType.SINE
var phase: float = 0.0

func sample(frequency: float, sample_rate: float) -> float:
	var phase_increment: float = frequency / sample_rate
	var value: float = 0.0
	match wave_type:
		WaveType.SINE:
			value = sin(phase * TAU)
		WaveType.SQUARE:
			value = 1.0 if phase < 0.5 else -1.0
		WaveType.TRIANGLE:
			value = 1.0 - abs(4.0 * phase - 2.0)
		WaveType.SAW:
			value = 2.0 * phase - 1.0
	phase += phase_increment
	if phase >= 1.0:
		phase -= floor(phase)
	return value

func reset() -> void:
	phase = 0.0
