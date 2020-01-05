//
//  heartRateController.swift
//  Blink
//
//  Created by khoirunnisa' rizky noor fatimah on 18/09/19.
//  Copyright © 2019 khoirunnisa' rizky noor fatimah. All rights reserved.
//

import UIKit
import HealthKit
import AVFoundation

var blinkCounter : Int = 0
var timeLeft = 4
var timeLeftFor = 1 //step

extension ViewController {
    
    func updateHeartRateCondition(){
        if heartRateNumber! > 100 {
            heartRateConditionLabel.text = "HIGH"
            sayHeartRateFeedback()
        } else {
            heartRateConditionLabel.text = "NORMAL"
        }
    }
    
    func startMockHeartData() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(subscribeToHeartBeatChanges),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    
    @objc func subscribeToHeartBeatChanges(){
        // Creating the sample for the heart rate
        
       
        /// Creating an observer, so updates are received whenever HealthKit’s
        
        
        /// When the completion is called, an other query is executed
        /// to fetch the latest heart rate
        self.seconds += 1     //This will decrement(count down)the seconds.
        self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds))
        
        if blinkStatus == true {
            blinkCounter += 1
            blinkCounterLabel.text = "\(blinkCounter)"
            blinkStatus = false
        }
        
        if seconds % 15 == 0 {
            giveBlinkFeedback()
            blinkCounter = 0
            blinkCounterLabel.text = "\(blinkCounter)"
        }
    
        fetchLatestHeartRateSample(completion: { sample in
            guard let sample = sample else {
                return
            }
            /// The completion in called on a background thread, but we
            /// need to update the UI on the main.
            DispatchQueue.main.async {
                /// Converting the heart rate to bpm
                let heartRateUnit = HKUnit(from: "count/min")
                let heartRate = sample
                    .quantity
                    .doubleValue(for: heartRateUnit)
                /// Updating the UI with the retrieved value
                
                self.heartRateLabel.text = "\(Int(heartRate))"
                self.heartRateNumber = Int(heartRate)
                self.updateHeartRateCondition()
                self.detik+=1
            }
        })
    }
    
    func fetchLatestHeartRateSample(
        completion: @escaping (_ sample: HKQuantitySample?) -> Void) {
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: .heartRate) else {
                completion(nil)
                return
        }
        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate)
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { (_, results, error) in
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                completion(results?[0] as? HKQuantitySample)
        }
        healthKitStore.execute(query)
    }
    
    func sayHeartRateFeedback()
    {
        //feedback suara
        let string = "Your heart rate is too high"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        
        //invalidate timer
        guard let timer = timer else { return }
        timer.invalidate()
        
        //alert feedback
        let alert = UIAlertController(title: "Your heart rate is too high!", message: "Take a deep breath for a while with 4-7-8 method.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.getFeedback()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func getFeedback(){
        self.timerView.isHidden = false
        self.timerViewLabel.text = "\(timeLeft)"
        //feedback suara
        if timeLeft == 4 {
            let string = "Take a breath in 4 seconds"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        } else if timeLeft == 7 {
            let string = "Hold in 7 seconds"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        } else if timeLeft == 8 {
            let string = "Release in 8 seconds"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "eng-ID")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }
        
        self.countdown()
        
    }
    
    func countdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            timeLeft = timeLeft - 1
            self.timerViewLabel.text = "\(timeLeft)"
            if timeLeft <= 0 {
                switch timeLeftFor {
                case 1:
                    timeLeft = 7
                    timeLeftFor = 2
                    Timer.invalidate()
                    self.getFeedback()
                case 2:
                    timeLeft = 8
                    timeLeftFor = 3
                    Timer.invalidate()
                    self.getFeedback()
                case 3:
                    timeLeft = 4
                    timeLeftFor = 1
                    self.timerView.isHidden = true
                    Timer.invalidate()
                    self.startMockHeartData()
                default:
                    return
                }
            }
        })
    }
}
