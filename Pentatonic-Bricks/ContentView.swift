//
//  ContentView.swift
//  Pentatonic-Bricks
//
//  Created by Aidan Bennett on 15/01/2025.
//

import SwiftUI

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

let rootNotes = [
    "C", "C#", "D", "D#", "E", "F",
    "F#", "G", "G#", "A", "A#", "B"
]

struct ContentView: View {
    @StateObject private var conductor = SynthConductor()
    @State private var activeNotes: Set<String> = [] // Tracks currently pressed notes
    @State private var rootNoteIndex: Int = 5
    var body: some View {
        VStack {
                HStack {
                    ForEach(pentatonicScales[rootNotes[rootNoteIndex]]!, id: \.self) { note in
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
                                        if !activeNotes.contains(note) { // Only trigger if the note isn't already active
                                            activeNotes.insert(note) // Add note to active notes
                                            conductor.playNote(MIDIname: note) // Play the note
                                        }
                                    }
                                    .onEnded { _ in
                                        activeNotes.remove(note) // Remove note from active notes
                                        conductor.stopNote(MIDIname: note) // Stop the note
                                    }
                            )
                    }
                    .padding(2)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
