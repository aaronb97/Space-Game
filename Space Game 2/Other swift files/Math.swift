//
//  Math.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/30/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import GameplayKit

class Math {
    
    static let AU = 149597871.0
    static let framesPerHour : Double = 216000
    static let millisecondsPerHour : Double = 3600000
    static let secondsPerHour : Double = 3600
    
    static func angleBetween(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return atan2(y2 - y1, x2 - x1)
    }
    
    static func textWidth(text: String, font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }
    
    static func distance(x1: Double, x2: Double, y1: Double, y2: Double) -> Double
    {
        return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
    }
    
    static func distance(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) -> Double
    {
        return Double(sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)))
    }
    
    static func formatDistance(_ distance: Double) -> String
    {
        if distance > 1000000000
        {
            return String(format: "%1.1f billion km", distance / 1000000000)
        }
        else if distance > 1000000
        {
            return String(format: "%1.1f million km", distance / 1000000)
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return "\(numberFormatter.string(from: NSNumber(value: Int(distance)))!) km"
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


