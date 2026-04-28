extends Control

#audio
var synth: SynthEngine
var audio_output: AudioOutput
var sequencer: Sequencer
var keyboard: Keyboard
var visualizer: WaveformVisualizer

#references
var wave_option: OptionButton
var attack_slider: HSlider
var decay_slider: HSlider
var release_slider: HSlider
var volume_slider: HSlider

var delay_check: CheckButton
var delay_time_slider: HSlider
var delay_feedback_slider: HSlider
var delay_mix_slider: HSlider

var bpm_slider: HSlider
var bpm_label: Label
var play_button: Button
var stop_button: Button
var generate_button: Button
var clear_button: Button
var euclid_button: Button
var density_slider: HSlider
var scale_option: OptionButton
var root_option: OptionButton

var step_buttons: Array[Button] = []
var panic_button: Button


#styling
const BG := Color(0.04, 0.04, 0.07)
const PANEL := Color(0.09, 0.09, 0.14)
const PANEL_BORDER := Color(0.17, 0.18, 0.28)
const ACCENT := Color(0.14, 0.85, 0.70)
const ACCENT_2 := Color(1.0, 0.30, 0.82)
const TEXT := Color(0.92, 0.94, 1.0)
const TEXT_DIM := Color(0.62, 0.66, 0.78)

const NOTE_NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
const ROOT_OPTIONS := [48, 53, 55, 57, 60, 62, 64, 65, 67, 69, 72]  # C3..C5 useful roots


func _ready() -> void:
	_build_audio_chain()
	_build_ui()
	_connect_signals()



#AUDIO CHAIN

func _build_audio_chain() -> void:
	synth = SynthEngine.new()
	synth.name = "SynthEngine"
	add_child(synth)

	audio_output = AudioOutput.new()
	audio_output.name = "AudioOutput"
	audio_output.synth = synth
	add_child(audio_output)

	sequencer = Sequencer.new()
	sequencer.name = "Sequencer"
	add_child(sequencer)

	keyboard = Keyboard.new()
	keyboard.name = "Keyboard"
	add_child(keyboard)



#UI CONSTRUCTION

func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = BG
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root_vb := VBoxContainer.new()
	root_vb.anchor_right = 1.0
	root_vb.anchor_bottom = 1.0
	root_vb.offset_left = 16
	root_vb.offset_top = 16
	root_vb.offset_right = -16
	root_vb.offset_bottom = -16
	root_vb.add_theme_constant_override("separation", 12)
	add_child(root_vb)
	var title := Label.new()
	title.text = "CREATIVE  CODING  SYNTH"
	title.add_theme_color_override("font_color", ACCENT)
	title.add_theme_font_size_override("font_size", 24)
	root_vb.add_child(title)
	var viz_panel := _make_panel()
	viz_panel.custom_minimum_size = Vector2(0, 180)
	root_vb.add_child(viz_panel)
