class_name PatternGenerator
extends RefCounted

const SCALES: Dictionary = {
	"minor_pentatonic": [0, 3, 5, 7, 10],
	"major_pentatonic": [0, 2, 4, 7, 9],
	"natural_minor":    [0, 2, 3, 5, 7, 8, 10],
	"major":            [0, 2, 4, 5, 7, 9, 11],
	"dorian":           [0, 2, 3, 5, 7, 9, 10],
	"phrygian":         [0, 1, 3, 5, 7, 8, 10],
	"blues":            [0, 3, 5, 6, 7, 10],
}

static func scale_names() -> Array:
	return SCALES.keys()

static func generate(steps: int, root_midi: int = 60, scale_name: String = "minor_pentatonic", density: float = 0.55) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var scale: Array = SCALES.get(scale_name, SCALES["minor_pentatonic"])
	var pattern: Array[int] = []
	pattern.resize(steps)
	for i in steps:
		var beat_boost: float = 0.18 if (i % 4 == 0) else 0.0
		if rng.randf() < density + beat_boost:
			var degree: int = rng.randi_range(0, scale.size() - 1)
			var octave_shift: int = rng.randi_range(0, 1) * 12
			pattern[i] = root_midi + scale[degree] + octave_shift
		else:
			pattern[i] = -1
	return pattern

static func euclidean(steps: int, hits: int, root_midi: int = 60, scale_name: String = "minor_pentatonic") -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var scale: Array = SCALES.get(scale_name, SCALES["minor_pentatonic"])
	var pattern: Array[int] = []
	pattern.resize(steps)
	hits = clamp(hits, 0, steps)
	var bucket: float = 0.0
	var step_inc: float = float(hits) / float(steps)
	for i in steps:
		bucket += step_inc
		if bucket >= 1.0:
			bucket -= 1.0
			var degree: int = rng.randi_range(0, scale.size() - 1)
			pattern[i] = root_midi + scale[degree]
		else:
			pattern[i] = -1
	return pattern
