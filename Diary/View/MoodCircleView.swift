//
//  MoodCircleView.swift
//  Diary
//
//  Created by Stephen McMillan on 15/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

@IBDesignable class MoodCircleView: UIView {
    
    var moodLevel: Int = 5 {
        didSet {
            // If the mood level is changed then update the moodView
            // Only update the view if there's a valid mood level
            print(moodLevel)
            guard (1...10).contains(moodLevel) else { return}
            
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
                
        let centerPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        
        let startAngle = (3 * Float.pi)/2// Radians (0deg)
        let endAngle = startAngle + (Float.pi * 2) // 360deg (full circle)
        let lineWidth = CGFloat(16.0)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.white.cgColor
        
        shapeLayer.path = UIBezierPath(arcCenter: centerPoint, radius: bounds.width/2 - lineWidth/2, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true).cgPath
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        
        let mood = CGFloat(moodLevel) / 10.0
        
        // Changes the colour of the stroke depending on the mood level.
        switch mood {
        case 0..<0.33:
            shapeLayer.strokeColor = #colorLiteral(red: 0.9882352941, green: 0.3607843137, blue: 0.3960784314, alpha: 1)
        case 0.33..<0.66:
            shapeLayer.strokeColor = #colorLiteral(red: 0.9921568627, green: 0.5882352941, blue: 0.2666666667, alpha: 1)
        case 0.66...1.0:
            shapeLayer.strokeColor = #colorLiteral(red: 0.1490196078, green: 0.8705882353, blue: 0.5058823529, alpha: 1)
        default:
            break
        }
        
        if mood > 0 {
            shapeLayer.strokeEnd = mood
        } else {
            shapeLayer.strokeColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            shapeLayer.strokeEnd = 1.0
        }
        
        layer.addSublayer(shapeLayer) 
    }
}
