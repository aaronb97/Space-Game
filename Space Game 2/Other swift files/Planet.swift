
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
    var distance: Double!
    var visitorDict: [String: Bool]!
    var color: UIColor!
    var type: String!
    
    init(name: String, radius: Double, startingPlanet: Bool, x: Int, y: Int, color: UIColor!, type: String!) {
        
        self.radius = radius
        self.startingPlanet = startingPlanet
        self.type = type
        
        super.init()
        
        self.color = color
        
        self.fillColor = (color != nil ? color : .moonColor)!
        
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -radius, y: -radius),
                        size: CGSize(width: radius * 2, height: radius * 2)),
                           transform: nil)
        
        self.strokeColor = (color != nil ? color : .moonColor)!
        
        self.name = name
        
        self.x = x
        self.y = y
    }
    
    func calculateDistance(x: Int, y: Int)
    {
        distance = Space_Game_2.distance(x1: CGFloat(x),
                                 x2: CGFloat(self.x),
                                 y1: CGFloat(y),
                                 y2: CGFloat(self.y)) / coordMultiplier - radius
        if (distance < 0)
        {
            distance = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
