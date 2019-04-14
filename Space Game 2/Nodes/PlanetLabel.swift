//
//  PlanetLabel.swift
//  Space Game 2
//
//  Created by Aaron Becker on 4/13/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import SpriteKit

class PlanetLabel : SKLabelNode {
    
    weak var planet: Planet!
    
    init(planet: Planet)
    {
        super.init()
        self.planet = planet
        self.text = planet.name
        self.color = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
