//
//  SynthConductor.swift
//  Pentatonic-Bricks
//
//  Created by Aidan Bennett on 15/01/2025.
//

import AudioKit
import DunneAudioKit
import SwiftUI


let noteToMIDIDictionary: [String: MIDINoteNumber] = {
    let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    var dictionary = [String: MIDINoteNumber]()
    
    for midiNote in 0...127 {
        let octave = (midiNote / 12) - 1 // Calculate octave
        let noteName = notes[midiNote % 12] + "\(octave)"
        dictionary[noteName] = MIDINoteNumber(midiNote)
    }
    
    return dictionary
}()

open class SynthConductor: ObservableObject, HasAudioEngine{
    
    var mySynth: Synth! // Class variable to hold synth instrument
    public let engine = AudioEngine() // Creates an audio engine for playing the synth
    
    init() {
        mySynth = Synth()       // Create synth instrument
        
        engine.output = mySynth       // and connect it to audio out
        // The synth will play without any parameters being set
        // but here are a few things you can adjust
        // Look at the documentation online for the full set
        // or start typing mySynth. and see what options come up
        mySynth.attackDuration = 0.5
        mySynth.filterCutoff = 0.5
        mySynth.filterAttackDuration = 1.5
        mySynth.masterVolume = 0.5
        mySynth.filterResonance = 0.8
        mySynth.vibratoDepth = 0.2
        
        try!engine.start()
    }
    
    open func changeVibratoDepth(vibrato: Float) {
        mySynth.vibratoDepth = AUValue(vibrato)
    }

//    This function uses the MIDI note to number dictionary defined at the top of this class to play a MIDI note depending on the string passed to the dictionary
    open func playNote (MIDIname: String){
        if let midiNote = noteToMIDIDictionary[MIDIname] {
            print("Note \(MIDIname) corresponds to MIDI note \(midiNote)")
            mySynth.play(noteNumber: midiNote, velocity: 30)
        }
        else{
            print("That MIDI value is invalid")
        }
    }
    
    open func stopNote (MIDIname: String){
        if let midiNote = noteToMIDIDictionary[MIDIname] {
            mySynth.stop(noteNumber: midiNote)
        }
        else{
            print("That MIDI value is invalid")
        }
    }
}
