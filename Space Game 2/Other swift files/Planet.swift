
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
    
    init(name: String, radius: Double, startingPlanet: Bool, x: Int, y: Int, z: Int) {
        
        self.radius = radius
        self.startingPlanet = startingPlanet
        
        super.init()
        
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -radius / 2, y: -radius / 2), size: CGSize(width: radius, height: radius)), transform: nil)
        
        self.strokeColor = UIColor.white
        self.name = name
        
        self.x = x
        self.y = y
        self.z = z

        //self.position = getCoordinates(filename: self.name!, dateString: dateFormatter.string(from: Date()))
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
