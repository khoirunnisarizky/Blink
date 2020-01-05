//
//  EyesBlinkCounter.swift
//  Blink
//
//  Created by khoirunnisa' rizky noor fatimah on 19/09/19.
//  Copyright © 2019 khoirunnisa' rizky noor fatimah. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

extension ViewController {
    
    func giveBlinkFeedback() {
        if blinkCounter < 6 {
            view.backgroundColor = UIColor(red: 226/255, green: 82/255, blue: 49/255, alpha: 1.0)
            
            //feedback suara
            let string = "Your eyes are dry! Close your eyes in 5 seconds."
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
            
            //invalidate timer
            guard let timer = timer else { return }
            timer.invalidate()
            
            var timeLeft = 5
            //alert feedback
            let alert = UIAlertController(title: "Your eyes are dry!", message: "Close your eyes in 5 seconds", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.timerView.isHidden = false
                self.timerViewLabel.text = "\(timeLeft)"
                
                let countdown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
                    timeLeft = timeLeft - 1
                    self.timerViewLabel.text = "\(timeLeft)"
                    if timeLeft <= 0 {
                        timeLeft = 0
                        self.timerView.isHidden = true
                        Timer.invalidate()
                        self.startMockHeartData()
                    }
                })
            }))
            present(alert, animated: true, completion: nil)
        }
        else if blinkCounter > 5 && blinkCounter < 10 {
            view.backgroundColor = UIColor(red: 248/255, green: 228/255, blue: 34/255, alpha: 1.0)
            let string = "Be Cautious! Lets blink more!"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }
        else {
            view.backgroundColor = UIColor(red: 175/255, green: 253/255, blue: 78/255, alpha: 1.0)
            let string = "Great! Keep Going"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }
    }
    
    
}
