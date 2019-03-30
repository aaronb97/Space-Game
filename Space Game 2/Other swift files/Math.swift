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
}
