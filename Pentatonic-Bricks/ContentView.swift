//
//  ContentView.swift
//  Pentatonic-Bricks
//
//  Created by Aidan Bennett on 15/01/2025.
//

import SwiftUI
import Controls

// A dictionary of arrays which stores 11 notes of the pentatonic scale for each root note of the western 12 note scale as a key
let pentatonicScales: [String: [String]] = [
    "C": ["C2", "D2", "E2", "G2", "A2", "C3", "D3", "E3", "G3", "A3", "C4"],
    "C#": ["C#2", "D#2", "F2", "G#2", "A#2", "C#3", "D#3", "F3", "G#3", "A#3", "C#4"],
    "D": ["D2", "E2", "F#2", "A2", "B2", "D3", "E3", "F#3", "A3", "B3", "D4"],
    "D#": ["D#2", "F2", "G2", "A#2", "C3", "D#3", "F3", "G3", "A#3", "C4", "D#4"],
    "E": ["E2", "F#2", "G#2", "B2", "C#3", "E3", "F#3", "G#3", "B3", "C#4", "E4"],
    "F": ["F2", "G2", "A2", "C3", "D3", "F3", "G3", "A3", "C4", "D4", "F4"],
    "F#": ["F#2", "G#2", "A#2", "C#3", "D#3", "F#3", "G#3", "A#3", "C#4", "D#4", "F#4"],
    "G": ["G2", "A2", "B2", "D3", "E3", "G3", "A3", "B3", "D4", "E4", "G4"],
    "G#": ["G#2", "A#2", "C3", "D#3", "F3", "G#3", "A#3", "C4", "D#4", "F4", "G#4"],
    "A": ["A2", "B2", "C#3", "E3", "F#3", "A3", "B3", "C#4", "E4", "F#4", "A4"],
    "A#": ["A#2", "C3", "D3", "F3", "G3", "A#3", "C4", "D4", "F4", "G4", "A#4"],
    "B": ["B2", "C#3", "D#3", "F#3", "G#3", "B3", "C#4", "D#4", "F#4", "G#4", "B4"]
]

struct ContentView: View {
    @StateObject private var conductor = SynthConductor()
    @State private var activeNotes: Set<String> = [] // Tracks currently pressed notes
    @State private var rootNote: String = "C"
    
//    Vibrato state variables
    @State private var vibratoSliderValue: Float = 0.0
    @State private var vibratoSliderEditing = false
    
//    ADSR filter state variables
    @State private var attackDecayXYValue: Float = 0.5
    @State private var releaseXYValue: Float = 0.5
    @State private var sustainSliderValue: Float = 0.6
    
//    Reverb state variables
    @State private var reverbSliderValue: Float = 0.0
    @State private var reverbSliderEditing = false
    @State private var reverbPreset: Int = 0
    @State private var reverbPresetEditing = false
    
//    Phaser state variables
    @State private var phaserRateXYValue: Float = 0.5
    @State private var phaserFeedbackXYValue: Float = 0.5
    
//    Filter envolope state variables
    @State private var filterAttackDecayXYValue: Float = 0.5
    @State private var filterResonanceXYValue: Float = 0.5
    @State private var filterSustainSliderValue: Float = 0.6
    
//    Delay state variables
    @State private var delayTimeXYValue: Float = 0.5
    @State private var delayLowPassCutoffXYValue: Float = 0.5
    
//    User interface options state variables
    @State private var areNotesHolding = false

    var body: some View {
//        Navigation view logic based on LP 6.2
        NavigationView{
            ZStack{
                Color.cyan
                    .ignoresSafeArea()
                VStack {
                    HStack{
                        VStack{
                            // XYPads go from (0, 0) at origin to (1, 1) at max x and y.
                            XYPad(x: $releaseXYValue, y: $attackDecayXYValue)
                                .backgroundColor(.orange)
                                .foregroundColor(.red)
                                .cornerRadius(10)
                                .onChange(of: attackDecayXYValue, initial: true) {
                                    (attackAndDecay, newValue) in conductor.changeAttackAndDecay(attackAndDecay: newValue)
                                }
                                .onChange(of: releaseXYValue, initial: true) {
                                    (release, newValue) in conductor.changeRelease(release: newValue)
                                }
                            Slider(value: $sustainSliderValue, in: 0.1...1)
                            {Text("Sustain Slider")}
                            minimumValueLabel: {Text("0.1")}
                            maximumValueLabel: {Text("1")}
                                .onChange(of: sustainSliderValue, initial: true) {
                                    (sustain, newValue) in conductor.changeSustain(sustain: newValue)
                            }
                        }
                        
                        VStack {
                            XYPad(x: $filterResonanceXYValue, y: $filterAttackDecayXYValue)
                                .backgroundColor(.orange)
                                .foregroundColor(.red)
                                .cornerRadius(10)
                                .onChange(of: filterResonanceXYValue, initial: true) {
                                    (filterResonance, newValue) in conductor.changeFilterResonance(filterResonance: newValue)
                                }
                                .onChange(of: filterAttackDecayXYValue, initial: true) {
                                    (filterAttackAndDecay, newValue) in conductor.changeFilterAttackAndDecay(filterAttackAndDecay: newValue)
                                }
                            Slider(value: $filterSustainSliderValue, in: 0.1...1)
                            {Text("Filter Sustain Slider")}
                            minimumValueLabel: {Text("0.1")}
                            maximumValueLabel: {Text("1")}
                                .onChange(of: filterSustainSliderValue, initial: true) {
                                    (filterSustain, newValue) in conductor.changeFilterSustain(filterSustain: newValue)
                            }
                        }
                        
                    }
                    HStack {
                        NavigationLink(destination: InfoView()) {
                            Text("Instructions")
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .cornerRadius(8)
                        //                .border(Color.red, width: 5)
                        
                        Button(areNotesHolding ? "Turn note toggle off" : "Turn note toggle on") {
                            areNotesHolding.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                    Picker("Root Note", selection: $rootNote) {
                        Text("C").tag("C")
                        Text("C#").tag("C#")
                        Text("D").tag("D")
                        Text("D#").tag("D#")
                        Text("E").tag("E")
                        Text("F").tag("F")
                        Text("F#").tag("F#")
                        Text("G").tag("G")
                        Text("G#").tag("G#")
                        Text("A").tag("A")
                        Text("A#").tag("A#")
                        Text("B").tag("B")
                    }
                    .frame(width: 700, height: 50, alignment:.center)
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    HStack {
                        ForEach(pentatonicScales[rootNote]!, id: \.self) { note in
                            Text(note)
                                .font(.title)
                                .frame(width: 60, height: 200)
                                .padding(1)
                                .background(activeNotes.contains(note) ? Color.green : Color.blue) // Change color depending if it is being pressed
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if areNotesHolding { // Toggle behavior
                                                if activeNotes.contains(note) {
                                                    // If the note is already active, remove it and stop playing
                                                    activeNotes.remove(note)
                                                    conductor.stopNote(MIDIname: note)
                                                } else {
                                                    // If the note is not active, add it and play the note
                                                    activeNotes.insert(note)
                                                    conductor.playNote(MIDIname: note)
                                                }
                                            } else { // Non-toggled behavior
                                                if !activeNotes.contains(note) {
                                                    // Play note if it isn't already active
                                                    activeNotes.insert(note)
                                                    conductor.playNote(MIDIname: note)
                                                }
                                            }
                                        }
                                        .onEnded { _ in
                                            if !areNotesHolding { // Only stop notes in non-toggled mode
                                                activeNotes.remove(note)
                                                conductor.stopNote(MIDIname: note)
                                            }
                                        }
                                )
                        }
                        .padding(2)
                    }
                    Slider(value: $vibratoSliderValue, in: 0...1)
                    {Text("VibratoSlider")}
                    minimumValueLabel: {Text("0")}
                    maximumValueLabel: {Text("1")}
                    onEditingChanged: {
                        editing in vibratoSliderEditing = editing
                    }
                    .onChange(of: vibratoSliderValue, initial: true) {
                        (vibrato, newValue) in conductor.changeVibratoDepth(vibrato: newValue)
                    }
                    .padding()
                    Slider(value: $reverbSliderValue, in: 0...1)
                    {Text("ReverbSlider")}
                    minimumValueLabel: {Text("0")}
                    maximumValueLabel: {Text("1")}
                    onEditingChanged: {
                        editing in reverbSliderEditing = editing
                    }
                    .onChange(of: reverbSliderValue, initial: true) {
                        (reverbAmount, newValue) in conductor.changeReverbAmount(reverbAmount: newValue)
                    }
                    .padding()
                    Picker("Reverb Setting", selection: $reverbPreset) {
                        Text("Small Room").tag(0)
                        Text("Medium Room").tag(1)
                        Text("Large Room").tag(2)
                        Text("Medium Hall").tag(3)
                        Text("Large Hall").tag(4)
                        Text("Plate").tag(5)
                        Text("Medium Chamber").tag(6)
                        Text("Large Chamber").tag(7)
                        Text("Cathedral").tag(8)
                        Text("Large Room 2").tag(9)
                        Text("Medium Hall 2").tag(10)
                        Text("Medium Hall 3").tag(11)
                        Text("Large Hall 2").tag(12)
                    }
                    .frame(width: 700, height: 50, alignment:.center)
                    .pickerStyle(WheelPickerStyle())
                    .onChange(of: reverbPreset, initial: true) {
                        (reverbPreset, newValue) in conductor.changeReverbPreset(reverbPreset: newValue)
                    }
                    .padding()
                    HStack{
                        XYPad(x: $delayTimeXYValue, y: $delayLowPassCutoffXYValue)
                            .backgroundColor(.orange)
                            .foregroundColor(.red)
                            .cornerRadius(10)
                            .onChange(of: delayTimeXYValue, initial: true) {
                                (delayTime, newValue) in conductor.changeDelayTime(delayTime: newValue)
                            }
                            .onChange(of: delayLowPassCutoffXYValue, initial: true) {
                                (delayLowPassCutoff, newValue) in conductor.changeDelayLowPassCutoff(lowPassCutoff: newValue)
                            }
                            .padding()
                        XYPad(x: $phaserFeedbackXYValue, y: $phaserRateXYValue)
                            .backgroundColor(.orange)
                            .foregroundColor(.red)
                            .cornerRadius(10)
                            .onChange(of: phaserFeedbackXYValue, initial: true) {
                                (phaserFeedback, newValue) in conductor.changePhaserFeedback(phaserFeedback: newValue)
                            }
                            .onChange(of: phaserRateXYValue, initial: true) {
                                (phaserRate, newValue) in conductor.changePhaserRate(phaserRate: newValue)
                            }
                            .padding()
                    }
                    
                }
                .onAppear {
                    conductor.start()
                }
                .onDisappear{
                    conductor.stop()
                }
                .padding()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InfoView: View {
    var body: some View {
        ZStack {
            Color.mint
                .ignoresSafeArea()
            VStack {
                Text("Info Screen")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        InfoView()
    }
}
