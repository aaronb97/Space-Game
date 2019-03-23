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
    
    var usernameLabel: UILabel!
    var enterUsernameLabel: UILabel!
    var invalidUsernameLabel: UILabel!
    
    var username: String!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var textField: UITextField!
    
    var dateString : String!
    
    var rocketX : Int64!
    var rocketY : Int64!
    var rocketZ : Int64!
    
    var planets : [Planet]!
    var planetList : [String]!
    
    override func didMove(to view: SKView) {
        ref = Database.database().reference()
        
        if (appDelegate.getUsername() == nil)
        {
            usernameSetup()
        }
        else
        {
            loadEverything()
        }
    }
    
    func loadEverything()
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
            ref.child("users").child(textField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.exists())  //username already exits
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
                    self.ref.child("users").child(self.username).setValue(["position": ["x": 0, "y": 0, "z": 0, "timeUpdated": 0]])
                    self.appDelegate.setUsername(self.username)
                    self.usernameCleanup()
                    
                    self.loadEverything()
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
    
    func usernameSetup()
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
    
    func usernameCleanup()
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
        group.enter()
        ref.child("timestamp").setValue(ServerValue.timestamp())
        
        var date : NSDate!
        
        ref.child("timestamp").observe(.value, with: {
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
        })
    }
    
    func loadPlanetList( _ group: DispatchGroup)
    {
        ref.child("planetList").observe(.value, with: {
            snap in
            self.planetList = snap.value as? [String]
            group.leave()
        })
    }
    
    func loadPlanets()
    {
        for planetString in self.planetList
        {
            ref.child("planets").child(planetString).child("positions").child(dateString).observe(.value, with: {
                snap in
                let coordDict = snap.value as! [String: String]
                self.ref.child("planets").child(planetString).child("values").observe(.value, with: {
                    snap2 in
                    
                    let valueDict = snap2.value as! [String: Any]
                    
                    let planet = Planet(name: planetString,
                                        radius: Double(valueDict["radius"] as! Int),
                                        currentPlanet: true,
                                        x: Int64(Double(coordDict["x"]!)!),
                                            y: Int64(Double(coordDict["y"]!)!),
                                            z: Int64(Double(coordDict["z"]!)!))
                    self.planets.append(planet)
                    print("loaded planet \(planet.name!)")
                })
            })
        }
    }
    
    override func sceneDidLoad() {

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        
    }
}
