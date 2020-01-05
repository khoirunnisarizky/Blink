//
//  EyesView.swift
//  Blink
//
//  Created by khoirunnisa' rizky noor fatimah on 18/09/19.
//  Copyright © 2019 khoirunnisa' rizky noor fatimah. All rights reserved.
//

import UIKit
import Vision

class EyesView: UIView {
    var leftEye: [CGPoint] = []
    var rightEye: [CGPoint] = []
    
    var boundingBox = CGRect.zero

    
    
    func clear() {
        leftEye = []
        rightEye = []
        
        boundingBox = .zero
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        defer {
            context.restoreGState()
        }
        
        context.addRect(boundingBox)
        
        UIColor.red.setStroke()
        
        context.strokePath()
        
        UIColor.white.setStroke()
        
        if !leftEye.isEmpty {
            // 2
            context.addLines(between: leftEye)
            
            // 3
            context.closePath()
            
            // 4
            context.strokePath()
        }
        
        if !rightEye.isEmpty {
            context.addLines(between: rightEye)
            context.closePath()
            context.strokePath()
        }
        
    }

}
