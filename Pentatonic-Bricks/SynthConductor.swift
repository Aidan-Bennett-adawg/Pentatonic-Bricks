//
//  SynthConductor.swift
//  Pentatonic-Bricks
//
//  Created by Aidan Bennett on 15/01/2025.
//  Template from lab 7 used for the Synth class functionality

import AudioKit
import SoundpipeAudioKit
import DunneAudioKit
import SwiftUI
import AVFAudio


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
    var phaser: Phaser! // Class variable for the phaser node
    var delay: Delay! // Class variable for the delay node
    var reverb: Reverb! // Class variable for the reverb node
    public let engine = AudioEngine() // Creates an audio engine for playing the synth

    
    init() {
        mySynth = Synth()       // Create synth instrument
        phaser = Phaser(mySynth) // Attach mySynth output to the phaser node input
        delay = Delay(phaser) // Attach phaser output to the delay node input
        reverb = Reverb(delay) // Attach delay output to the reverb node input
        engine.output = reverb // Attach reverb output to the final audio engine output
        
//        Then define parameters that have no user interface value bound to them
        mySynth.masterVolume = 0.5
        
        
        delay.dryWetMix = 40
        delay.feedback = 1.0
        
        phaser.depth = 0.5
        
        try!engine.start()
    }
    
/*---------------MIDI note playing functions--------------------------*/
//    This function uses the MIDI note to number dictionary defined at the top of this class to play a MIDI note depending on the string passed to the dictionary
    open func playNote (MIDIname: String){
        if let midiNote = noteToMIDIDictionary[MIDIname] {
//            print("Note \(MIDIname) corresponds to MIDI note \(midiNote)")
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

/*---------------Effects parameter functions--------------------------*/
    
    open func changeVibratoDepth(vibrato: Float) {
        mySynth.vibratoDepth = AUValue(vibrato)
    }
    
    open func changeReverbAmount(reverbAmount: Float) {
        reverb.dryWetMix = AUValue(reverbAmount)
    }
    
    open func changeReverbPreset(reverbPreset: Int) {
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset(rawValue: reverbPreset)!)
        print("Reverb index is now \(reverbPreset)")
    }
    
    open func changeAttackAndDecay(attackAndDecay: Float) {
        mySynth.attackDuration = AUValue(4*attackAndDecay)
        mySynth.decayDuration = AUValue(8*attackAndDecay)
        print("Decay duration: \(mySynth.decayDuration)")
        print("Attack duration: \(mySynth.attackDuration)")
    }
    
    open func changeRelease(release: Float) {
        mySynth.releaseDuration = AUValue(4*release)
        print("Release duration: \(mySynth.releaseDuration)")
    }
    
    open func changeSustain(sustain: Float) {
        mySynth.sustainLevel = AUValue(sustain)
    }
    
    open func changePhaserRate(phaserRate: Float) {
//        phaserRate value is scaled from 0 to 1 to 24 to 360 to match phaser documentation values
        phaser.lfoBPM = AUValue(phaserRate*336+24)
        
    }
    
    open func changePhaserFeedback(phaserFeedback: Float) {
        phaser.feedback = AUValue(phaserFeedback*0.8)
    }
    
    open func changeFilterAttackAndDecay(filterAttackAndDecay: Float) {
        mySynth.filterAttackDuration = AUValue(2*filterAttackAndDecay)
        mySynth.filterDecayDuration = AUValue(2*filterAttackAndDecay)
    }
    
    open func changeFilterResonance(filterResonance: Float) {
        mySynth.filterResonance = AUValue(5*filterResonance)
    }
    
    open func changeFilterSustain(filterSustain: Float) {
        mySynth.filterSustainLevel = AUValue(filterSustain)
    }
    
    open func changeDelayLowPassCutoff(lowPassCutoff: Float) {
        delay.lowPassCutoff = AUValue(lowPassCutoff*150+50)
    }
    
    open func changeDelayTime(delayTime: Float) {
        delay.time = AUValue(delayTime)
    }
}
