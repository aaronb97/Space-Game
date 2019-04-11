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
import GoogleSignIn


class GameScene: SKScene, UITableViewDelegate, UITableViewDataSource {
    
    let planetTexturesDict : [String: Bool] = ["Earth": true, "The Moon": true, "Mars": true, "The Sun": true, "Mercury": true]
    
    var testView: UIView!
    
    var xPositionLabel: UILabel!
    var yPositionLabel: UILabel!
    var zPositionLabel: UILabel!
    var xVelocityLabel: UILabel!
    var yVelocityLabel: UILabel!
    var loadingLabel = UILabel()

    var ref: DatabaseReference!
    
    var username: String! {
        didSet {
            if let name = username
            {
                usernameLabel.text = "Signed in as \(name)"
            }
            else
            {
                usernameLabel.text = ""
            }
        }
    }
    
    var usernameLabel = UILabel()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var dateString : String!
    
    var positionX : Int!
    var positionY : Int!
    var velocityX = 0.0
    var velocityY = 0.0

    
    var velocity : Double = 0 {
        didSet {
            setSpeedLabel()
        }
    }
    
    var baseVelocity = 50000
    
    var rocket = SKSpriteNode()
    var coordinatesSet = false
    var travelingToName: String!
    var currentPlanetName: String!
    
    var planetDict = [String: Planet]()
    var planetArray = [Planet]()
    var planetList : [String]!
    var starList : [String]!
    
    let sceneCam = SKCameraNode()
    
    var planetListTableView = UITableView()

    var setACourseButton = UIButton()
    var goButton = UIButton()
    var cancelButton = UIButton()
    let signOutButton = UIButton()
    
    var planetSelection: Planet!
    var travelingTo: Planet! {
        didSet {
            setTimeToPlanetLabel()
        }
    }
    
    let consoleView = ConsoleView()

    
    var currentPlanet : Planet! {
        didSet {
            if (currentPlanet != nil)
            {
                consoleView.timeToDestLabel.text = ""
            }
        }
    }
    
    let starFieldWidth : CGFloat = 1000
    let starFieldHeight : CGFloat = 2000
    
    var email: String!
    var timestamp : Int! {
        didSet {
            if view != nil
            {
                setSpeedBoostTimeLabel()
                setTimeToPlanetLabel()
                calculateIfBoostedOrLanded()
            }
        }
    }
    
    
    var nextSpeedBoostTime = Int.max
    var willLandOnPlanetTime = Int.max
    
    var pushTimer: Timer!
    var calcVelocityTimer: Timer!
    var loadDateTimer: Timer!
    var loadPlanetImagesTimer: Timer!
    
    var localTime: TimeInterval!
    
    var traveledToDict = [String: Bool]()
    var flagsDict = [String: Bool]()
    
    var versionLabel = UILabel()
    
    let starfieldDict : [String: Any] = ["starfield": ["alpha" : 1.0, "resistance": 600.0]]
    
    func setTimeToPlanetLabel()
    {
        if (travelingTo != nil)
        {
            travelingTo.calculateDistance(x: positionX, y: positionY)
            consoleView.timeToDestLabel.text = "Time to \(travelingTo.name!): \(formatTime(Int(travelingTo!.distance / Double(velocity) * 3600)))"
        }
        else
        {
            consoleView.timeToDestLabel.text = ""
        }
    }
    
    func setSpeedLabel()
    {
        consoleView.speedLabel.text = "Speed: \(formatDistance(Double(velocity)))/hour"
    }
    
    override func didMove(to view: SKView) {
        
        self.view?.backgroundColor = .spaceColor
        self.view?.window?.backgroundColor = .spaceColor
        self.backgroundColor = .spaceColor
        
        camera = sceneCam
        camera?.name = "camera"
        
        self.view?.window?.addSubview(consoleView)
        consoleView.translatesAutoresizingMaskIntoConstraints = false
        consoleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        consoleView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 250).isActive = true
        consoleView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        consoleView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        
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
                    self.loadEverything()
                }
        })

        planetListTableView.rowHeight = CGFloat(100)
        self.scene?.view?.addSubview(planetListTableView)
        planetListTableView.delegate = self
        planetListTableView.dataSource = self
        planetListTableView.isHidden = true
        
        planetListTableView.translatesAutoresizingMaskIntoConstraints = false
        planetListTableView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -5).isActive = true
        planetListTableView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 5).isActive = true
        planetListTableView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 15).isActive = true
        planetListTableView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -160).isActive = true
        
        setACourseButton.setTitle("Set a Course", for: .normal)
        let setACourseButtonWidth = 130.0
        setACourseButton.frame = CGRect(x: (self.view?.center.x)! - CGFloat(setACourseButtonWidth / 2), y: self.view!.frame.height / 4, width: CGFloat(setACourseButtonWidth), height: CGFloat(30.0))
        formatButton(setACourseButton)
        setACourseButton.isHidden = true
        
        self.view?.addSubview(goButton)
        formatButton(goButton)
        goButton.isHidden = true
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.topAnchor.constraint(equalTo: planetListTableView.bottomAnchor, constant: 20).isActive = true
        goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        goButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view?.addSubview(cancelButton)
        formatButton(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: planetListTableView.bottomAnchor, constant: 70).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.isHidden = true
        cancelButton.setTitle("Cancel", for: .normal)
        
        
        versionLabel.text = "v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (build \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))"
        versionLabel.frame = CGRect(x: 20.0, y: (self.view?.frame.maxY)! - 25, width: 300, height: 30)
        versionLabel.font = UIFont(name: versionLabel.font.fontName, size: 10)
        
        usernameLabel.font = UIFont(name: versionLabel.font.fontName, size: 12)
        
        consoleView.isHidden = true
        
        formatLabel(versionLabel)
        formatLabel(usernameLabel)
        
        formatButton(signOutButton)
        signOutButton.isHidden = true
        
        self.view?.addSubview(versionLabel)
        self.view?.addSubview(signOutButton)
        self.view?.addSubview(usernameLabel)
        self.view?.addSubview(setACourseButton)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 5).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -5).isActive = true
        signOutButton.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: textWidth(text: signOutButton.titleLabel!.text!, font: signOutButton.titleLabel!.font!) + 15).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 5).isActive = true
        versionLabel.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true

        
        loadingLabel.text = "Loading..."
        loadingLabel.font = UIFont(name: loadingLabel.font.fontName, size: 15)
        loadingLabel.frame = CGRect(x: (self.view?.center.x)! - textWidth(text: loadingLabel.text!, font: loadingLabel.font) / 2,
                                    y: (self.view?.center.y)!,
                                    width: textWidth(text: loadingLabel.text!, font: loadingLabel.font),
                                    height: 30)
        formatLabel(loadingLabel)
        self.view?.addSubview(loadingLabel)

        localTime = Date().timeIntervalSinceReferenceDate
    }
    
    func createStarfield()
    {
        for key in starfieldDict.keys
        {
            let subDict = starfieldDict[key] as! [String: Double]
            for i in 0...1 {
                for j in 0...1 {
                    let width : CGFloat = starFieldWidth
                    let height : CGFloat = starFieldHeight
                    let starfield = SKSpriteNode()
                    starfield.texture = SKTexture(imageNamed: key)
                    starfield.name = key
                    starfield.zPosition = 0
                    starfield.alpha = CGFloat(subDict["alpha"]!)
                    starfield.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    starfield.size = CGSize(width: width, height: height)
                    starfield.position = CGPoint(x: width * CGFloat(i) - width / 2,
                                                 y: height * CGFloat(j) - height / 2)
                    starfield.alpha = 0
                    self.addChild(starfield)
                    setView(view: starfield, hide: false)
                }
            }
        }
    }
    
    func moveStarField(_ time: TimeInterval)
    {
        for key in starfieldDict.keys
        {
            let width : CGFloat = starFieldWidth
            let height : CGFloat = starFieldHeight
            let subDict = starfieldDict[key] as! [String: Double]
            self.enumerateChildNodes(withName: key, using: ({
                (node, error) in
                node.position = CGPoint(x: node.position.x - CGFloat(sqrtPreserveSign(self.velocityX) / subDict["resistance"]! * time), y: node.position.y - CGFloat(sqrtPreserveSign(self.velocityY) / subDict["resistance"]! * time))
                if node.position.x > width
                {
                    node.position.x = -width
                }
                else if node.position.x < -width
                {
                    node.position.x = width
                }
                
                if node.position.y > height
                {
                    node.position.y = -height
                }
                else if node.position.y < -height
                {
                    node.position.y = height
                }
            }))
        }
    }
    
    func formatLabel(_ label: UILabel)
    {
        label.textColor = UIColor.white
        //label.font = UIFont(name: "Courier", size: 15)
    }
    
    func formatButton(_ button: UIButton)
    {
        button.setTitleColor(UIColor.white, for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action:#selector(buttonPressed), for: .touchUpInside)
        button.backgroundColor = UIColor("000000").withAlphaComponent(0.8)
        button.setBackgroundColor(color: UIColor("111111").withAlphaComponent(1.0), forState: UIControl.State.highlighted)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func buttonPressed(sender: UIButton)
    {
        if sender == setACourseButton
        {
            
            for planet in planetDict.values {
                planet.calculateDistance(x: positionX, y: positionY)
            }
            
            planetArray = Array(planetDict.values)
            planetArray.sort(by: {$0.distance < $1.distance})
            
            planetListTableView.reloadData()
            
            setView(view: setACourseButton, hide: true)
            setView(view: planetListTableView, hide: false)
            setView(view: consoleView, hide: true)
            setView(view: signOutButton, hide: true)
            setView(view: cancelButton, hide: false)
            
        }
        else if sender == goButton
        {
            setView(view: goButton, hide: true)
            setView(view: setACourseButton, hide: false)
            setView(view: planetListTableView, hide: true)
            setView(view: consoleView, hide: false)
            setView(view: signOutButton, hide: false)
            setView(view: cancelButton, hide: true)
            
            willLandOnPlanetTime = Int.max
            
            velocity = calcSpeed()

            travelingTo = planetSelection
            planetSelection = nil
            currentPlanet = nil

            calculateVelocities()
            pushNextSpeedBoostTime()
            pushWillLandOnPlanetTime()
            
        }
        else if sender == cancelButton
        {
            setView(view: goButton, hide: true)
            setView(view: setACourseButton, hide: false)
            setView(view: planetListTableView, hide: true)
            setView(view: consoleView, hide: false)
            setView(view: signOutButton, hide: false)
            setView(view: cancelButton, hide: true)
        }
        else if sender == signOutButton
        {
            for planet in planetDict.values
            {
                planet.fillTexture = nil
            }
            planetDict = [String: Planet]()
            pushPositionToServer()
            GIDSignIn.sharedInstance()?.signOut()
            UserDefaults.standard.set(false, forKey: "StaySignedIn")
            appDelegate.showSignInScreen()
        }
    }
    
    func pushNextSpeedBoostTime()
    {
        let group = DispatchGroup()
        group.enter()
        loadDate(group)
        
        group.notify(queue: .main) {
            self.nextSpeedBoostTime = self.timestamp + 43200000
            self.setSpeedBoostTimeLabel()
            NSLog("next speed boost time set: \(self.nextSpeedBoostTime)")
            self.pushPositionToServer()
        }
    }
    
    func pushWillLandOnPlanetTime()
    {
        let group = DispatchGroup()
        group.enter()
        loadDate(group)
        
        group.notify(queue: .main) {
            guard let planet = self.travelingTo else { return }
            planet.calculateDistance(x: self.positionX, y: self.positionY)
            self.willLandOnPlanetTime = self.timestamp + Int(self.travelingTo.distance / Double(self.velocity) * 3600000.0)
            self.pushPositionToServer()
        }
    }
    
    @objc func calculateVelocities()
    {
        if let planet = travelingTo
        {
            let theta = angleBetween(x1: rocket.position.x, y1: rocket.position.y, x2: planet.position.x, y2: planet.position.y)
            rocket.zRotation = theta - .pi / 2
            
            velocityX = Double(cos(theta) * CGFloat(velocity)) * coordMultiplier
            velocityY = Double(sin(theta) * CGFloat(velocity)) * coordMultiplier
        }

    }
    
    func checkTouchDown()
    {
        guard let planet = travelingTo else {return}
        guard let radius = planet.radius else {return}
        if (distance(x1: rocket.position.x, x2: planet.position.x, y1: rocket.position.y, y2: planet.position.y) < radius) //touch down on a planet
        {

            currentPlanet = planet
            travelingTo = nil
            rocket.zRotation = angleBetween(x1: rocket.position.x, y1: rocket.position.y, x2: currentPlanet.position.x, y2: currentPlanet.position.y) + .pi / 2
            
            if (traveledToDict[currentPlanet.name!] == nil)
            {
                addVisitorToPlanet(currentPlanet.name!)
            }
            
            traveledToDict[currentPlanet.name!] = true
            velocity = 0
            pushPositionToServer()
            setSpeedBoostTimeLabel()
        }
    }
    
    func addVisitorToPlanet(_ name: String)
    {
        //guard let planet = planetDict[name] else { NSLog("planet to add visitor to not found"); return}
        
        if traveledToDict[name] != true
        {
            //planet.visitorDict[self.username] = true
            traveledToDict[name] = true
            self.ref.child("planets/\(name)/values/visitors/\(self.username!)").setValue(true)
            NSLog("added visitor \(username!) to \(name)")
            self.ref.child("users/\(email!)/data/traveledTo/\(name)").setValue(true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let planet = planetArray[indexPath.row]
        if planet != currentPlanet && planet != travelingTo
        {
            planetSelection = planetArray[indexPath.row]
            setView(view: goButton, hide: true)
            goButton.setTitle("Go to \(planetArray[indexPath.row].name!)", for: .normal)
            
            
            //self.goButton.frame.size.width = textWidth(text: self.goButton.titleLabel!.text!, font: self.goButton.titleLabel?.font)
            setView(view: goButton, hide: false)

            
        }
    }
    
    @objc func pinchRecognized(sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            let deltaScale = (sender.scale - 1.0)*2
            let convertedScale = sender.scale - deltaScale
            let newScale = self.camera!.xScale*convertedScale
            if newScale < 1
            {
                self.camera!.setScale(1)
                return
            }
            else if newScale > 985295324645636.8
            {
                self.camera?.setScale(985295324645636.8)
                return
            }
            else
            {
                self.camera!.setScale(newScale)
            }
            
            for planet in planetDict.values
            {
                if (camera!.xScale > CGFloat(0.1))
                {
                    planet.lineWidth = newScale
                }
                else
                {
                    planet.lineWidth = 0
                }
                planet.glowWidth = newScale
            }
            if camera!.xScale > CGFloat(1.4)
            {
                for key in starfieldDict.keys
                {
                    self.enumerateChildNodes(withName: key, using: ({
                        (node, error) in
                        setView(view: node, hide: true, setStartAlpha: false)
                    }))
                }
            }
            else
            {
                for key in starfieldDict.keys
                {
                    self.enumerateChildNodes(withName: key, using: ({
                        (node, error) in
                        setView(view: node, hide: false, setStartAlpha: false)
                    }))
                }
            }
            
            sender.scale = 1.0
        }
    }
    
    func loadEverything()
    {
        makeStartElementsInvisible()
        let group2 = DispatchGroup()
        group2.enter()
        loadDate(group2)                                //part 1: load date
        group2.notify(queue: .main) {
            let group = DispatchGroup()
            
            group.enter()
            group.enter()
            group.enter()
            
            self.loadPlanetList(group)                  //part 2: load planet list, user data, and position
            self.getUserData(group)
            self.getPositionFromServer(group)
            
            group.notify(queue: .main) {
                self.loadPlanets({                      //part 3: load planets
                    
                    //self.addGameViews()
                    self.setCurrentAndTravelingPlanets()
                    
                    self.drawObjects()
                    if (self.currentPlanet != nil)
                    {
                        self.moveRocketToCurrentPlanet()
                    }
                    self.calculateIfBoostedOrLanded()

                    self.startPushTimer()
                    self.calculateVelocities()
                    self.startCalculateVelocityTimer()
                    self.startLoadDateTimer()
                    self.startLoadPlanetImagesTimer()
                    self.setSpeedLabel()
                    self.setSpeedBoostTimeLabel()
                    self.setTimeToPlanetLabel()
                    self.createStarfield()
                    self.makeStartElementsVisible()
                })
            }
        }
    }
    
    func makeStartElementsVisible()
    {
        for planet in planetDict.values
        {
            planet.alpha = 0.0
            setView(view: planet, hide: false)
        }
        
        
        setView(view: rocket, hide: false)
        setView(view: consoleView, hide: false)
        setView(view: setACourseButton, hide: false)
        setView(view: loadingLabel, hide: true)
        setView(view: signOutButton, hide: false)
        
        
        self.addChild(camera!)
    }
    
    func makeStartElementsInvisible()
    {
        setView(view: rocket, hide: true)
        setView(view: consoleView, hide: true)
        setView(view: setACourseButton, hide: true)
        setView(view: loadingLabel, hide: false)
        setView(view: signOutButton, hide: true)
        
        self.removeAllChildren()
        
        for planet in planetDict.values
        {
            planet.fillTexture = nil
        }
        
        
    }
    
    func getUserData(_ group: DispatchGroup)
    {
        ref.child("users/\(email!)/data").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any]
            {
                self.username = dict["nickname"] as? String
                self.coordinatesSet = dict["coordinatesSet"] as? Bool ?? false
                self.traveledToDict = dict["traveledTo"] as? [String: Bool] ?? [String: Bool]()
                self.flagsDict = dict["flags"] as? [String: Bool] ?? [String: Bool]()
            }
            group.leave()
            NSLog("got user data for \(self.email ?? "nil")")
        }) { (error) in
            NSLog(error.localizedDescription)
            showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
        }
    }
    
    
    func nicknameSetup()
    {
        let nickname = "\(Words.adjectives[Int.random(in: 0 ..< Words.adjectives.count)])\(Words.nouns[Int.random(in: 0 ..< Words.nouns.count)])\(Int.random(in: 0 ..< 10000))"
        ref.child("nicknames").child(nickname).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.exists() && (snapshot.value as! Bool) == true)  //username already exits
            {
                self.nicknameSetup()
            }
            else
            {                   //username doesn't exist
                self.username = nickname
                self.ref.child("nicknames/\(nickname)").setValue(true)
                self.ref.child("users/\(self.email!)/data/nickname").setValue(nickname)
                self.loadEverything()
            }
            
        }) { (error) in
            NSLog(error.localizedDescription)
        }
    }

    func addGameViews()
    {
        self.view?.addSubview(consoleView)
    }
    
    func startPushTimer()
    {
        pushTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(pushPositionToServer), userInfo: nil, repeats: true)
    }
    
    func startCalculateVelocityTimer()
    {
        calcVelocityTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(calculateVelocities), userInfo: nil, repeats: true)
    }
    
    func startLoadDateTimer()
    {
        loadDateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(loadDateNoDispatch), userInfo: nil, repeats: true)
    }
    
    func startLoadPlanetImagesTimer()
    {
        loadPlanetImagesTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadPlanetImages), userInfo: nil, repeats: false)
    }
    
    @objc func loadDateNoDispatch()
    {
        loadDate(nil)
    }
    
    func loadDate(_ group: DispatchGroup! )
    {
        var date : NSDate!
        
        ref.child("timestamp").setValue(ServerValue.timestamp(), withCompletionBlock: { (error, snapshot) in
            self.ref.child("timestamp").observeSingleEvent(of: .value, with: {
                snap in
                if let t = snap.value as? TimeInterval {
                    
                    self.timestamp = snap.value as? Int
                    date = NSDate(timeIntervalSince1970: t/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-M-dd"
                    self.dateString = dateFormatter.string(from: date as Date)
                }
                
                if (group != nil)
                {
                    group.leave()
                }
                
                NSLog("date loaded")
            }) { (error) in
                NSLog(error.localizedDescription)
                showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
            }
        })
    }
    
    func loadPlanetList( _ group: DispatchGroup)
    {
        group.enter()
        ref.child("planetList").observeSingleEvent(of: .value, with: {
            snap in
            self.planetList = snap.value as? [String]
            group.leave()
            NSLog("planet list loaded")
        }) { (error) in
            NSLog(error.localizedDescription)
            showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
        }
        
        ref.child("starList").observeSingleEvent(of: .value, with: {
            snap in
            self.starList = snap.value as? [String]
            group.leave()
            NSLog("planet list loaded")
        }) { (error) in
            NSLog(error.localizedDescription)
            showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
        }
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
                    let visitorDict = valueDict["visitors"] as? [String : Bool] ?? [String : Bool]()
                    let planet = Planet(name: planetString,
                                        radius: valueDict["radius"] as! Double,
                                        startingPlanet: valueDict["startingPlanet"] != nil,
                                            x: Int(Double(coordDict["x"]!)! * coordMultiplier * AU),
                                            y: Int(Double(coordDict["y"]!)! * coordMultiplier * AU),
                                            color: valueDict["color"] != nil ? UIColor( valueDict["color"] as! String) : nil,
                                            type: valueDict["type"] as? String)
                    
                    self.planetDict[planet.name!] = planet
                    planet.visitorCount = visitorDict.count
                    group.leave()
                    
                }) { (error) in
                    NSLog(error.localizedDescription)
                    showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
                }
                
                
            }) { (error) in
                NSLog(error.localizedDescription)
                showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
            }
        }
        
        for starString in self.starList
        {
            group.enter()
            ref.child("planets/\(starString)").observeSingleEvent(of: .value, with: {
                snap in
                let dict = snap.value as! [String: Any]
                print(dict)
                let star = Planet(name: starString, radius: 100000, x: Int(dict["x"] as! Double * coordMultiplier * parsec),
                                                                                           y: Int(dict["y"] as! Double * coordMultiplier * parsec),
                                                                                           color: .yellow, type: "Star")
                let visitorDict = dict["visitors"] as? [String: Bool] ?? [String:Bool]()
                star.visitorCount = visitorDict.count
                self.planetDict[starString] = star
                group.leave()
                
                
            }) { (error) in
                NSLog(error.localizedDescription)
                showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
            }
        }
        
        group.notify(queue: .main) {
            callback()
        }
    }
    
    func drawObjects()
    {
        for planet in planetDict.values
        {
            //planet.isHidden = true
            planet.zPosition = 1
            if (planet.startingPlanet == true) //process the starting planet first
            {
                
                    rocket = SKSpriteNode(imageNamed: "rocket.png")
                    rocket.size = CGSize(width: 20, height: 40)
                    rocket.zPosition = 2
                

                self.addChild(rocket)
                camera!.position = CGPoint(x: 0, y: 0)
                rocket.position = camera!.position
                self.addChild(planet)
                
                if (!coordinatesSet)
                {
                    NSLog("coordinates not set")
                    coordinatesSet = true
                    positionX = planet.x
                    positionY = planet.y + Int(planet.radius) * Int(coordMultiplier)
                    ref.child("users/\(email!)/data/coordinatesSet").setValue(true)
                    planet.position = CGPoint(x: rocket.position.x, y: rocket.position.y - CGFloat(planet.radius))
                    addVisitorToPlanet(planet.name!)
                    currentPlanet = planet
                    
                }
                else
                {
                    NSLog("coordinates already set")
                    planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
                }
            }
        }
        
        for planet in planetDict.values
        {
            planet.zPosition = 1
            if (planet.startingPlanet == false)
            {
                planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
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
        //let path = "users/\(email!)/position"
        
        ref.child("users/\(email!)/position").setValue(
            ["positionX" : positionX!,
             "positionY" : positionY!,
             "velocityX" : velocityX,
             "velocityY" : velocityY,
             "timestamp": ServerValue.timestamp(),
             "travelingTo" : travelingToName!,
             "currentPlanet" : currentPlanetName!,
             "velocity" : velocity,
             "nextSpeedBoostTime": nextSpeedBoostTime,
             "willLandOnPlanetTime" : willLandOnPlanetTime])
    }
    
    func getPositionFromServer(_ group: DispatchGroup!)
    {

        ref.child("users/\(email!)/position").observeSingleEvent(of: .value, with: {
            snap in
            
            if (snap.exists())
            {
                let coordDict = snap.value as! [String: Any]
                
                self.velocity = coordDict["velocity"] as? Double ?? 0
                self.positionX = coordDict["positionX"] as? Int
                self.positionY = coordDict["positionY"] as? Int
                self.velocityX = coordDict["velocityX"] as? Double ?? 0
                self.velocityY = coordDict["velocityY"] as? Double ?? 0
                self.travelingToName = (coordDict["travelingTo"] as? String)!
                self.currentPlanetName = (coordDict["currentPlanet"] as? String)
                self.nextSpeedBoostTime = coordDict["nextSpeedBoostTime"] as? Int ?? Int.max
                self.willLandOnPlanetTime = coordDict["willLandOnPlanetTime"] as? Int ?? Int.max

                let oldTimestamp = coordDict["timestamp"] as! Int
                let millisecondsElapsed = self.timestamp - oldTimestamp
                NSLog("\(millisecondsElapsed) milliseconds since last load")

                NSLog("x change: \(Int(self.velocityX / millisecondsPerHour * Double(millisecondsElapsed)))")
                NSLog("y change: \(Int(self.velocityY / millisecondsPerHour * Double(millisecondsElapsed)))")
                
                self.positionX += Int(self.velocityX / millisecondsPerHour * Double(millisecondsElapsed))
                self.positionY += Int(self.velocityY / millisecondsPerHour * Double(millisecondsElapsed))
            }
            
            if (group != nil)
            {
                group.leave()
            }

        }) { (error) in
            NSLog(error.localizedDescription)
            showAlertMessage((self.view?.window!.rootViewController)!, header: "Error", body: error.localizedDescription)
        }
    }
    
    func calculateIfBoostedOrLanded()
    {
        if (self.timestamp > willLandOnPlanetTime && travelingTo != nil)
        {
            currentPlanet = travelingTo
            travelingTo = nil
            moveRocketToCurrentPlanet()
        }
        else if (self.timestamp > self.nextSpeedBoostTime)
        {
            nextSpeedBoostTime = Int.max
            NSLog("speed boosted")
            velocity *= 2
            pushNextSpeedBoostTime()
            setTimeToPlanetLabel()
            pushWillLandOnPlanetTime()
            calculateVelocities()
        }
        else
        {
            NSLog("speed not boosted, need to wait \(self.nextSpeedBoostTime - self.timestamp) milliseconds")
            self.setSpeedBoostTimeLabel()
            self.setTimeToPlanetLabel()
        }
    }
    
    func setSpeedBoostTimeLabel()
    {
        if let planet = currentPlanet
        {
            consoleView.timeToSpeedBoostLabel.text = "Welcome to \(planet.name!)"
        }
        else
        {
            consoleView.timeToSpeedBoostLabel.text = "Speed boost available in \(formatTime(Int(Double(self.nextSpeedBoostTime - self.timestamp) / 1000)))"
        }
    }
    
    func setCurrentAndTravelingPlanets()
    {
        if let name = travelingToName
        {
            if let travelingToPlanet = planetDict[name]
            {
                travelingTo = travelingToPlanet
            }
        }
        
        if let name = currentPlanetName
        {
            if let currentPlanetPlanet = planetDict[name]
            {
                currentPlanet = currentPlanetPlanet
            }
        }
    }
    
    func moveRocketToCurrentPlanet()
    {
        NSLog("moving rocket to \(currentPlanet.name!)")
        if velocityX != 0
        {
            rocket.zRotation = CGFloat(atan(velocityY / velocityX)) - .pi / 2
            if velocityX < 0
            {
                rocket.zRotation -= .pi
            }
        }
        else
        {
            rocket.zRotation = .pi
        }

        let zRot = rocket.zRotation
        let adjustedX = Int(currentPlanet.radius * coordMultiplier * Double(cos(zRot + .pi / 2)))
        let adjustedY = Int(currentPlanet.radius * coordMultiplier * Double(sin(zRot + .pi / 2)))

        positionX = currentPlanet.x - adjustedX
        positionY = currentPlanet.y - adjustedY
        rocket.zRotation -= .pi
        
        movePlanets()
        addVisitorToPlanet(currentPlanet.name!)
        velocity = 0
        setSpeedBoostTimeLabel()
    }
    
    func movePlanets()
    {
        for planet in planetDict.values
        {
            planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
        }
    }
    
    func calcSpeed() -> Double
    {
        var speedSum = 40000
        for key in traveledToDict.keys
        {
            if let planet = planetDict[key] {
                if planet.type == "Planet"
                {
                    speedSum += 10000
                }
                else if planet.type == "Dwarf Planet"
                {
                    speedSum += 7500
                }
                else if planet.type == "Moon"
                {
                    
                    speedSum += 5000
                }
                else if planet.type == "Irregular Moon"
                {
                    
                    speedSum += 2500
                }
                else if planet.type == "Star"
                {
                    
                    speedSum += 15000
                }
                else if planet.type == "Asteroid"
                {
                    
                    speedSum += 2000
                }
                else if planet.type == "Comet"
                {
                    speedSum += 6666
                }
            }
        }
        return Double(speedSum)
    }

    @objc func loadPlanetImages()
    {
        loadPlanetImagesTimer.invalidate()
        DispatchQueue.global(qos: .userInitiated).async {
            for key in self.planetTexturesDict.keys
            {
                let planet = self.planetDict[key]
                if planet != nil
                {
                    if self.camera!.xScale < CGFloat(planet!.radius * 2) && (self.camera?.contains(planet!))!
                    {
                        if planet?.fillTexture == nil
                        {
                            if let image = UIImage(named: planet!.name!)
                            {
                                planet?.fillTexture = SKTexture.init(image: image)
                                planet?.fillColor = .white
                                print("set \(planet!.name!) texture")
                            }
                        }
                    }
                    else
                    {
                        if planet?.fillTexture != nil
                        {
                            planet?.fillTexture = nil
                            planet?.fillColor = planet?.color ?? UIColor.moonColor
                            print("reset \(planet!.name!) texture to nil")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.startLoadPlanetImagesTimer()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let newTime = Date().timeIntervalSinceReferenceDate
        let timeDiff = newTime - localTime
        localTime = newTime
        
        if (travelingTo != nil)
        {
            positionX += Int(velocityX / secondsPerHour * timeDiff)
            positionY += Int(velocityY / secondsPerHour * timeDiff)
            
            for planet in planetDict.values
            {
                planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier,
                                          y: Double(planet.y - positionY!) / coordMultiplier)
            }
            
            moveStarField(timeDiff)
            checkTouchDown()

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planetDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let planet = self.planetArray[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        cell?.detailTextLabel?.numberOfLines = 5
        cell!.textLabel?.text = planet.name
        
        if self.planetArray[indexPath.row] == currentPlanet
        {
            cell!.textLabel?.textColor = UIColor.gray
            cell!.detailTextLabel?.text = "You are here"
            cell!.detailTextLabel?.textColor = UIColor.gray
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        else if self.planetArray[indexPath.row] == travelingTo
        {
            cell!.textLabel?.textColor = UIColor.gray
            cell!.detailTextLabel?.text = "You are already traveling here"
            cell!.detailTextLabel?.textColor = UIColor.gray
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
            cell!.detailTextLabel?.text?.append("\nDistance: \(String(describing: formatDistance(self.planetArray[indexPath.row].distance!)))")
        }
        else
        {
            cell!.textLabel?.textColor = UIColor.black
            cell!.detailTextLabel?.textColor = UIColor.black
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            cell!.detailTextLabel?.text = "Distance: \(String(describing: formatDistance(self.planetArray[indexPath.row].distance!)))"
        }
        
        if (planet.type != nil)
        {
            cell?.detailTextLabel?.text?.append("\nType: \(planet.type!)")
        }
        //let visitorCount = planet.visitorDict != nil ? planet.visitorDict.count : 0
        cell?.detailTextLabel?.text?.append("\nVisited by: \(planet.visitorCount)")
        
        if (traveledToDict[planet.name!] == true && planet != currentPlanet)
        {
            cell?.detailTextLabel?.text?.append("\nYou have been here")
        }
        
        cell?.backgroundColor = planet.color != nil ? planet.color!.lighter() : planet.fillColor.lighter()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}




