//
//  ViewController.swift
//  Blink
//
//  Created by khoirunnisa' rizky noor fatimah on 18/09/19.
//  Copyright © 2019 khoirunnisa' rizky noor fatimah. All rights reserved.
//

import UIKit
import HealthKit
import AVFoundation
import Vision
import LocalAuthentication

let healthKitStore : HKHealthStore = HKHealthStore()

class ViewController: UIViewController {

    //timer counter and heart rate
    var timer: Timer?
    var seconds = 0
    var detik = 0
    var heartRateNumber : Int?
    
    //Eyes Detection
    var sequenceHandler = VNSequenceRequestHandler()
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0
    var isFiring:Bool = false
    
    //outlet utama
    @IBOutlet weak var timerViewLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eyeConditionLabel: UILabel!
    @IBOutlet weak var blinkCounterLabel: UILabel!
    @IBOutlet weak var heartRateConditionLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    //eyesView eyes detection
    @IBOutlet weak var eyesView: EyesView!
    
    //start-finish action
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        
        if isFiring == false {
            
            isFiring = true
            actionButton.setTitle("FINISH", for: .normal)
            startMockHeartData()
            print(isFiring)
            
        } else if isFiring == true {
            isFiring = false
            actionButton.setTitle("START", for: .normal)
            seconds = 0
            timeLabel.text = "00:00"
            if timer != nil {
                self.timer!.invalidate()
            }
            heartRateConditionLabel.text = "RATE"
            heartRateLabel.text = "0"
            blinkCounterLabel.text = "0"
        
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.Authenticate { (success) in
            print(success)
        }
        authorizeHealthKitInApp()
        timerView.isHidden = true
        
        //rounded eyesView
        self.eyesView.layer.cornerRadius = 50
        
        //configure to eyes detection
        configureCaptureSession()
        
        maxX = eyesView.bounds.maxX
        midY = eyesView.bounds.midY
        maxY = eyesView.bounds.maxY
        
        session.startRunning()
        
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func authorizeHealthKitInApp() {
        let healthKitTypesToRead : Set<HKObjectType> = [ HKObjectType.quantityType(forIdentifier: .heartRate)!]
        
        let healthKitTypesToWrite : Set<HKSampleType> = []
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("Error occured")
            return
        }
        
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            print("Read Write Authorization succeded")
        }
        
    }
    
    func Authenticate(completion: @escaping ((Bool) -> ())){
        
        //Create a context
        let authenticationContext = LAContext()
        var error:NSError?
        
        //Check if device have Biometric sensor
        let isValidSensor : Bool = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if isValidSensor {
            //Device have BiometricSensor
            //It Supports TouchID
            
            authenticationContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Touch / Face ID authentication",
                reply: { [unowned self] (success, error) -> Void in
                    
                    if(success) {
                        // Touch / Face ID recognized success here
                        completion(true)
                    } else {
                        //If not recognized then
                        if let error = error {
                            let strMessage = self.errorMessage(errorCode: error._code)
                            if strMessage != ""{
                                self.showAlertWithTitle(title: "Error", message: strMessage)
                            }
                        }
                        completion(false)
                    }
            })
        } else {
            
            let strMessage = self.errorMessage(errorCode: (error?._code)!)
            if strMessage != ""{
                self.showAlertWithTitle(title: "Error", message: strMessage)
            }
        }
        
    }
    
    //MARK: TouchID error
    func errorMessage(errorCode:Int) -> String{
        
        var strMessage = ""
        
        switch errorCode {
            
        case LAError.Code.authenticationFailed.rawValue:
            strMessage = "Authentication Failed"
            
        case LAError.Code.userCancel.rawValue:
            strMessage = "User Cancel"
            
        case LAError.Code.systemCancel.rawValue:
            strMessage = "System Cancel"
            
        case LAError.Code.passcodeNotSet.rawValue:
            strMessage = "Please goto the Settings & Turn On Passcode"
            
        case LAError.Code.biometryNotAvailable.rawValue:
            strMessage = "TouchI or FaceID DNot Available"
            
        case LAError.Code.biometryNotEnrolled.rawValue:
            strMessage = "TouchID or FaceID Not Enrolled"
            
        case LAError.Code.biometryLockout.rawValue:
            strMessage = "TouchID or FaceID Lockout Please goto the Settings & Turn On Passcode"
            
        case LAError.Code.appCancel.rawValue:
            strMessage = "App Cancel"
            
        case LAError.Code.invalidContext.rawValue:
            strMessage = "Invalid Context"
            
        default:
            strMessage = ""
            
        }
        return strMessage
    }

    //MARK: Show Alert
    func showAlertWithTitle( title:String, message:String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
}

