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

class GameScene: SKScene, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var xPositionLabel: UILabel!
    var yPositionLabel: UILabel!
    var zPositionLabel: UILabel!
    var xVelocityLabel: UILabel!
    var yVelocityLabel: UILabel!
    var zVelocityLabel: UILabel!

    var ref: DatabaseReference!
    
    var username: String!
    
    var usernameLabel: UILabel!
    var enterUsernameLabel: UILabel!
    var invalidUsernameLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var textField: UITextField!
    
    var dateString : String!
    
    var positionX : Int!
    var positionY : Int!
    var positionZ : Int!
    var velocityX = 0.0
    var velocityY = 0.0
    var velocityZ = 0.0
    
    
    var velocity = 0 {
        didSet {
            speedLabel.text = "Speed: \(velocity) km / hour"
            speedLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - Math.textWidth(text: self.speedLabel.text!, font: self.speedLabel.font) / 2,
                                      y: 5 * (self.view?.frame.height)! / 8,
                                      width: 200,
                                      height: Math.textWidth(text: self.speedLabel.text!, font: self.speedLabel.font))

        }
    }
    var baseVelocity = 50000
    
    var rocket : SKSpriteNode!
    var coordinatesSet = false
    var travelingToName: String!
    var currentPlanetName: String!
    
    var planets : [Planet]!
    var planetList : [String]!
    
    var sceneCam: SKCameraNode!
    
    var planetListTableView : UITableView!

    var setACourseButton: UIButton!
    var goButton: UIButton!
    
    var planetSelection: Planet!
    var travelingTo: Planet!
    var currentPlanet : Planet!
    
    let coordMultiplier = 100.0
    
    var email: String!
    var timestamp : Int!
    
    var pushTimer: Timer!
    var localTime: TimeInterval!
    
    var traveledTo = [String: Bool]()
    var speedLabel = UILabel()
    
    override func didMove(to view: SKView) {
        
        self.view?.backgroundColor = .spaceColor
        self.view?.window?.backgroundColor = .spaceColor
        self.backgroundColor = .spaceColor
        sceneCam = SKCameraNode()
        camera = sceneCam
        
        let pinch = UIPinchGestureRecognizer(target: self, action:#selector(self.pinchRecognized(sender:)))
        self.view?.addGestureRecognizer(pinch)
        
        ref = Database.database().reference()
        email = Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: ",")
        
        ref.child("users").child(email).observeSingleEvent(of: .value, with: {
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
        
        planetListTableView = UITableView(frame: CGRect(x:20, y: 20 , width: self.view!.frame.width - 40, height: self.view!.frame.height / 1.5))
        planetListTableView.rowHeight = CGFloat(100)
        self.scene?.view?.addSubview(planetListTableView)
        planetListTableView.delegate = self
        planetListTableView.dataSource = self
        planetListTableView.isHidden = true
        
        setACourseButton = UIButton()
        setACourseButton.setTitle("Set a Course", for: .normal)
        let setACourseButtonWidth = 130.0
        setACourseButton.frame = CGRect(x: (self.view?.center.x)! - CGFloat(setACourseButtonWidth / 2), y: self.view!.frame.height / 4, width: CGFloat(setACourseButtonWidth), height: CGFloat(30.0))
        formatButton(setACourseButton)
        
        goButton = UIButton()
        goButton.setTitle("Go!", for: .normal)
        let goButtonWidth = 150
        goButton.frame = CGRect(x: (self.view?.center.x)! - CGFloat(goButtonWidth / 2), y: planetListTableView.frame.maxY + 20, width: CGFloat(goButtonWidth), height: CGFloat(30.0))
        formatButton(goButton)
        goButton.isHidden = true
        
        speedLabel.textColor = .white
        self.view?.addSubview(speedLabel)
        
        velocityX = 0.0
        velocityY = 0.0
        velocityZ = 0.0
        planets = [Planet]()

        localTime = Date().timeIntervalSinceReferenceDate
        
        ref.child("timestamp").observe(.value, with: {
            snap in
                self.timestamp = snap.value as? Int
            print("timestamp set: \(self.timestamp!)")
        })
    }
    
    func addDebugLabels()
    {
        xPositionLabel = UILabel()
        yPositionLabel = UILabel()
        zPositionLabel = UILabel()
        xVelocityLabel = UILabel()
        yVelocityLabel = UILabel()
        zVelocityLabel = UILabel()
        
        let labelHeight = 15.0
        xPositionLabel.frame = CGRect(x: 0, y: (self.view?.center.y)! + 30, width: (self.view?.frame.width)!, height: CGFloat(labelHeight))
        yPositionLabel.frame = CGRect(x: 0, y: xPositionLabel.frame.maxY + 2, width: (self.view?.frame.width)!, height: CGFloat(labelHeight))
        zPositionLabel.frame = CGRect(x: 0, y: yPositionLabel.frame.maxY + 2, width: (self.view?.frame.width)!, height: CGFloat(labelHeight))
        xVelocityLabel.frame = CGRect(x: 0, y: zPositionLabel.frame.maxY + 2, width: (self.view?.frame.width)!, height: CGFloat(labelHeight))
        yVelocityLabel.frame = CGRect(x: 0, y: xVelocityLabel.frame.maxY + 2, width: (self.view?.frame.width)!, height: CGFloat(labelHeight))
        zVelocityLabel.frame = CGRect(x: 0, y: yVelocityLabel.frame.maxY + 2, width: (self.view?.frame.width)!, height: CGFloat(labelHeight))
        
        formatNumberLabel(xPositionLabel)
        formatNumberLabel(yPositionLabel)
        formatNumberLabel(zPositionLabel)
        formatNumberLabel(xVelocityLabel)
        formatNumberLabel(yVelocityLabel)
        formatNumberLabel(zVelocityLabel)
        
        self.view?.addSubview(xPositionLabel)
        self.view?.addSubview(yPositionLabel)
        self.view?.addSubview(zPositionLabel)
        self.view?.addSubview(xVelocityLabel)
        self.view?.addSubview(yVelocityLabel)
        self.view?.addSubview(zVelocityLabel)
    }
    
    func formatNumberLabel(_ label: UILabel)
    {
        label.textColor = UIColor.white
        label.font = UIFont(name: "Courier", size: 13)
    }
    
    func formatButton(_ button: UIButton)
    {
        button.setTitleColor(UIColor.white, for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action:#selector(buttonPressed), for: .touchUpInside)
        button.backgroundColor = UIColor(white: 1, alpha: 0.1)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func buttonPressed(sender: UIButton)
    {
        if (sender == setACourseButton)
        {
            setACourseButton.isHidden = true
            planetListTableView.isHidden = false
            speedLabel.isHidden = true
            
            for planet in planets {
                planet.distance = Math.distance(x1: Double(positionX) / coordMultiplier,
                                                x2: Double(planet.x)  / coordMultiplier,
                                                y1: Double(positionY) / coordMultiplier,
                                                y2: Double(planet.y)  / coordMultiplier)
            }
            
            planets.sort(by: {$0.distance < $1.distance})
            
            planetListTableView.reloadData()
        }
        else if (sender == goButton)
        {
            goButton.isHidden = true
            planetListTableView.isHidden = true
            setACourseButton.isHidden = false

            speedLabel.isHidden = false
            travelingTo = planetSelection
            planetSelection = nil
            currentPlanet = nil
            
            velocity = 50000
            calculateVelocities()
            pushPositionToServer()
        }
    }
    
    func calculateVelocities()
    {
        let Bx = rocket.position.x
        let By = rocket.position.y
        let Ax = travelingTo.position.x
        let Ay = travelingTo.position.y
        let r = travelingTo.radius
        let denom = sqrt(pow(Bx - Ax, 2) + pow(By - Ay, 2))
        let travelingToPointx = Ax + CGFloat(r!) * (Bx - Ax) / denom
        let travelingToPointy = Ay + CGFloat(r!) * (By - Ay) / denom
        
        
        if (abs(travelingToPointx) < 1 && abs(travelingToPointy) < 1) //touch down on a planet
        {
            velocityX = 0
            velocityY = 0
            velocityZ = 0
            currentPlanet = travelingTo
            travelingTo = nil
            rocket.zRotation = Math.angleBetween(x1: rocket.position.x, y1: rocket.position.y, x2: currentPlanet.position.x, y2: currentPlanet.position.y) + .pi / 2
            
            if (traveledTo[currentPlanet.name!] == nil)
            {
                addVisitorToPlanet(currentPlanet.name!)
            }
            
            traveledTo[currentPlanet.name!] = true
            pushTraveledToDict()
            velocity = 0
            pushPositionToServer()
        }
        else
        {
            let phi = Math.angleBetween(x1: CGFloat(positionY!), y1: CGFloat(positionZ!), x2: CGFloat(travelingTo.y), y2: CGFloat(travelingTo.z))
            let theta = Math.angleBetween(x1: rocket.position.x, y1: rocket.position.y, x2: travelingToPointx, y2: travelingToPointy)
            rocket.zRotation = theta - .pi / 2
            
            velocityX = Double(cos(theta) * abs(cos(phi)) * CGFloat(velocity)) * coordMultiplier
            velocityY = Double(sin(theta) * abs(cos(phi)) * CGFloat(velocity)) * coordMultiplier
            velocityZ = Double(sin(phi) * CGFloat(velocity)) * coordMultiplier
        }
    }
    
    func pushTraveledToDict()
    {
        ref.child("users/\(email!)/data/traveledTo").setValue(traveledTo)
    }
    
    func addVisitorToPlanet(_ name: String)
    {
        let planet = planetWithName(name)
        if (planet?.visitorDict[self.username] != true)
        {
            planet?.visitorDict[self.username] = true
            traveledTo[name] = true
            self.ref.child("planets/\(name)/values/visitors/\(self.username!)").setValue(true)
            print("added visitor \(username!) to \(name)")
            pushTraveledToDict()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if (!(planets[indexPath.row] == currentPlanet))
        {
            planetSelection = planets[indexPath.row]
            goButton.isHidden = false
            goButton.setTitle("Go to \(planets[indexPath.row].name!)", for: .normal)
        }
        
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
//                    if (newScale < 1)
//                    {
//                        planet.strokeColor = UIColor(white: 1, alpha: newScale)
//                    }
//                    else{
//                        planet.strokeColor = UIColor(white: 1, alpha: 1)
//                    }
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
        group.enter()
        group.enter()
        
        loadPlanetList(group)
        loadDate(group)
        getUserData(group)
        getPositionFromServer(group)

        
        group.notify(queue: .main) {
            self.loadPlanets({
                self.addGameViews()
                self.setCurrentTravelingPlanets()
                if (self.currentPlanet != nil)
                {
                    self.moveRocketToCurrentPlanet()
                }
                self.drawObjects()
                self.startPushTimer()
            })
        }
    }
    
    func getUserData(_ group: DispatchGroup)
    {
        ref.child("users/\(email!)/data").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any]
            {
                self.username = dict["nickname"] as? String
                self.coordinatesSet = dict["coordinatesSet"] as? Bool ?? false
                
                self.traveledTo = dict["traveledTo"] as? [String: Bool] ?? [String: Bool]()
            }
            group.leave()
            print("got user data")
        })
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        usernameLabel.text = textField.text!.filter("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM01234567890".contains)
        usernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - Math.textWidth(text: usernameLabel.text!, font: usernameLabel.font) / 2,
                                     y : enterUsernameLabel.frame.maxY + 3,
                                     width: Math.textWidth(text: usernameLabel.text!, font: usernameLabel.font),
                                     height: 30.0)
        
        invalidUsernameLabel.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (usernameLabel.text == "")
        {
            self.invalidUsernameLabel.text = "Username can't be empty"
            self.invalidUsernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - Math.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font) / 2,
                                                     y : self.usernameLabel.frame.maxY + 3,
                                                     width: Math.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font),
                                                     height: 30.0)
        }
        else
        {
            ref.child("nicknames").child(usernameLabel.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.exists() && (snapshot.value as! Bool) == true)  //username already exits
                {
                    self.invalidUsernameLabel.text = "Username already taken"
                    self.invalidUsernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - Math.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font) / 2,
                                                 y : self.usernameLabel.frame.maxY + 3,
                                                 width: Math.textWidth(text: self.invalidUsernameLabel.text!, font: self.invalidUsernameLabel.font),
                                                 height: 30.0)
                }
                else
                {                   //username doesn't exist
                    textField.resignFirstResponder()
                    self.username = textField.text
                    self.ref.child("nicknames/\(self.username!)").setValue(true)
                    self.ref.child("users/\(self.email!)/data/nickname").setValue(textField.text!)

                    self.nicknameCleanup()
                    self.loadPlanetlistDatePlanets()
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        return true
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
        enterUsernameLabel.frame = CGRect(x: (self.view?.frame.size.width)! / 2 - Math.textWidth(text: enterUsernameLabel.text!, font: enterUsernameLabel.font) / 2,
                                          y : (self.view?.frame.size.height)! / 4,
                                          width: Math.textWidth(text: enterUsernameLabel.text!, font: enterUsernameLabel.font),
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
        textField.autocorrectionType = UITextAutocorrectionType.no
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
    
    func addGameViews()
    {
        self.view?.addSubview(setACourseButton)
        self.view?.addSubview(goButton)
        self.view?.addSubview(speedLabel)
        
    }
    
    func startPushTimer()
    {
        pushTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(pushPositionToServer), userInfo: nil, repeats: true)
    }
    
    func loadDate(_ group: DispatchGroup )
    {
        var date : NSDate!
        
        ref.child("timestamp").setValue(ServerValue.timestamp(), withCompletionBlock: { (error, snapshot) in
            self.ref.child("timestamp").observeSingleEvent(of: .value, with: {
                snap in
                if let t = snap.value as? TimeInterval {
                    
                    self.timestamp = snap.value as? Int
                    print("server timestamp: \(self.timestamp!)")
                    date = NSDate(timeIntervalSince1970: t/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-M-dd"
                    self.dateString = dateFormatter.string(from: date as Date)
                }
                
                group.leave()
                print("date loaded")
            })
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
    
    func loadPlanets( _ callback: @escaping () -> () )
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
                    let visitorDict = valueDict["visitors"] as? [String: Bool] ?? [String:Bool]()
                    let planet = Planet(name: planetString,
                                        radius: valueDict["radius"] as! Double,
                                        startingPlanet: valueDict["startingPlanet"] != nil,
                                            x: Int(Double(coordDict["x"]!)! * self.coordMultiplier * Math.AU),
                                            y: Int(Double(coordDict["y"]!)! * self.coordMultiplier * Math.AU),
                                            z: Int(Double(coordDict["z"]!)! * self.coordMultiplier * Math.AU),
                                            color: valueDict["color"] != nil ? Math.hexStringToUIColor(hex: valueDict["color"] as! String) : nil,
                                            type: valueDict["type"] as? String)
                    
                    self.planets.append(planet)
                    
//                    if (!self.coordinatesSet && planet.startingPlanet == true)
//                    {
//                        self.currentPlanet = planet
//                        visitorDict[planet.name!] = true
//                        self.traveledTo[planet.name!] = true
//                        self.pushTraveledToDict()
//                    }
                    
                    planet.visitorDict = visitorDict
                    
                    print("loaded planet \(planet.name!)")
                    group.leave()
                })
                
                
            })
        }
        
        group.notify(queue: .main) {
            callback()
        }
    }
    
    func drawObjects()
    {
        for planet in planets
        {
            if (planet.startingPlanet == true) //process the starting planet first
            {
                rocket = SKSpriteNode(imageNamed: "rocket.png")
                rocket.size = CGSize(width: 20, height: 40)
                self.addChild(rocket)
                sceneCam.position = CGPoint(x: 0, y: 0)
                rocket.position = sceneCam.position
                
                planet.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -planet.radius, y: -planet.radius), size: CGSize(width: planet.radius * 2, height: planet.radius * 2)), transform: nil)
                
                self.addChild(planet)
                
                if (!coordinatesSet)
                {
                    print("coordinates not set")
                    coordinatesSet = true
                    positionX = planet.x
                    positionY = (planet.y + Int(planet.radius) * Int(coordMultiplier))
                    positionZ = planet.z
                    ref.child("users/\(email!)/data/coordinatesSet").setValue(true)
                    planet.position = CGPoint(x: rocket.position.x, y: rocket.position.y - CGFloat(planet.radius))
                    addVisitorToPlanet(planet.name!)
                    currentPlanet = planet
                    
                }
                else
                {
                    print("coordinates already set")
                    planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
                }
            }
        }
        
        for planet in planets
        {
            if (planet.startingPlanet == false)
            {
                planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
                planet.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -planet.radius / 2, y: 0.0), size: CGSize(width: planet.radius, height: planet.radius)), transform: nil)
                self.addChild(planet)
            }
        }
    }
    
    override func sceneDidLoad() {

    }
    
    @objc func pushPositionToServer()
    {
        let travelingToName = travelingTo != nil ? travelingTo.name : "nil"
        let currentPlanetName = currentPlanet != nil ? currentPlanet.name : "nil"
        
        ref.child("users/\(email!)/position").setValue(
            ["positionX" : positionX!,
             "positionY" : positionY!,
             "positionZ" : positionZ!,
             "velocityX" : velocityX,
             "velocityY" : velocityY,
             "velocityZ" : velocityZ,
             "timestamp": ServerValue.timestamp(),
             "travelingTo" : travelingToName!,
             "currentPlanet" : currentPlanetName!,
             "velocity" : velocity])
        
    }
    
    func getPositionFromServer(_ group: DispatchGroup!)
    {

        ref.child("users/\(email!)/position").observeSingleEvent(of: .value, with: {
            snap in
            
            if (snap.exists())
            {
                let coordDict = snap.value as! [String: Any]
                
                self.velocity = coordDict["velocity"] as? Int ?? 0
                self.positionX = coordDict["positionX"] as? Int
                self.positionY = coordDict["positionY"] as? Int
                self.positionZ = coordDict["positionZ"] as? Int
                self.velocityX = coordDict["velocityX"] as? Double ?? 0
                self.velocityY = coordDict["velocityY"] as? Double ?? 0
                self.velocityZ = coordDict["velocityZ"] as? Double ?? 0
                self.travelingToName = (coordDict["travelingTo"] as? String)!
                self.currentPlanetName = (coordDict["currentPlanet"] as? String)

                let oldTimestamp = coordDict["timestamp"] as! Int
                print("old timestamp: \(oldTimestamp)")
                let millisecondsElapsed = self.timestamp - oldTimestamp
                print("\(millisecondsElapsed) milliseconds since last load")

                print("x change: \(Int(self.velocityX / Math.millisecondsPerHour * Double(millisecondsElapsed)))")
                print("y change: \(Int(self.velocityY / Math.millisecondsPerHour * Double(millisecondsElapsed)))")
                print("z change: \(Int(self.velocityZ / Math.millisecondsPerHour * Double(millisecondsElapsed)))")
                
                self.positionX += Int(self.velocityX / Math.millisecondsPerHour * Double(millisecondsElapsed))
                self.positionY += Int(self.velocityY / Math.millisecondsPerHour * Double(millisecondsElapsed))
                self.positionZ += Int(self.velocityZ / Math.millisecondsPerHour * Double(millisecondsElapsed))
                
                
            }
            
            if (group != nil)
            {
                group.leave()
            }

        })
    }
    
    func setCurrentTravelingPlanets()
    {
        travelingTo = self.planetWithName(travelingToName)
        currentPlanet = self.planetWithName(currentPlanetName)
    }
    
    func moveRocketToCurrentPlanet()
    {
        print("moving rocket to \(currentPlanet.name!)")
        positionX = currentPlanet.x
        positionY = currentPlanet.y + Int(currentPlanet.radius) * Int(coordMultiplier)
        positionZ = currentPlanet.z
        addVisitorToPlanet(currentPlanet.name!)
        
    }
    
    func planetWithName(_ name: String!) -> Planet!
    {
        for planet in planets
        {
            if (planet.name == name)
            {
                return planet
            }
        }
        return nil
    }

    override func update(_ currentTime: TimeInterval) {
        
        let newTime = Date().timeIntervalSinceReferenceDate
        let timeDiff = newTime - localTime
        localTime = newTime
        
        if (travelingTo != nil)
        {
            
            positionX += Int(velocityX / Math.secondsPerHour * timeDiff)
            positionY += Int(velocityY / Math.secondsPerHour * timeDiff)
            positionZ += Int(velocityZ / Math.secondsPerHour * timeDiff)
            
            for planet in planets
            {
                planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
            }
            
//            xPositionLabel.text = "x position: \(positionX!)"
//            yPositionLabel.text = "y position: \(positionY!)"
//            zPositionLabel.text = "z position: \(positionZ!)"
//            xVelocityLabel.text = "x velocity: \(velocityX!)"
//            yVelocityLabel.text = "y velocity: \(velocityY!)"
//            zVelocityLabel.text = "z velocity: \(velocityZ!)"

           //
                //print("calculated velocities")
            calculateVelocities()
            //}
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let planet = self.planets[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        cell?.detailTextLabel?.numberOfLines = 4
        
        cell!.textLabel?.text = planet.name
        if (self.planets[indexPath.row] == currentPlanet)
        {
            cell!.textLabel?.textColor = UIColor.gray
            cell!.detailTextLabel?.text = "You are here"
            cell!.detailTextLabel?.textColor = UIColor.gray
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        else if (self.planets[indexPath.row] == travelingTo)
        {
            cell!.textLabel?.textColor = UIColor.gray
            cell!.detailTextLabel?.text = "You are already traveling to this planet"
            cell!.detailTextLabel?.textColor = UIColor.gray
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        else
        {
            cell!.textLabel?.textColor = UIColor.black
            cell!.detailTextLabel?.textColor = UIColor.black
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            cell!.detailTextLabel?.text = "Distance: \(String(describing: Math.formatDistance(self.planets[indexPath.row].distance!)))"
        }
        if (planet.type != nil)
        {
            cell?.detailTextLabel?.text?.append("\nType: \(planet.type!)")
        }
        let visitorCount = planet.visitorDict != nil ? planet.visitorDict.count : 0
        cell?.detailTextLabel?.text?.append("\nVisited by: \(visitorCount)")
        if (traveledTo[planet.name!] == true && planet != currentPlanet)
        {
            cell?.detailTextLabel?.text?.append("\nYou have been here")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


