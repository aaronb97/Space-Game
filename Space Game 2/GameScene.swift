//
//  GameScene.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/21/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import SpriteKit
import GameplayKit
import Firebase
import FirebaseDatabase

class GameScene: SKScene, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    
    var username: String!
    
    var usernameLabel: UILabel!
    var enterUsernameLabel: UILabel!
    var invalidUsernameLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var textField: UITextField!
    
    var dateString : String!
    
    var rocketX : Int!
    var rocketY : Int!
    var rocketZ : Int!
    var rocket : SKSpriteNode!
    
    var planets : [Planet]!
    var planetList : [String]!
    
    var sceneCam: SKCameraNode!
    
    let coordMultiplier = 100.0
    let AU = 149597871.0
    
    
    override func didMove(to view: SKView) {
        
        sceneCam = SKCameraNode()
        camera = sceneCam
        
        let pinch = UIPinchGestureRecognizer(target: self, action:#selector(self.pinchRecognized(sender:)))
        self.view?.addGestureRecognizer(pinch)
        
        ref = Database.database().reference()
        
        ref.child("users").child((Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: ","))!).observeSingleEvent(of: .value, with: {
            snap in
                if (!snap.exists())
                {
                    self.nicknameSetup()
                }
                else
                {
                    self.loadPlanetlistDatePlanets()

                }
            
        })
        

    }
    
    @objc func pinchRecognized(sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            let deltaScale = (sender.scale - 1.0)*2
            let convertedScale = sender.scale - deltaScale
            let newScale = self.camera!.xScale*convertedScale
            self.camera!.setScale(newScale)
            for planet in planets
            {
                if (newScale > 0.1)
                {
                    planet.lineWidth = newScale
                    if (newScale < 1)
                    {
                        planet.strokeColor = UIColor(white: 1, alpha: newScale)
                    }
                    else{
                        planet.strokeColor = UIColor(white: 1, alpha: 1)
                    }
                }
                else
                {
                    planet.lineWidth = 0
                }
                planet.glowWidth = newScale
            }
            
            sender.scale = 1.0
        }
    }
    
    func loadPlanetlistDatePlanets()
    {
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        loadPlanetList(group)
        loadDate(group)
        
        group.notify(queue: .main) {
            self.loadPlanets()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        usernameLabel.text = textField.text!.filter("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM01234567890".contains)
        usernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - textWidth(text: usernameLabel.text!, font: usernameLabel.font) / 2,
                                     y : enterUsernameLabel.frame.maxY + 3,
                                     width: textWidth(text: usernameLabel.text!, font: usernameLabel.font),
                                     height: 30.0)
        
        invalidUsernameLabel.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (usernameLabel.text == "")
        {
            self.invalidUsernameLabel.text = "Username can't be empty"
            self.invalidUsernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - self.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font) / 2,
                                                     y : self.usernameLabel.frame.maxY + 3,
                                                     width: self.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font),
                                                     height: 30.0)
        }
        else
        {
            ref.child("nicknames").child(usernameLabel.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.exists() && (snapshot.value as! Bool) == true)  //username already exits
                {
                    self.invalidUsernameLabel.text = "Username already taken"
                    self.invalidUsernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - self.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font) / 2,
                                                 y : self.usernameLabel.frame.maxY + 3,
                                                 width: self.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font),
                                                 height: 30.0)
                }
                else
                {                   //username doesn't exist
                    textField.resignFirstResponder()
                    self.username = textField.text
                    self.ref.child("nicknames").child(self.username).setValue(true)
                    self.ref.child("users").child((Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: ","))!).setValue(["position": ["x": 0, "y": 0, "z": 0, "timeUpdated": 0]])
                    self.ref.child("users").child((Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: ","))!).child("nickname").setValue(textField.text!)

                    self.nicknameCleanup()
                    self.loadPlanetlistDatePlanets()
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        return true
    }
    
    func textWidth(text: String, font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }
    
    func nicknameSetup()
    {
        textField = UITextField()
        textField.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: .editingChanged)
        textField.frame = CGRect(x: -50, y: -50, width: 0, height: 0)
        self.view?.addSubview(textField)
        textField.returnKeyType = UIReturnKeyType.done
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.delegate = self
        textField.tag = 1
        
        enterUsernameLabel = UILabel()
        enterUsernameLabel.text = "Enter a username (letters and numbers only):"
        enterUsernameLabel.textColor = UIColor.white
        enterUsernameLabel.font = UIFont(name: enterUsernameLabel.font.fontName, size: 12)
        enterUsernameLabel.tag = 1
        enterUsernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - textWidth(text: enterUsernameLabel.text!, font: enterUsernameLabel.font) / 2,
                                          y : (self.view?.frame.size.height)! / 4,
                                          width: textWidth(text: enterUsernameLabel.text!, font: enterUsernameLabel.font),
                                          height: 30.0)
        
        usernameLabel = UILabel()
        usernameLabel.text = ""
        usernameLabel.textColor = UIColor.white
        usernameLabel.tag = 1
        usernameLabel.frame = CGRect(x: 0,
                                     y : enterUsernameLabel.frame.maxY + 3,
                                     width: 0,
                                     height: 30.0)
        
        invalidUsernameLabel = UILabel()
        invalidUsernameLabel.text = ""
        invalidUsernameLabel.textColor = UIColor.red
        invalidUsernameLabel.tag = 1
        
        self.view?.addSubview(usernameLabel)
        self.view?.addSubview(enterUsernameLabel)
        self.view?.addSubview(invalidUsernameLabel)
        textField.becomeFirstResponder()
    }
    
    func nicknameCleanup()
    {
        for view in (self.view?.subviews)!
        {
            if (view.tag == 1)
            {
                view.removeFromSuperview()
            }
        }
    }
    
    func loadDate(_ group: DispatchGroup )
    {
        planets = [Planet]()
        ref.child("timestamp").setValue(ServerValue.timestamp())
        
        var date : NSDate!
        
        ref.child("timestamp").observeSingleEvent(of: .value, with: {
            snap in
            if let t = snap.value as? TimeInterval {
                // Cast the value to an NSTimeInterval
                // and divide by 1000 to get seconds.
                date = NSDate(timeIntervalSince1970: t/1000)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-M-dd"
                self.dateString = dateFormatter.string(from: date as Date)
            }

            group.leave()
            print("date loaded")
        })
    }
    
    func loadPlanetList( _ group: DispatchGroup)
    {
        ref.child("planetList").observeSingleEvent(of: .value, with: {
            snap in
            self.planetList = snap.value as? [String]
            group.leave()
            print("planet list loaded")
        })
    }
    
    func loadPlanets()
    {
        let group = DispatchGroup()
        
        for planetString in self.planetList
        {
            group.enter()
        
            ref.child("planets").child(planetString).child("positions").child(dateString).observeSingleEvent(of: .value, with: {
                snap in
                let coordDict = snap.value as! [String: String]
                self.ref.child("planets").child(planetString).child("values").observeSingleEvent(of: .value, with: {
                    snap2 in
                    
                    let valueDict = snap2.value as! [String: Any]
                    
                    //print(Int(Double(coordDict["x"]!)! * self.coordMultiplier * self.AU))
                    //print(Int(Double(coordDict["y"]!)! * self.coordMultiplier * self.AU))
                    let planet = Planet(name: planetString,
                                        radius: valueDict["radius"] as! Double,
                                        startingPlanet: valueDict["startingPlanet"] != nil,
                                        x: Int(Double(coordDict["x"]!)! * self.coordMultiplier * self.AU),
                                            y: Int(Double(coordDict["y"]!)! * self.coordMultiplier * self.AU),
                                            z: Int(Double(coordDict["z"]!)! * self.coordMultiplier * self.AU))
                    self.planets.append(planet)
                    print("loaded planet \(planet.name!)")
                    group.leave()
                })
                
                
            })
        }
        
        group.notify(queue: .main) {
            self.drawObjects()
        }
    }
    
    func drawObjects()
    {
        for planet in planets
        {
            if (planet.startingPlanet == true)
            {
                rocket = SKSpriteNode(imageNamed: "rocket.png")
                rocket.size = CGSize(width: 20, height: 40)
                self.addChild(rocket)
                sceneCam.position = CGPoint(x: 0, y: 0)
                rocket.position = sceneCam.position
                
                planet.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -planet.radius / 2, y: 0.0), size: CGSize(width: planet.radius, height: planet.radius)), transform: nil)
                
                planet.position = CGPoint(x: rocket.position.x, y: rocket.position.y - CGFloat(planet.radius))
                planet.fillColor = UIColor.blue
                
                self.addChild(planet)
                
                rocketX = planet.x
                rocketY = planet.y + Int(planet.radius)
                rocketZ = planet.z
            }
        }
        
        for planet in planets
        {
            if (planet.startingPlanet == false)
            {
                planet.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -planet.radius / 2, y: 0.0), size: CGSize(width: planet.radius, height: planet.radius)), transform: nil)
                print(planet.x)
                print(planet.y)
                planet.position = CGPoint(x: Double(planet.x - rocketX) / coordMultiplier, y: Double(planet.y - rocketY) / coordMultiplier)
                
                planet.fillColor = UIColor.white
                
                self.addChild(planet)
            }
        }
    }
    
    override func sceneDidLoad() {

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        
    }
}
