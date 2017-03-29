//
//  Speaker.swift
//  FightingCam
//
//  Created by Nam Pham on 3/29/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol SpeakerDelegate {
    @objc optional func startSpeaker()
    @objc optional func stopSpeaker()
}

class Speaker: NSObject {
    
    let synth = AVSpeechSynthesizer()
    
    weak var delegate: SpeakerDelegate?
    
    //create protocol with 2 function start and stop mp3
    
    override init() {
        super.init()
        synth.delegate = self
    }
    
    func speak(_ announcement: String, in language: String) {
        print("speak announcement in language \(language) called")
        prepareAudioSession()
        let utterance = AVSpeechUtterance(string: announcement.lowercased())
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synth.speak(utterance)
    }
    
    func setMyDelegate(_ delegate: SpeakerDelegate){
        self.delegate = delegate
    }
    
    private func prepareAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, with: .mixWithOthers)
        } catch {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    func stop() {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        }
    }
}


extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Speaker class started")
        self.delegate?.startSpeaker!()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Speaker class finished")
        self.delegate?.stopSpeaker!()
    }
}
