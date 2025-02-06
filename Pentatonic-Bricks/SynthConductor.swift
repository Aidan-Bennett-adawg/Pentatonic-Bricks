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

// This dictionary of strings converts a string sent to it to the equivalent MIDI note, which includes the octave it is in based on the appended number.
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
        
//        Then define initial parameters according to the presets in the bound user interface values
        mySynth.masterVolume = 0.9
        
        self.changeVibratoDepth(vibrato: 0)
        self.changeAttackAndDecay(attackAndDecay: 0.5)
        self.changeRelease(release: 0.5)
        self.changeSustain(sustain: 0.6)
        
        self.changeFilterAttackAndDecay(filterAttackAndDecay: 0.5)
        self.changeFilterResonance(filterResonance: 0.5)
        self.changeFilterSustain(filterSustain: 0.6)
        
//        And the effects presets too
        self.changeReverbAmount(reverbAmount: 0)
        self.changeReverbPreset(reverbPreset: 0)
        
        self.changePhaserRate(phaserRate: 0.5)
        self.changePhaserFeedback(phaserFeedback: 0.5)
        
        self.changeDelayTime(delayTime: 0.5)
        self.changeDelayLowPassCutoff(lowPassCutoff: 0.5)
        
        delay.dryWetMix = 40
        delay.feedback = 1.0
        
        phaser.depth = 0.5
        
        try!engine.start()
    }
    
/*---------------MIDI note playing functions--------------------------*/
//    This function uses the MIDI note to number dictionary defined at the top of this class to play a MIDI note depending on the string passed to the dictionary
    open func playNote (MIDIname: String){
        if let midiNote = noteToMIDIDictionary[MIDIname] {
            print("Note \(MIDIname) corresponds to MIDI note \(midiNote)")
            mySynth.play(noteNumber: midiNote, velocity: 120)
        }
        else{
            print("That MIDI value is invalid")
        }
    }
//    This does a similar thing except it stops the note.
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
        print("Vibrato depth: \(mySynth.vibratoDepth)")
    }
    
    open func changeReverbAmount(reverbAmount: Float) {
        reverb.dryWetMix = AUValue(reverbAmount)
        print("Reverb mix: \(reverb.dryWetMix)")
    }
    
    open func changeReverbPreset(reverbPreset: Int) {
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset(rawValue: reverbPreset)!)
        print("Reverb index: \(reverbPreset)")
    }
    
    open func changeAttackAndDecay(attackAndDecay: Float) {
        mySynth.attackDuration = AUValue(4*attackAndDecay)
        mySynth.decayDuration = AUValue(4*attackAndDecay)
        print("Decay duration: \(mySynth.decayDuration)")
        print("Attack duration: \(mySynth.attackDuration)")
    }
    
    open func changeRelease(release: Float) {
        mySynth.releaseDuration = AUValue(4*release)
        print("Release duration: \(mySynth.releaseDuration)")
    }
    
    open func changeSustain(sustain: Float) {
        mySynth.sustainLevel = AUValue(sustain)
        print("Sustain level: \(mySynth.sustainLevel)")
    }
    
    open func changePhaserRate(phaserRate: Float) {
//        phaserRate value is scaled from 0 to 1 to 24 to 360 to match phaser documentation values
        phaser.lfoBPM = AUValue(phaserRate*336+24)
        print("Phaser lfo BPM: \(phaser.lfoBPM)")
        
    }
    
    open func changePhaserFeedback(phaserFeedback: Float) {
        phaser.feedback = AUValue(phaserFeedback*0.8)
        print("Phaser feedback: \(phaser.feedback)")
    }
    
    open func changeFilterAttackAndDecay(filterAttackAndDecay: Float) {
        mySynth.filterAttackDuration = AUValue(2*filterAttackAndDecay)
        mySynth.filterDecayDuration = AUValue(2*filterAttackAndDecay)
        print("Filter attack: \(mySynth.filterAttackDuration)")
        print("Filter decay: \(mySynth.filterDecayDuration)")
    }
    
    open func changeFilterResonance(filterResonance: Float) {
        mySynth.filterResonance = AUValue(6*filterResonance)
        print("Filter resonance: \(mySynth.filterResonance)")
    }
    
    open func changeFilterSustain(filterSustain: Float) {
        mySynth.filterSustainLevel = AUValue(filterSustain)
        print("Filter sustain: \(mySynth.filterSustainLevel)")
    }
    
    open func changeDelayLowPassCutoff(lowPassCutoff: Float) {
        delay.lowPassCutoff = AUValue(lowPassCutoff*1300+200)
        print("Delay low pass cutoff: \(delay.lowPassCutoff)")
    }
    
    open func changeDelayTime(delayTime: Float) {
        delay.time = AUValue(delayTime)
        print("Delay time: \(delay.time)")
    }
    
//--------------------------Getter functions for UI labels-------------------------------//
    open func getVibratoDepth() -> Float {
        return mySynth.vibratoDepth
    }
    
    open func getReverbAmount() -> Float {
        return reverb.dryWetMix
    }
    
    open func getAttack() -> Float {
        return mySynth.attackDuration
    }
    
    open func getDecay() -> Float {
        return mySynth.decayDuration
    }
    
    open func getRelease() -> Float {
        return mySynth.releaseDuration
    }
    
    open func getSustain() -> Float {
        return mySynth.sustainLevel
    }
    
    open func getPhaserRate() -> Float {
        return phaser.lfoBPM
    }
    
    open func getPhaserFeedback() -> Float {
        return phaser.feedback
    }
    
    open func getFilterAttack() -> Float {
        return mySynth.filterAttackDuration
    }
    
    open func getFilterDecay() -> Float {
        return mySynth.filterDecayDuration
    }
    
    open func getFilterResonance() -> Float {
        return mySynth.filterResonance

    }
    
    open func getFilterSustain() -> Float {
        return mySynth.filterSustainLevel

    }
    
    open func getDelayLowPassCutoff() -> Float {
        return delay.lowPassCutoff

    }
    
    open func getDelayTime() -> Float {
        return delay.time
    }
}
