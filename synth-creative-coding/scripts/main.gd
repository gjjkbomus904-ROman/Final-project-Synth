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


	visualizer = WaveformVisualizer.new()
	visualizer.synth = synth
	visualizer.anchor_right = 1.0
	visualizer.anchor_bottom = 1.0
	visualizer.offset_left = 8
	visualizer.offset_top = 8
	visualizer.offset_right = -8
	visualizer.offset_bottom = -8
	viz_panel.add_child(visualizer)

	var mid_row := HBoxContainer.new()
	mid_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid_row.add_theme_constant_override("separation", 12)
	root_vb.add_child(mid_row)

	mid_row.add_child(_build_synth_panel())
	mid_row.add_child(_build_sequencer_panel())


func _make_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.border_color = PANEL_BORDER
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return p

func _section_label(text: String, color: Color = ACCENT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", 14)
	return l

func _row_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", TEXT_DIM)
	l.add_theme_font_size_override("font_size", 12)
	l.custom_minimum_size = Vector2(72, 0)
	return l

func _build_labeled_slider(text: String, min_v: float, max_v: float, step: float, value: float) -> Array:

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_row_label(text))
	var s := HSlider.new()
	s.min_value = min_v
	s.max_value = max_v
	s.step = step
	s.value = value
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(s)
	return [row, s]


func _build_synth_panel() -> PanelContainer:
	var panel := _make_panel()
	panel.custom_minimum_size = Vector2(330, 0)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	vb.add_child(_section_label("SYNTH"))
	var wave_row := HBoxContainer.new()
	wave_row.add_child(_row_label("Wave"))
	wave_option = OptionButton.new()
	wave_option.add_item("Sine",     Oscillator.WaveType.SINE)
	wave_option.add_item("Square",   Oscillator.WaveType.SQUARE)
	wave_option.add_item("Triangle", Oscillator.WaveType.TRIANGLE)
	wave_option.add_item("Saw",      Oscillator.WaveType.SAW)
	wave_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wave_option.tooltip_text = "Pick the basic waveform of every note."
	wave_row.add_child(wave_option)
	vb.add_child(wave_row)

	# Volume
	var r: Array
	r = _build_labeled_slider("Volume", 0.0, 0.6, 0.01, synth.master_volume)
	volume_slider = r[1]
	volume_slider.tooltip_text = "Master output volume (0.0 = silent, 0.6 = max)."
	vb.add_child(r[0])
	vb.add_child(_section_label("ENVELOPE", ACCENT_2))
	r = _build_labeled_slider("Attack",  0.0, 2.0, 0.005, synth.attack);  attack_slider = r[1]
	attack_slider.tooltip_text = "Fade-in time in seconds."
	vb.add_child(r[0])
	r = _build_labeled_slider("Decay",   0.0, 2.0, 0.005, synth.decay);   decay_slider = r[1]
	decay_slider.tooltip_text = "Time for the note to fall from the peak."
	vb.add_child(r[0])
	r = _build_labeled_slider("Release", 0.0, 3.0, 0.01,  synth.release); release_slider = r[1]
	release_slider.tooltip_text = "Fade-out time after the key is released."
	vb.add_child(r[0])

	# Delay
	vb.add_child(_section_label("DELAY", ACCENT_2))
	delay_check = CheckButton.new()
	delay_check.text = "Enabled"
	delay_check.button_pressed = synth.delay_enabled
	delay_check.tooltip_text = "Toggle the delay effect on or off."
	vb.add_child(delay_check)
	r = _build_labeled_slider("Time",     0.05, 1.5,  0.01, synth.delay_time);     delay_time_slider = r[1]
	delay_time_slider.tooltip_text = "Delay time in seconds (gap between echoes)."
	vb.add_child(r[0])
	r = _build_labeled_slider("Feedback", 0.0,  0.92, 0.01, synth.delay_feedback); delay_feedback_slider = r[1]
	delay_feedback_slider.tooltip_text = "Echo feedback. Higher = longer tail (avoid 1.0)."
	vb.add_child(r[0])
	r = _build_labeled_slider("Mix",      0.0,  1.0,  0.01, synth.delay_mix);      delay_mix_slider = r[1]
	delay_mix_slider.tooltip_text = "Wet level: 0 = no echo, 1 = full wet."
	vb.add_child(r[0])

	# Panic
	panic_button = Button.new()
	panic_button.text = "PANIC (all notes off)"
	panic_button.tooltip_text = "Immediately silences every voice. Useful if a note gets stuck."
	vb.add_child(panic_button)

	return panel


func _build_sequencer_panel() -> PanelContainer:
	var panel := _make_panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	vb.add_child(_section_label("SEQUENCER"))

	#Transport row
	var transport := HBoxContainer.new()
	transport.add_theme_constant_override("separation", 6)
	play_button = Button.new(); play_button.text = "▶ Play"
	stop_button = Button.new(); stop_button.text = "■ Stop"
	clear_button = Button.new(); clear_button.text = "Clear"
	transport.add_child(play_button)
	transport.add_child(stop_button)
	transport.add_child(clear_button)
	vb.add_child(transport)

	#BPM
	var bpm_row := HBoxContainer.new()
	bpm_row.add_child(_row_label("BPM"))
	bpm_slider = HSlider.new()
	bpm_slider.min_value = 50
	bpm_slider.max_value = 200
	bpm_slider.step = 1
	bpm_slider.value = sequencer.bpm
	bpm_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bpm_row.add_child(bpm_slider)
	bpm_label = Label.new()
	bpm_label.text = "%d" % int(sequencer.bpm)
	bpm_label.custom_minimum_size = Vector2(40, 0)
	bpm_row.add_child(bpm_label)
	vb.add_child(bpm_row)

	# Step grid
	var grid := GridContainer.new()
	grid.columns = 16
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	for i in sequencer.steps:
		var btn := Button.new()
		btn.toggle_mode = true
		btn.text = ""
		btn.custom_minimum_size = Vector2(28, 36)
		btn.tooltip_text = "Step %d — click to toggle, right-click clears" % (i + 1)
		btn.gui_input.connect(_on_step_button_input.bind(i))
		btn.toggled.connect(_on_step_toggled.bind(i))
		step_buttons.append(btn)
		grid.add_child(btn)
	vb.add_child(grid)


	vb.add_child(_section_label("GENERATE", ACCENT_2))

	var scale_row := HBoxContainer.new()
	scale_row.add_child(_row_label("Scale"))
	scale_option = OptionButton.new()
	for s in PatternGenerator.scale_names():
		scale_option.add_item(str(s).replace("_", " "))
	scale_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scale_row.add_child(scale_option)
	vb.add_child(scale_row)

	var root_row := HBoxContainer.new()
	root_row.add_child(_row_label("Root"))
	root_option = OptionButton.new()
	for midi in ROOT_OPTIONS:
		root_option.add_item(_midi_name(midi), midi)
	# default to C4 (60)
	for i in root_option.item_count:
		if root_option.get_item_id(i) == 60:
			root_option.select(i)
			break
	root_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_row.add_child(root_option)
	vb.add_child(root_row)


	var r: Array
	r = _build_labeled_slider("Density", 0.1, 0.95, 0.01, 0.55); density_slider = r[1]; vb.add_child(r[0])

	var gen_row := HBoxContainer.new()
	gen_row.add_theme_constant_override("separation", 6)
	generate_button = Button.new(); generate_button.text = "Random"
	euclid_button = Button.new();   euclid_button.text = "Euclidean"
	generate_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	euclid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gen_row.add_child(generate_button)
	gen_row.add_child(euclid_button)
	vb.add_child(gen_row)

	return panel

func _connect_signals() -> void:
	keyboard.note_on.connect(_on_keyboard_note_on)
	keyboard.note_off.connect(_on_keyboard_note_off)

	sequencer.note_triggered.connect(_on_seq_note_triggered)
	sequencer.step_changed.connect(_on_seq_step_changed)

	wave_option.item_selected.connect(func(idx): synth.wave_type = wave_option.get_item_id(idx))
	volume_slider.value_changed.connect(func(v): synth.master_volume = v)
	attack_slider.value_changed.connect(func(v): synth.attack = v)
	decay_slider.value_changed.connect(func(v): synth.decay = v)
	release_slider.value_changed.connect(func(v): synth.release = v)
	delay_check.toggled.connect(func(p): synth.delay_enabled = p)
	delay_time_slider.value_changed.connect(func(v): synth.delay_time = v)
	delay_feedback_slider.value_changed.connect(func(v): synth.delay_feedback = v)
	delay_mix_slider.value_changed.connect(func(v): synth.delay_mix = v)
	panic_button.pressed.connect(_on_panic)

	play_button.pressed.connect(func():
		sequencer.start()
	)
	stop_button.pressed.connect(func():
		sequencer.stop()
		synth.panic()
		_clear_playhead()
	)
	clear_button.pressed.connect(func():
		sequencer.clear()
		_refresh_step_buttons()
	)
	bpm_slider.value_changed.connect(func(v):
		sequencer.set_bpm(v)
		bpm_label.text = "%d" % int(v)
	)

	generate_button.pressed.connect(_on_generate_random)
	euclid_button.pressed.connect(_on_generate_euclidean)

func _on_keyboard_note_on(midi_note: int) -> void:
	synth.note_on(midi_note)

func _on_keyboard_note_off(midi_note: int) -> void:
	synth.note_off(midi_note)

func _on_seq_note_triggered(midi_note: int) -> void:
	synth.note_on(midi_note)
	var t: SceneTreeTimer = get_tree().create_timer(sequencer.step_duration() * sequencer.gate)
	t.timeout.connect(func(): synth.note_off(midi_note))

func _on_seq_step_changed(step: int) -> void:
	for i in step_buttons.size():
		var btn: Button = step_buttons[i]
		_apply_step_style(btn, sequencer.pattern[i] >= 0, i == step)

func _clear_playhead() -> void:
	for i in step_buttons.size():
		_apply_step_style(step_buttons[i], sequencer.pattern[i] >= 0, false)

func _on_step_button_input(event: InputEvent, idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			sequencer.set_step(idx, -1)
			step_buttons[idx].set_pressed_no_signal(false)
			_apply_step_style(step_buttons[idx], false, idx == sequencer.current_step)

func _on_step_toggled(pressed: bool, idx: int) -> void:
	if pressed:
		var root_id: int = root_option.get_item_id(root_option.selected)
		var scale_name: String = scale_option.get_item_text(scale_option.selected).replace(" ", "_")
		var scale: Array = PatternGenerator.SCALES.get(scale_name, [0])
		var degree: int = (idx / 4) % scale.size()
		sequencer.set_step(idx, root_id + scale[degree])
	else:
		sequencer.set_step(idx, -1)
	_apply_step_style(step_buttons[idx], pressed, idx == sequencer.current_step)

func _apply_step_style(btn: Button, has_note: bool, is_playhead: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(4)
	if is_playhead and has_note:
		sb.bg_color = ACCENT_2
	elif is_playhead:
		sb.bg_color = Color(ACCENT_2.r, ACCENT_2.g, ACCENT_2.b, 0.45)
	elif has_note:
		sb.bg_color = ACCENT
	else:
		sb.bg_color = Color(0.18, 0.19, 0.27)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)

func _refresh_step_buttons() -> void:
	for i in step_buttons.size():
		var has_note: bool = sequencer.pattern[i] >= 0
		step_buttons[i].set_pressed_no_signal(has_note)
		_apply_step_style(step_buttons[i], has_note, i == sequencer.current_step)

func _on_generate_random() -> void:
	var root_id: int = root_option.get_item_id(root_option.selected)
	var scale_name: String = scale_option.get_item_text(scale_option.selected).replace(" ", "_")
	var pattern: Array[int] = PatternGenerator.generate(sequencer.steps, root_id, scale_name, density_slider.value)
	sequencer.load_pattern(pattern)
	_refresh_step_buttons()

func _on_generate_euclidean() -> void:
	var root_id: int = root_option.get_item_id(root_option.selected)
	var scale_name: String = scale_option.get_item_text(scale_option.selected).replace(" ", "_")
	var hits: int = int(round(density_slider.value * sequencer.steps))
	hits = clamp(hits, 1, sequencer.steps)
	var pattern: Array[int] = PatternGenerator.euclidean(sequencer.steps, hits, root_id, scale_name)
	sequencer.load_pattern(pattern)
	_refresh_step_buttons()

func _on_panic() -> void:
	synth.panic()

func _midi_name(midi: int) -> String:
	var note: String = NOTE_NAMES[midi % 12]
	var octave: int = (midi / 12) - 1
	return "%s%d" % [note, octave]
