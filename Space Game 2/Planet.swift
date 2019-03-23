
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
    var currentPlanet: Bool!
    var x: Int64!
    var y: Int64!
    var z: Int64!
    
    
    
    init(name: String, radius: Double, currentPlanet: Bool, x: Int64, y: Int64, z: Int64) {
        
        self.radius = radius
        self.currentPlanet = currentPlanet
        
        super.init()
        
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -radius / 2, y: 0.0), size: CGSize(width: radius, height: radius)), transform: nil)
        
        self.strokeColor = UIColor.white
        self.name = name
        

        //self.position = getCoordinates(filename: self.name!, dateString: dateFormatter.string(from: Date()))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
