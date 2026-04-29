# WaveformVisualizer: reads SynthEngine's circular scope buffer once per frame
# and draws it as a glowing polyline. Color saturates with output amplitude so
# louder = hotter. Fully procedural — no images needed.
class_name WaveformVisualizer
extends Control

@export var synth: SynthEngine
@export var line_width: float = 2.4
@export var glow_layers: int = 4

var _peak_smoothed: float = 0.0
var _hue_phase: float = 0.0

func _process(delta: float) -> void:
	_hue_phase = fposmod(_hue_phase + delta * 0.05, 1.0)
	queue_redraw()

func _draw() -> void:
	if synth == null:
		return
	var buffer: PackedFloat32Array = synth.get_scope_buffer()
	var write_pos: int = synth.get_scope_write_position()
	var n: int = buffer.size()
	if n < 2:
		return

	var w: float = size.x
	var h: float = size.y
	var center_y: float = h * 0.5
	var amp_scale: float = h * 0.42

	var peak: float = 0.0
	for i in n:
		peak = max(peak, abs(buffer[i]))
	_peak_smoothed = lerp(_peak_smoothed, peak, 0.18)

	var points: PackedVector2Array = PackedVector2Array()
	points.resize(n)
	for i in n:
		var idx: int = (write_pos + i) % n
		var x: float = float(i) / float(n - 1) * w
		var y: float = center_y - buffer[idx] * amp_scale
		points[i] = Vector2(x, y)

	draw_line(Vector2(0, center_y), Vector2(w, center_y), Color(1, 1, 1, 0.05), 1.0)

	var hue: float = fposmod(_hue_phase + _peak_smoothed * 0.25, 1.0)
	var line_color: Color = Color.from_hsv(hue, 0.55 + 0.4 * _peak_smoothed, 1.0)
	var glow_color: Color = Color.from_hsv(fposmod(hue + 0.08, 1.0), 0.7, 1.0)

	for layer in range(glow_layers, 0, -1):
		var width: float = line_width + float(layer) * 4.0
		var c: Color = glow_color
		c.a = (0.10 + 0.10 * _peak_smoothed) / float(layer)
		draw_polyline(points, c, width, true)

	draw_polyline(points, line_color, line_width, true)
