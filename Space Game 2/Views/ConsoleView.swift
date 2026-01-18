//
//  Console.swift
//  Space Game 2
//
//  Created by Aaron Becker on 4/10/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import UIKit

class ConsoleView: UIView, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let speedLabel = UILabel()
    let timeToDestLabel = UILabel()
    let timeToSpeedBoostLabel = UILabel()
    let notificationLabel = UILabel()
    var notificationTimer : Timer!
    weak var gameScene: GameScene!
    let pickerView = UIPickerView()
    var planetArray = [Planet]()
    let infoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(speedLabel)
        formatLabel(speedLabel)
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        speedLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        speedLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        speedLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(timeToDestLabel)
        formatLabel(timeToDestLabel)
        timeToDestLabel.translatesAutoresizingMaskIntoConstraints = false
        timeToDestLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        timeToDestLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 5).isActive = true
        timeToDestLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        timeToDestLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(timeToSpeedBoostLabel)
        formatLabel(timeToSpeedBoostLabel)
        timeToSpeedBoostLabel.translatesAutoresizingMaskIntoConstraints = false
        timeToSpeedBoostLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        timeToSpeedBoostLabel.topAnchor.constraint(equalTo: timeToDestLabel.bottomAnchor, constant: 5).isActive = true
        timeToSpeedBoostLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        timeToSpeedBoostLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(notificationLabel)
        formatLabel(notificationLabel, color: UIColor.yellow)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        notificationLabel.topAnchor.constraint(equalTo: timeToSpeedBoostLabel.bottomAnchor, constant: 5).isActive = true
        notificationLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -5).isActive = true
        notificationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        pickerView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        addSubview(pickerView)
        pickerView.frame.size.width = self.frame.width
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        pickerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.66).isActive = true
        
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        infoLabel.topAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        infoLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.33).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        formatLabel(infoLabel, fontSize: 16, numberOfLines: 6)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    @objc func resetNotification()
    {
        notificationLabel.text = ""
    }
    
    func setNotification(_ text: String)
    {
        notificationLabel.text = text
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(resetNotification), userInfo: nil, repeats: false)
    }
    
    public override func draw(_ frame: CGRect) {
        let color:UIColor = .white
        let drect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let bpath:UIBezierPath = UIBezierPath(rect: drect)
        color.set()
        bpath.stroke()
    }
    
    convenience init(gameScene: GameScene)
    {
        self.init(frame: CGRect.zero)
        self.gameScene = gameScene
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func preparePlanetList()
    {
        setView(view: speedLabel, hide: true)
        setView(view: notificationLabel, hide: true)
        setView(view: timeToDestLabel, hide: true)
        setView(view: timeToSpeedBoostLabel, hide: true)
        setView(view: infoLabel, hide: false)
        
        planetArray = Array(gameScene.planetDict.values)
        planetArray.sort(by: {$0.distance < $1.distance})
        pickerView.reloadAllComponents()
        setView(view: pickerView, hide: false)
        pickerView.selectRow(0, inComponent: 0, animated: false)
        selectPlanet(planetArray[0], row: 0)
    }
    
    func prepareGo()
    {
        setView(view: speedLabel, hide: false)
        setView(view: notificationLabel, hide: false)
        setView(view: timeToDestLabel, hide: false)
        setView(view: timeToSpeedBoostLabel, hide: false)
        setView(view: pickerView, hide: true)
        setView(view: infoLabel, hide: true)

        planetArray = [Planet]()
    }
    
    func formatLabel(_ label: UILabel, color: UIColor = UIColor.white, fontSize: CGFloat = 15, numberOfLines: Int = 2)
    {
        label.font = UIFont(name: "Courier", size: fontSize)
        label.textColor = color
        label.numberOfLines = numberOfLines
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return planetArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return planetArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Courier", size: 22)
            pickerLabel?.textAlignment = .center
        }
        if row < planetArray.count
        {
            let planet = planetArray[row]
            pickerLabel?.text = planet.name
            pickerLabel?.textColor = planet.color.lighter()
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if row < planetArray.count
        {
            selectPlanet(planetArray[row], row: row)
        }
    }
    
    func selectPlanet(_ planet: Planet, row: Int)
    {
        setView(view: infoLabel, hide: true)
        infoLabel.text = ""
        infoLabel.text?.append("\nDistance: \(formatDistance(planet.distance))")
        if let type = planet.type
        {
            infoLabel.text?.append("\nType: \(type)")
        }
        
        if let radius = planet.radius
        {
            infoLabel.text?.append("\nRadius: \(formatDistance(radius))")
        }
    
        if gameScene.currentPlanet == planet
        {
            infoLabel.text?.append("\nYou are here")
        }
        else if gameScene.travelingTo == planet
        {
            infoLabel.text?.append("\nYou are traveling here")
        }
    
        if gameScene.traveledToDict[planet.name!] == true && planet != gameScene.currentPlanet
        {
            infoLabel.text?.append("\nYou have been here")
        }
    
        if planet != gameScene.currentPlanet && planet != gameScene.travelingTo
        {
            gameScene.planetSelection = planet
            setView(view: gameScene.goButton, hide: true)
            gameScene.goButton.setTitle("\(gameScene.goToOrDestroy) \(planet.name!)", for: .normal)
            setView(view: gameScene.goButton, hide: false)
        }
        else
        {
            setView(view: gameScene.goButton, hide: true)
        }
        setView(view: infoLabel, hide: false)
    }
}

