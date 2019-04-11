//
//  Console.swift
//  Space Game 2
//
//  Created by Aaron Becker on 4/10/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import UIKit

class ConsoleView: UIView {
    
    var speedLabel = UILabel()
    var timeToDestLabel = UILabel()
    var timeToSpeedBoostLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(speedLabel)
        formatLabel(speedLabel)
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        speedLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        speedLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        speedLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(timeToDestLabel)
        formatLabel(timeToDestLabel)
        timeToDestLabel.translatesAutoresizingMaskIntoConstraints = false
        timeToDestLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        timeToDestLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 5).isActive = true
        timeToDestLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        timeToDestLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(timeToSpeedBoostLabel)
        formatLabel(timeToSpeedBoostLabel)
        timeToSpeedBoostLabel.translatesAutoresizingMaskIntoConstraints = false
        timeToSpeedBoostLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        timeToSpeedBoostLabel.topAnchor.constraint(equalTo: timeToDestLabel.bottomAnchor, constant: 5).isActive = true
        timeToSpeedBoostLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        timeToSpeedBoostLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    public override func draw(_ frame: CGRect) {

        let color:UIColor = .white
        let drect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let bpath:UIBezierPath = UIBezierPath(rect: drect)
        color.set()
        bpath.stroke()
        
        
        NSLog("drawRect has updated the view")
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func formatLabel(_ label: UILabel)
    {
        label.font = UIFont(name: "Courier", size: 13)
        label.textColor = .white
        label.numberOfLines = 2
    }
    
}

