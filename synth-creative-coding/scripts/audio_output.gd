class_name AudioOutput
extends AudioStreamPlayer

@export var synth: SynthEngine

var _playback: AudioStreamGeneratorPlayback

func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = SynthEngine.SAMPLE_RATE
	gen.buffer_length = 0.05
	stream = gen
	autoplay = false
	bus = "Master"
	play()
	_playback = get_stream_playback()

func _process(_delta: float) -> void:
	if _playback == null or synth == null:
		return
	var frames: int = _playback.get_frames_available()
	for i in frames:
		var s: float = synth.generate_sample()
		_playback.push_frame(Vector2(s, s))
