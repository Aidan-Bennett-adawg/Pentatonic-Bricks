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
    "C": ["C3", "D3", "E3", "G3", "A3", "C4", "D4", "E4", "G4", "A4", "C5"],
    "C#": ["C#3", "D#3", "F3", "G#3", "A#3", "C#4", "D#4", "F4", "G#4", "A#4", "C#5"],
    "D": ["D3", "E3", "F#3", "A3", "B3", "D4", "E4", "F#4", "A4", "B4", "D5"],
    "D#": ["D#3", "F3", "G3", "A#3", "C4", "D#4", "F4", "G4", "A#4", "C5", "D#5"],
    "E": ["E3", "F#3", "G#3", "B3", "C#4", "E4", "F#4", "G#4", "B4", "C#5", "E5"],
    "F": ["F3", "G3", "A3", "C4", "D4", "F4", "G4", "A4", "C5", "D5", "F5"],
    "F#": ["F#3", "G#3", "A#3", "C#4", "D#4", "F#4", "G#4", "A#4", "C#5", "D#5", "F#5"],
    "G": ["G3", "A3", "B3", "D4", "E4", "G4", "A4", "B4", "D5", "E5", "G5"],
    "G#": ["G#3", "A#3", "C4", "D#4", "F4", "G#4", "A#4", "C5", "D#5", "F5", "G#5"],
    "A": ["A3", "B3", "C#4", "E4", "F#4", "A4", "B4", "C#5", "E5", "F#5", "A5"],
    "A#": ["A#3", "C4", "D4", "F4", "G4", "A#4", "C5", "D5", "F5", "G5", "A#5"],
    "B": ["B3", "C#4", "D#4", "F#4", "G#4", "B4", "C#5", "D#5", "F#5", "G#5", "B5"]
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
    @State private var sustainSliderEditing = false
    
    
//    Reverb state variables
    @State private var reverbSliderValue: Float = 0.0
    @State private var reverbSliderEditing = false
    @State private var reverbPreset: Int = 0
    
//    Phaser state variables
    @State private var phaserRateXYValue: Float = 0.5
    @State private var phaserFeedbackXYValue: Float = 0.5
    
//    Filter envolope state variables
    @State private var filterAttackDecayXYValue: Float = 0.5
    @State private var filterResonanceXYValue: Float = 0.5
    @State private var filterSustainSliderValue: Float = 0.6
    @State private var filterSustainEditing = false
    
//    Delay state variables
    @State private var delayTimeXYValue: Float = 0.5
    @State private var delayLowPassCutoffXYValue: Float = 0.5
    
//    User interface options state variables
    @State private var areNotesHolding = false
    @State private var valuesShowing = false

    var body: some View {
//        Navigation view logic based on LP 6.2
        NavigationView{
            GeometryReader { geometry in
                ZStack{
                    Color.cyan
                        .ignoresSafeArea()
                    VStack {
                        HStack{
                            ZStack {
                                VStack {
                                    Text("Delay time: \(conductor.getDelayTime(), specifier: "%.2f") sec")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                    Text("Delay filter cutoff: \(conductor.getDelayLowPassCutoff(), specifier: "%.0f")Hz")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                }
                                .allowsHitTesting(false) // Allows touches through the info text
                                .zIndex(valuesShowing ? 1 : 0)
                                
                                XYPad(x: $delayTimeXYValue, y: $delayLowPassCutoffXYValue)
                                
                                    .backgroundColor(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .onChange(of: delayTimeXYValue) {
                                        (newValue) in conductor.changeDelayTime(delayTime: newValue)
                                    }
                                    .onChange(of: delayLowPassCutoffXYValue) {
                                        (newValue) in conductor.changeDelayLowPassCutoff(lowPassCutoff: newValue)
                                    }
                            }
                            .padding(3)
                            
                            ZStack {
                                VStack {
                                    Text("Phaser feedback: \(conductor.getPhaserFeedback(), specifier: "%.2f")")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                    Text("Phaser rate: \(conductor.getPhaserRate(), specifier: "%.0f")bpm")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                }
                                .allowsHitTesting(false)
                                .zIndex(valuesShowing ? 1 : 0)
                                XYPad(x: $phaserFeedbackXYValue, y: $phaserRateXYValue)
                                    .backgroundColor(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .onChange(of: phaserFeedbackXYValue) {
                                        (newValue) in conductor.changePhaserFeedback(phaserFeedback: newValue)
                                    }
                                    .onChange(of: phaserRateXYValue) {
                                        (newValue) in conductor.changePhaserRate(phaserRate: newValue)
                                    }
                            }
                            .padding(3)
                        }
                        
                        HStack{
                            ZStack {
                                VStack {
                                    Text("Attack/decay time: \(conductor.getAttack(), specifier: "%.2f") sec")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                    Text("Release time: \(conductor.getRelease(), specifier: "%.2f") sec")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                }
                                .allowsHitTesting(false)
                                .zIndex(valuesShowing ? 1 : 0)
                                    
                                XYPad(x: $releaseXYValue, y: $attackDecayXYValue)
                                    .backgroundColor(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .onChange(of: attackDecayXYValue) {
                                        (newValue) in conductor.changeAttackAndDecay(attackAndDecay: newValue)
                                    }
                                    .onChange(of: releaseXYValue) {
                                        (newValue) in conductor.changeRelease(release: newValue)
                                    }
                                }
                                .padding(3)
                            
                            VStack {
                                ZStack {
                                    VStack {
                                        Text("Filter resonance: \(conductor.getFilterResonance(), specifier: "%.2f")")
                                            .foregroundColor(.blue)
                                            .font(.headline)
                                        Text("Filter attack/decay: \(conductor.getFilterAttack(), specifier: "%.2f") sec")
                                            .foregroundColor(.blue)
                                            .font(.headline)
                                    }
                                    .allowsHitTesting(false)
                                    .zIndex(valuesShowing ? 1 : 0)
                                    
                                    XYPad(x: $filterResonanceXYValue, y: $filterAttackDecayXYValue)
                                        .backgroundColor(.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .onChange(of: filterResonanceXYValue) {
                                            (newValue) in conductor.changeFilterResonance(filterResonance: newValue)
                                        }
                                        .onChange(of: filterAttackDecayXYValue) {
                                            (newValue) in conductor.changeFilterAttackAndDecay(filterAttackAndDecay: newValue)
                                        }
                                }
                                .padding(3)
                                
                                
                            }
                        }
                        
                        HStack{
                            VStack{
                                Slider(value: $sustainSliderValue, in: 0.1...1)
                                {Text("Sustain Slider")}
                                minimumValueLabel: {Text("0.1")}
                                maximumValueLabel: {Text("1")}
                                onEditingChanged: {
                                    editing in sustainSliderEditing = editing
                                }
                                    .onChange(of: sustainSliderValue) {
                                        (newValue) in conductor.changeSustain(sustain: newValue)
                                }

                                if valuesShowing {
                                    Text("Sustain level: \(conductor.getSustain(), specifier: "%.2f")")
                                        .foregroundColor(sustainSliderEditing ? .purple : .black)
                                        .font(.headline)
                                }
                            }
                            
                            VStack{
                                Slider(value: $filterSustainSliderValue, in: 0.1...1)
                                {Text("Filter Sustain Slider")}
                                minimumValueLabel: {Text("0.1")}
                                maximumValueLabel: {Text("1")}
                                onEditingChanged: {
                                    editing in filterSustainEditing = editing
                                }
                                    .onChange(of: filterSustainSliderValue) {
                                        (newValue) in conductor.changeFilterSustain(filterSustain: newValue)
                                }
                                
                                if valuesShowing {
                                    Text("Filter Sustain level: \(conductor.getFilterSustain(), specifier: "%.2f")")
                                        .foregroundColor(filterSustainEditing ? .purple : .black)
                                        .font(.headline)
                                }
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: InfoView()) {
                                Text("Instructions")
                            }
                            .buttonStyle(.borderedProminent)
                            .foregroundStyle(.purple)
                            .tint(.mint)
                            .cornerRadius(8)
                            
                            Toggle(isOn: $valuesShowing) {
                                Text("Show values:")
                            }
                            .frame(width: 160, height: 50, alignment: .center)
                            
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
                            .frame(width: geometry.size.width/2, height: 50, alignment:.center)
                            .pickerStyle(WheelPickerStyle())
                            .onChange(of: reverbPreset) {
                                (newValue) in conductor.changeReverbPreset(reverbPreset: newValue)
                            }
                        }
                        
                        HStack {
                            VStack {
                                Slider(value: $vibratoSliderValue, in: 0...1)
                                {Text("VibratoSlider")}
                                minimumValueLabel: {Text("0")}
                                maximumValueLabel: {Text("1")}
                                onEditingChanged: {
                                    editing in vibratoSliderEditing = editing
                                }
                                .onChange(of: vibratoSliderValue) {
                                    (newValue) in conductor.changeVibratoDepth(vibrato: newValue)
                                }
                                
                                if valuesShowing {
                                    Text("Vibrato depth: \(conductor.getVibratoDepth(), specifier: "%.2f")")
                                        .foregroundColor(vibratoSliderEditing ? .purple : .black)
                                        .font(.headline)
                                }
                            }
                            
                            VStack {
                                Slider(value: $reverbSliderValue, in: 0...1)
                                {Text("ReverbSlider")}
                                minimumValueLabel: {Text("0")}
                                maximumValueLabel: {Text("1")}
                                onEditingChanged: {
                                    editing in reverbSliderEditing = editing
                                }
                                .onChange(of: reverbSliderValue) {
                                    (newValue) in conductor.changeReverbAmount(reverbAmount: newValue)
                                }
                                
                                if valuesShowing {
                                    Text("Reverb dry/wet mix: \(conductor.getReverbAmount(), specifier: "%.2f")")
                                        .foregroundColor(reverbSliderEditing ? .purple : .black)
                                        .font(.headline)
                                }
                            }
                        }
                        
                        HStack {
                            Toggle(isOn: $areNotesHolding) {
                                Text("Hold:")
                            }
                            .frame(width: 100, height: 50, alignment: .center)
                            
                            Button("CLEAR") {
                                let notesToRemove = Array(activeNotes) // Convert to an Array to iterate safely
                                for note in notesToRemove {
                                    activeNotes.remove(note) // Modify the set outside the iteration
                                    conductor.stopNote(MIDIname: note)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            
                            
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
                            .frame(width: geometry.size.width/2, height: 50, alignment:.center)
                            .pickerStyle(WheelPickerStyle())
                        }
                        
                        HStack {
                            ForEach(pentatonicScales[rootNote]!, id: \.self) { note in
                                Text(note)
                                    .font(.title)
                                    .frame(width: 60, height: 150)
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
                        }
                    }
                    .onAppear {
                        conductor.start()
                    }
                    .onDisappear{
                        conductor.stop()
                    }
                    .frame(width: geometry.size.width-10, alignment: .center)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InfoView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.mint
                    .ignoresSafeArea()
                
                ScrollView { // Enables scrolling if needed
                    VStack {
                        Text("Top left pad:\n -> Up and down to control the delay low pass filter cutoff in Hz\n -> Side to side to control the delay time in seconds\nTop right pad:\n -> Up and down to control the phaser rate in beats per minute (bpm)\n -> Side to side to control the amount of phaser feedback\nBottom left pad:\n -> Up and down to control the attack and decay time of the amplitude envelope in seconds\n -> Side to side to control the release time of the amplitude filter in seconds\nBottom right pad:\n -> Up and down to control the filter attack and decay time in seconds\n -> Side to side to control the filter resonance level")
                            .padding()
                            .frame(width: geometry.size.width - 10) // Adds padding to prevent edge touches
                            .multilineTextAlignment(.leading) // Centers the text

                        Spacer().frame(height: 3) // Adds space between text and image

                        Image("PentatonicBotInfoScreen")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Fits the image within its frame without cropping
                            .frame(width: geometry.size.width - 450) // Adds margin on the sides
                            .cornerRadius(10) // Optional: Rounds the corners of the image
                            .shadow(radius: 5) // Optional: Adds a shadow for better visual hierarchy
                        
                        Spacer().frame(height: 3)
                        
                        Text("Play the synth by touching the blocks labelled with the notes they play at the bottom of the screen; they are based on a pentatonic scale so any note will sound good with a neighboring note. You can select the root note of the pentatonic scale using the selector above the note blocks.\n\nToggle the Hold switch so that notes will toggle on and off instead of stopping when you release, and press the CLEAR button to stop all notes playing.\n\nToggle the Show values switch to make labels appear with values of the XYPads, and values of other parameters such as the vibrato depth, the reverb dry/wet mix, and the sustain levels of the amplitude and filter envelopes. The reverb room preset can be selected using the options above the reverb slider.")
                            .padding()
                            .frame(width: geometry.size.width - 10) // Adds padding to prevent edge touches
                            .multilineTextAlignment(.leading) // Centers the text
                    }
                    .frame(maxWidth: .infinity) // Centers the VStack content horizontally
                    .padding(.vertical, 20) // Adds vertical padding for better spacing
                    
                    
                }
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
