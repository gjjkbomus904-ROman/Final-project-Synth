#Creative Coding Synth

Polyphonic generative synthesizer, step sequencer, and real-time visualizer built in Godot 4.6.

Replace with demo video:
[https://youtu.be/C5WUfZZ4xJA]
<img width="1152" height="648" alt="Знімок екрана 2026-05-01 121049" src="https://github.com/user-attachments/assets/c3bfa1cb-108e-4da8-ab67-3b6c3c034da4" />

#Features

Polyphonic (up to 16 voices)
Oscillators: sine / square / triangle / saw (procedural)
ADSR envelope per voice
Feedback delay + soft clipping
16-step sequencer (BPM + editable grid)
Pattern generation:

Random (density-based)
Euclidean rhythms
Multiple musical scales
Real-time waveform visualizer
Panic button

#Controls

Keyboard

Lower row: C3 
Upper row: C5 
Left-click: toggle note 
Right-click: clear 
Play / Stop 
BPM, Density sliders 

#Run

1. Install Godot 4.6
2. Import project
3. Press F5

#Structure

audio/        oscillators, ADSR, voices, synth engine
sequencer/    step logic + pattern generation
visualizer/   waveform rendering
input/        keyboard mapping
main.gd       wiring + UI

#Audio Flow

Input → SynthEngine → Voices → AudioOutput → Speakers
