//
//  EyesDetection.swift
//  Blink
//
//  Created by khoirunnisa' rizky noor fatimah on 18/09/19.
//  Copyright © 2019 khoirunnisa' rizky noor fatimah. All rights reserved.
//

import AVFoundation
import UIKit
import Vision

var globalTime: CFTimeInterval = 0

var leftArray: [CGFloat] = []
var blinkStatus : Bool?

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
                                                    fatalError("No front video camera available")
        }
        
        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = eyesView.bounds
        previewLayer.bounds = eyesView.bounds
        eyesView.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 1
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 2
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        
        // 3
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func convert(rect: CGRect) -> CGRect {
        // 1
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        // 2
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        // 3
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    // 1
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // 2
        let absolute = point.absolutePoint(in: rect)
        
        // 3
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        // 4
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }
        return points.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.eyesView.setNeedsDisplay()
            }
        }
        
        let box = result.boundingBox
        eyesView.boundingBox = convert(rect: box)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            eyesView.leftEye = leftEye
        }
        
        let leftEyePoints = landmarks.leftEye!.normalizedPoints
        let leftEyePoint1 = leftEyePoints[0]
        let leftEyePoint2 = leftEyePoints[4]
        let leftDistanceX = leftEyePoint1.x - leftEyePoint2.x
        let leftDistanceY = leftEyePoint1.y - leftEyePoint2.y
        let leftDistance = sqrt(leftDistanceX * leftDistanceX + leftDistanceY * leftDistanceY)
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            eyesView.rightEye = rightEye
        }
        
//        let rightEyePoints = landmarks.rightEye!.normalizedPoints
//        let rightEyePoint1 = rightEyePoints[0]
//        let rightEyePoint2 = rightEyePoints[4]
//        let rightDistanceX = rightEyePoint1.x - rightEyePoint2.x
//        let rightDistanceY = rightEyePoint1.y - rightEyePoint2.y
//        let rightDistance = sqrt(rightDistanceX * rightDistanceX + rightDistanceY * rightDistanceY)
//        print("left : \(leftDistance)")
//        print("right : \(rightDistance)")
        
        leftArray.append(leftDistance)
        
        compareData()
//        print(globalTime)
//
//
//        if globalTime.remainder(dividingBy: 60/60) == 1/50 {
//            leftArray.append(leftDistance)
//            print(leftArray)
//        }
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        // 1
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            
            else {
                // 2
                eyesView.clear()
                return
        }
        
        updateFaceView(for: result)
    }
    
    func compareData() {
        for i in 1..<leftArray.count {
            if leftArray[i] - leftArray[i-1] > 0.008 {
                blinkStatus = true
                print("------BLINK BOZ")
            } else {
                print("buka mata")
            }
            leftArray.remove(at: i-1)
        }
        
    }
}
