
//
//  File.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/22/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Planet: SKShapeNode {
    var radius: Double!
    var startingPlanet: Bool!
    var x: Int!
    var y: Int!
    var z: Int!
    var distance: Double!
    var visitorDict: [String: Bool]!
    var color: UIColor!
    var type: String!
    
    init(name: String, radius: Double, startingPlanet: Bool, x: Int, y: Int, z: Int, color: UIColor!, type: String!) {
        
        self.radius = radius
        self.startingPlanet = startingPlanet
        self.type = type
        
        super.init()
        
        self.color = color
        self.fillColor = (color != nil ? color : .moonColor)!
        
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -radius / 2, y: -radius / 2), size: CGSize(width: radius, height: radius)), transform: nil)
        
        self.strokeColor = (color != nil ? color!.lighter() : .moonColor)!
        
        self.name = name
        
        self.x = x
        self.y = y
        self.z = z
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
    static let spaceColor = Math.hexStringToUIColor(hex: "0b1435")
    static let moonColor = Math.hexStringToUIColor(hex: "adadad")
}
