//
//  GameScene.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/21/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import SpriteKit
import GameplayKit
import UserNotifications


class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    private enum StorageKey {
        static let nickname = "offline.nickname"
        static let coordinatesSet = "offline.coordinatesSet"
        static let traveledTo = "offline.traveledTo"
        static let flags = "offline.flags"
        static let position = "offline.position"
        static let lastPlanetUpdate = "offline.lastPlanetUpdate"
        static let planetPositionTimestamp = "offline.planetPositionTimestamp"
    }

    private let userDefaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()
    
    let planetTexturesDict : [String: Bool] = ["Earth": true, "The Moon": true, "Mars": true, "The Sun": true, "Mercury": true, "Uranus": true, "Neptune": true, "Saturn": true, "Jupiter": true, "Brick World": true]

    private struct OrbitDefinition {
        let name: String
        let radius: Double
        let startingPlanet: Bool
        let color: UIColor
        let type: String
        let kepler: KeplerianElements?
        let fixedPositionAU: (x: Double, y: Double, z: Double)?
        let satellite: SatelliteElements?
        let orbits: String?

        init(name: String,
             radius: Double,
             startingPlanet: Bool,
             color: UIColor,
             type: String,
             kepler: KeplerianElements? = nil,
             fixedPositionAU: (x: Double, y: Double, z: Double)? = nil,
             satellite: SatelliteElements? = nil,
             orbits: String? = nil) {
            self.name = name
            self.radius = radius
            self.startingPlanet = startingPlanet
            self.color = color
            self.type = type
            self.kepler = kepler
            self.fixedPositionAU = fixedPositionAU
            self.satellite = satellite
            self.orbits = orbits
        }
    }

    private let orbitDefinitions: [OrbitDefinition] = {
        let luytenBase = raDecDistToEclipticAU(raHours: 1, raMinutes: 39, raSeconds: 1.3, decDegrees: -17, decMinutes: 57, decSeconds: 1.8, distanceLightYears: 8.73)
        let luytenOffsetAU = ((2.1 + 8.8) / 2.0) / 2.0
        return [
            OrbitDefinition(name: "The Sun", radius: 696340, startingPlanet: false, color: .yellow, type: "Star", fixedPositionAU: (x: 0, y: 0, z: 0)),
            OrbitDefinition(name: "Mercury", radius: 2439.7, startingPlanet: false, color: UIColor("c0c0c0"), type: "Planet",
                            kepler: KeplerianElements(a: 0.38709893, e: 0.20563069, i: 7.00487, L: 252.25084, longPeri: 77.45645, longNode: 48.33167, LDot: 149472.67411175)),
            OrbitDefinition(name: "Venus", radius: 6051.8, startingPlanet: false, color: UIColor("ffc649"), type: "Planet",
                            kepler: KeplerianElements(a: 0.72333199, e: 0.00677323, i: 3.39471, L: 181.97973, longPeri: 131.53298, longNode: 76.68069, LDot: 58517.81538729)),
            OrbitDefinition(name: "Earth", radius: 6371, startingPlanet: true, color: UIColor("6b93d6"), type: "Planet",
                            kepler: KeplerianElements(a: 1.00000011, e: 0.01671022, i: 0.00005, L: 100.46435, longPeri: 102.94719, longNode: -11.26064, LDot: 35999.37244981)),
            OrbitDefinition(name: "The Moon", radius: 1737.4, startingPlanet: false, color: .moonColor, type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 384400, e: 0.0549, i: 5.145, longNode: 125.08, argPeri: 318.15, meanAnomalyAtEpoch: 115.3654, meanMotionDegPerDay: 360 / 27.321661),
                            orbits: "Earth"),
            OrbitDefinition(name: "Brick World", radius: 6371, startingPlanet: false, color: UIColor("b55239"), type: "Planet",
                            kepler: KeplerianElements(a: 100.00000011, e: 0.01671022, i: 0.00005, L: 280.46435, longPeri: 102.94719, longNode: -11.26064, LDot: 35999.37244981)),
            OrbitDefinition(name: "Mars", radius: 3389.5, startingPlanet: false, color: UIColor("cd5c5c"), type: "Planet",
                            kepler: KeplerianElements(a: 1.52366231, e: 0.09341233, i: 1.85061, L: 355.45332, longPeri: 336.04084, longNode: 49.57854, LDot: 19140.30268499)),
            OrbitDefinition(name: "Phobos", radius: 11.267, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 9376, e: 0.0151, i: 1.075, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 0.31891),
                            orbits: "Mars"),
            OrbitDefinition(name: "Deimos", radius: 6.2, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 23463, e: 0.00033, i: 1.79, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 1.26244),
                            orbits: "Mars"),
            OrbitDefinition(name: "Ceres", radius: 473, startingPlanet: false, color: UIColor("9ca3af"), type: "Dwarf Planet",
                            kepler: KeplerianElements(a: 2.767, e: 0.0758, i: 10.593, L: 95.989, longPeri: 73.597, longNode: 80.305, LDot: 7828.0)),
            OrbitDefinition(name: "Jupiter", radius: 69911, startingPlanet: false, color: UIColor("fad5a5"), type: "Planet",
                            kepler: KeplerianElements(a: 5.20336301, e: 0.04839266, i: 1.3053, L: 34.40438, longPeri: 14.75385, longNode: 100.55615, LDot: 3034.90371757)),
            OrbitDefinition(name: "Io", radius: 1821.6, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 421700, e: 0.0041, i: 0.04, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 1.769),
                            orbits: "Jupiter"),
            OrbitDefinition(name: "Europa", radius: 1560.8, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 671100, e: 0.009, i: 0.47, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 3.551),
                            orbits: "Jupiter"),
            OrbitDefinition(name: "Ganymede", radius: 2634.1, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 1070400, e: 0.0013, i: 0.2, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 7.155),
                            orbits: "Jupiter"),
            OrbitDefinition(name: "Callisto", radius: 2410.3, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 1882700, e: 0.007, i: 0.19, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 16.689),
                            orbits: "Jupiter"),
            OrbitDefinition(name: "Saturn", radius: 58232, startingPlanet: false, color: UIColor("d8ca9d"), type: "Planet",
                            kepler: KeplerianElements(a: 9.53707032, e: 0.0541506, i: 2.48446, L: 49.94432, longPeri: 92.43194, longNode: 113.71504, LDot: 1222.11451204)),
            OrbitDefinition(name: "Titan", radius: 2574.7, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 1221870, e: 0.0288, i: 0.348, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 15.945),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Mimas", radius: 198.2, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 185539, e: 0.0196, i: 1.5, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 0.942422),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Enceladus", radius: 252.1, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 237948, e: 0.0047, i: 0.01, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 1.370218),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Tethys", radius: 531.1, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 294619, e: 0.0001, i: 1.09, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 1.887802),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Dione", radius: 561.4, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 377396, e: 0.0022, i: 0.02, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 2.736915),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Rhea", radius: 763.5, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 527108, e: 0.001, i: 0.33, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 4.518212),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Iapetus", radius: 734.5, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 3560820, e: 0.0286, i: 7.5, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 79.3215),
                            orbits: "Saturn"),
            OrbitDefinition(name: "Uranus", radius: 25362, startingPlanet: false, color: UIColor("4fd0e7"), type: "Planet",
                            kepler: KeplerianElements(a: 19.19126393, e: 0.04716771, i: 0.76986, L: 313.23218, longPeri: 170.96424, longNode: 74.22988, LDot: 428.49512562)),
            OrbitDefinition(name: "Miranda", radius: 235.8, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 129900, e: 0.0013, i: 4.34, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 1.4135),
                            orbits: "Uranus"),
            OrbitDefinition(name: "Ariel", radius: 578.9, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 190900, e: 0.0012, i: 0.26, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 2.52),
                            orbits: "Uranus"),
            OrbitDefinition(name: "Umbriel", radius: 584.7, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 266000, e: 0.0039, i: 0.36, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 4.144),
                            orbits: "Uranus"),
            OrbitDefinition(name: "Titania", radius: 788.4, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 436300, e: 0.0011, i: 0.08, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 8.706),
                            orbits: "Uranus"),
            OrbitDefinition(name: "Oberon", radius: 761.4, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 583500, e: 0.0014, i: 0.1, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 13.463),
                            orbits: "Uranus"),
            OrbitDefinition(name: "Neptune", radius: 24622, startingPlanet: false, color: UIColor("4b70dd"), type: "Planet",
                            kepler: KeplerianElements(a: 30.06896348, e: 0.00858587, i: 1.76917, L: 304.88003, longPeri: 44.97135, longNode: 131.72169, LDot: 218.46515314)),
            OrbitDefinition(name: "Triton", radius: 1353.4, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 354759, e: 0.00002, i: 156.8, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: -360 / 5.8769),
                            orbits: "Neptune"),
            OrbitDefinition(name: "Pluto", radius: 1188.3, startingPlanet: false, color: UIColor("a0522d"), type: "Dwarf Planet",
                            kepler: KeplerianElements(a: 39.48168677, e: 0.24880766, i: 17.14175, L: 238.92881, longPeri: 224.06676, longNode: 110.30347, LDot: 145.20780515)),
            OrbitDefinition(name: "Charon", radius: 606, startingPlanet: false, color: UIColor("c0c0c0"), type: "Moon",
                            satellite: SatelliteElements(semiMajorAxisKm: 19571, e: 0.0002, i: 0.08, longNode: 0, argPeri: 0, meanAnomalyAtEpoch: 0, meanMotionDegPerDay: 360 / 6.38723),
                            orbits: "Pluto"),
            OrbitDefinition(name: "Makemake", radius: 715, startingPlanet: false, color: UIColor("d4a373"), type: "Dwarf Planet",
                            kepler: KeplerianElements(a: 45.5, e: 0.16, i: 29.0, L: 185.3, longPeri: 16.3, longNode: 79.3, LDot: 117.2)),
            OrbitDefinition(name: "Gonggong", radius: 615, startingPlanet: false, color: UIColor("7b5cff"), type: "Dwarf Planet",
                            kepler: KeplerianElements(a: 66.9, e: 0.503, i: 30.9, L: 295.0, longPeri: 184.0, longNode: 337.0, LDot: 65.7)),
            OrbitDefinition(name: "Sedna", radius: 500, startingPlanet: false, color: UIColor("8b0000"), type: "Dwarf Planet",
                            kepler: KeplerianElements(a: 518, e: 0.85, i: 11.93, L: 96.0, longPeri: 95.3, longNode: 144.0, LDot: 3.16)),
            OrbitDefinition(name: "Proxima Centauri", radius: 107280, startingPlanet: false, color: UIColor("ffcccc"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 14, raMinutes: 29, raSeconds: 42.95, decDegrees: -62, decMinutes: 40, decSeconds: 46.1, distanceLightYears: 4.2465)),
            OrbitDefinition(name: "Alpha Centauri A", radius: 854190, startingPlanet: false, color: UIColor("fff5e0"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 14, raMinutes: 39, raSeconds: 36.49, decDegrees: -60, decMinutes: 50, decSeconds: 2.3, distanceLightYears: 4.37)),
            OrbitDefinition(name: "Alpha Centauri B", radius: 602050, startingPlanet: false, color: UIColor("ffd699"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 14, raMinutes: 39, raSeconds: 35.06, decDegrees: -60, decMinutes: 50, decSeconds: 13.8, distanceLightYears: 4.37)),
            OrbitDefinition(name: "Barnard's Star", radius: 136150, startingPlanet: false, color: UIColor("ffb3b3"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 17, raMinutes: 57, raSeconds: 48.5, decDegrees: 4, decMinutes: 41, decSeconds: 36.2, distanceLightYears: 5.96)),
            OrbitDefinition(name: "Wolf 359", radius: 111410, startingPlanet: false, color: UIColor("ff9999"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 10, raMinutes: 56, raSeconds: 29.2, decDegrees: 7, decMinutes: 0, decSeconds: 52.8, distanceLightYears: 7.86)),
            OrbitDefinition(name: "Lalande 21185", radius: 264690, startingPlanet: false, color: UIColor("ffb3b3"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 11, raMinutes: 3, raSeconds: 20.2, decDegrees: 35, decMinutes: 58, decSeconds: 11.5, distanceLightYears: 8.31)),
            OrbitDefinition(name: "Sirius", radius: 1189340, startingPlanet: false, color: UIColor("a8c8ff"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 6, raMinutes: 45, raSeconds: 8.9, decDegrees: -16, decMinutes: 42, decSeconds: 58.0, distanceLightYears: 8.6)),
            OrbitDefinition(name: "Gliese 65 A (BL Ceti)", radius: 100490, startingPlanet: false, color: UIColor("ff8080"), type: "Star",
                            fixedPositionAU: (x: luytenBase.x - luytenOffsetAU, y: luytenBase.y, z: luytenBase.z)),
            OrbitDefinition(name: "Gliese 65 B (UV Ceti)", radius: 100490, startingPlanet: false, color: UIColor("ff8080"), type: "Star",
                            fixedPositionAU: (x: luytenBase.x + luytenOffsetAU, y: luytenBase.y, z: luytenBase.z)),
            OrbitDefinition(name: "Ross 154", radius: 146430, startingPlanet: false, color: UIColor("ffb3b3"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 18, raMinutes: 49, raSeconds: 49.4, decDegrees: -23, decMinutes: 50, decSeconds: 10.4, distanceLightYears: 9.69)),
            OrbitDefinition(name: "Ross 248", radius: 111410, startingPlanet: false, color: UIColor("ff9999"), type: "Star",
                            fixedPositionAU: raDecDistToEclipticAU(raHours: 23, raMinutes: 41, raSeconds: 54.7, decDegrees: 44, decMinutes: 10, decSeconds: 30.3, distanceLightYears: 10.3))
        ]
    }()
    
    var menuView: MenuView!
    
    var xPositionLabel: UILabel!
    var yPositionLabel: UILabel!
    var zPositionLabel: UILabel!
    var xVelocityLabel: UILabel!
    var yVelocityLabel: UILabel!
    var loadingLabel = UILabel()

    
    var username: String! {
        didSet {
            if let name = username
            {
                usernameLabel.text = "\(name)"
            }
            else
            {
                usernameLabel.text = ""
            }
        }
    }
    
    var usernameLabel = UILabel()
    
    weak var appDelegate : AppDelegate!
    
    var dateString : String!
    private var lastPlanetUpdateDate: String? {
        didSet {
            userDefaults.set(lastPlanetUpdateDate, forKey: StorageKey.lastPlanetUpdate)
        }
    }
    private var planetPositionTimestamp: Int? {
        didSet {
            if let value = planetPositionTimestamp {
                userDefaults.set(value, forKey: StorageKey.planetPositionTimestamp)
            }
        }
    }
    private var planetPositionDate: Date {
        if let timestamp = planetPositionTimestamp {
            return Date(timeIntervalSince1970: Double(timestamp) / 1000)
        }
        return Date()
    }
    
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
    var planetLabelDict = [String: PlanetLabel]()
    var planetArray = [Planet]()
    var planetList : [String]!
    var starList : [String]!
    
    let sceneCam = SKCameraNode()
    
    var setACourseButton = UIButton()
    var goButton = UIButton()
    var cancelButton = UIButton()
    let menuButton = UIButton()
    
    var planetSelection: Planet!
    var travelingTo: Planet! {
        didSet {
            setTimeToPlanetLabel()
        }
    }
    
    var consoleView : ConsoleView!

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
    
    var timestamp : Int! {
        didSet {
            if view != nil
            {
                setSpeedBoostTimeLabel()
                setTimeToPlanetLabel()
                checkIfBoostedOrLanded()
            }
        }
    }
    
    var nextSpeedBoostTime = Int.max
    var willLandOnPlanetTime = Int.max
    
    var pushTimer: Timer!
    var calcVelocityTimer: Timer!
    var loadDateTimer: Timer!
    var loadPlanetImagesTimer: Timer!
    var updatePlanetLabelsTimer: Timer!
    
    var localTime: TimeInterval!
    
    var goToOrDestroy = String()
    var blueOrNormal = String()
    
    var traveledToDict = [String: Bool]() {
        didSet {
            let traveledToKeysCount = Array(self.traveledToDict.keys).count
            let threshold = 47
            let belowThreshold = traveledToKeysCount < threshold
            goToOrDestroy = belowThreshold ? "Go to" : "Destroy"
            self.setACourseButton.setTitle(belowThreshold ? "Set a Course" : "Destroy a Planet", for: .normal)
            blueOrNormal = belowThreshold ? "rocket" : "blue rocket"
            userDefaults.set(traveledToDict, forKey: StorageKey.traveledTo)
        }
    }
    var flagsDict = [String: Any]()
    
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
        consoleView.speedLabel.text = "Speed: \(formatSpeed(Double(velocity)))"
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func didMove(to view: SKView) {
        
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }

        
        appDelegate = UIApplication.shared.delegate as? AppDelegate

        menuView = MenuView(frame: self.frame, gamescene: self)
        consoleView = ConsoleView(gameScene: self)
        
        self.view?.backgroundColor = .spaceColor
        self.view?.window?.backgroundColor = .spaceColor
        self.backgroundColor = .spaceColor
        
        camera = sceneCam
        camera?.name = "camera"
        
        self.view?.window?.addSubview(consoleView)
        consoleView.translatesAutoresizingMaskIntoConstraints = false

        let consoleCenterXConstraint = NSLayoutConstraint(item: consoleView!, attribute: .centerX, relatedBy: .equal, toItem: view.window, attribute: .centerX, multiplier: 1, constant: 0)
        let consoleBottomConstraint = NSLayoutConstraint(item: consoleView!, attribute: .bottom, relatedBy: .equal, toItem: view.window, attribute: .bottomMargin, multiplier: 1, constant: -25)
        let consoleWidthConstraint = NSLayoutConstraint(item: consoleView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        let consoleHeightConstraint = NSLayoutConstraint(item: consoleView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 225)
        consoleCenterXConstraint.identifier = constraintEnum.consoleCenterX.rawValue
        consoleBottomConstraint.identifier = constraintEnum.consoleBottom.rawValue
        consoleWidthConstraint.identifier = constraintEnum.consoleWidth.rawValue
        consoleHeightConstraint.identifier = constraintEnum.consoleHeight.rawValue
        view.window!.addConstraints([consoleCenterXConstraint, consoleBottomConstraint, consoleWidthConstraint, consoleHeightConstraint])
        
        let pinch = UIPinchGestureRecognizer(target: self, action:#selector(self.pinchRecognized(sender:)))
        pinch.delegate = self
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(self.rotationRecognized(sender:)))
        rotate.delegate = self
        self.view?.addGestureRecognizer(pinch)
        self.view?.addGestureRecognizer(rotate)
        
        
        
        if let savedName = userDefaults.string(forKey: StorageKey.nickname)
        {
            username = savedName
            hardLoad()
        }
        else
        {
            nicknameSetup()
        }
        
        let setACourseButtonWidth = 150.0
        setACourseButton.frame = CGRect(x: (self.view?.center.x)! - CGFloat(setACourseButtonWidth / 2), y: self.view!.frame.height / 4, width: CGFloat(setACourseButtonWidth), height: CGFloat(30.0))
        formatButton(setACourseButton)
        setACourseButton.isHidden = true
        
        self.view?.addSubview(goButton)
        formatButton(goButton)
        goButton.isHidden = true
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.topAnchor.constraint(equalTo: consoleView.bottomAnchor, constant: 20).isActive = true
        goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        goButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view?.addSubview(cancelButton)
        formatButton(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -20).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.isHidden = true
        cancelButton.setTitle("Cancel", for: .normal)
        
        versionLabel.text = "v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (\(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))"
        versionLabel.frame = CGRect(x: 20.0, y: (self.view?.frame.maxY)! - 25, width: 300, height: 30)
        versionLabel.font = UIFont(name: versionLabel.font.fontName, size: 10)
        
        usernameLabel.font = UIFont(name: versionLabel.font.fontName, size: 12)
        
        consoleView.isHidden = true
        
        formatLabel(versionLabel)
        formatLabel(usernameLabel)
        
        
        self.view?.addSubview(versionLabel)
        self.view?.addSubview(menuButton)
        self.view?.addSubview(usernameLabel)
        self.view?.addSubview(setACourseButton)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 5).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        
        menuButton.isHidden = true
        menuButton.setImage(UIImage(named: "menuIcon"), for: .normal)
        menuButton.addTarget(self, action:#selector(buttonPressed), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -15).isActive = true
        menuButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 15).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        
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
        
        

        menuView.isHidden = true
        self.view?.addSubview(menuView)
        menuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
        button.backgroundColor = UIColor("000000").withAlphaComponent(0.5)
        button.setBackgroundColor(color: UIColor("111111").withAlphaComponent(1.0), forState: UIControl.State.selected)
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
            
            setView(view: setACourseButton, hide: true)
            setView(view: menuButton, hide: true)
            setView(view: cancelButton, hide: false)
            formatConsole(setACourseView: true)
            
        }
        else if sender == goButton
        {
            setView(view: goButton, hide: true)
            
            setView(view: setACourseButton, hide: false)
            setView(view: consoleView, hide: false)
            setView(view: menuButton, hide: false)
            setView(view: cancelButton, hide: true)
            
            willLandOnPlanetTime = Int.max
            
            velocity = calcSpeed()

            travelingTo = planetSelection
            planetSelection = nil
            currentPlanet = nil

            calculateVelocities()
            
            setTimes()
            
            formatConsole(setACourseView: false)
            
        }
        else if sender == cancelButton
        {
            setView(view: goButton, hide: true)
            
            setView(view: setACourseButton, hide: false)
            setView(view: consoleView, hide: false)
            setView(view: menuButton, hide: false)
            setView(view: cancelButton, hide: true)
            

            formatConsole(setACourseView: false)
            
        }
        else if sender == menuButton
        {
            setView(view: menuView, hide: false)
            
            setView(view: goButton, hide: true)
            setView(view: setACourseButton, hide: true)
            setView(view: consoleView, hide: true)
            setView(view: menuButton, hide: true)
        }
    }
    
    func prepareSignOut()
    {
        center.removeAllPendingNotificationRequests()
        for planet in planetDict.values
        {
            planet.fillTexture = nil
        }
        planetDict = [String: Planet]()
        traveledToDict = [String: Bool]()
        flagsDict = [String: Any]()
        coordinatesSet = false
        positionX = nil
        positionY = nil
        velocityX = 0
        velocityY = 0
        velocity = 0
        travelingTo = nil
        currentPlanet = nil
        nextSpeedBoostTime = Int.max
        willLandOnPlanetTime = Int.max
        userDefaults.removeObject(forKey: StorageKey.nickname)
        userDefaults.removeObject(forKey: StorageKey.coordinatesSet)
        userDefaults.removeObject(forKey: StorageKey.traveledTo)
        userDefaults.removeObject(forKey: StorageKey.flags)
        userDefaults.removeObject(forKey: StorageKey.position)
        nicknameSetup()
    }
    
    func hideMenu()
    {
        setView(view: menuView, hide: true)
        setView(view: setACourseButton, hide: false)
        setView(view: consoleView, hide: false)
        setView(view: menuButton, hide: false)
        
        for view in menuView.flagScrollView.subviews
        {
            view.removeFromSuperview()
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
        if distance(x1: rocket.position.x, x2: planet.position.x, y1: rocket.position.y, y2: planet.position.y) < radius //touch down on a planet
        {

            center.removeAllPendingNotificationRequests()
            
            currentPlanet = planet
            travelingTo = nil
            checkFlags()
            rocket.zRotation = angleBetween(x1: rocket.position.x, y1: rocket.position.y, x2: currentPlanet.position.x, y2: currentPlanet.position.y) + .pi / 2
            
            if traveledToDict[currentPlanet.name!] == nil
            {
                addVisitorToPlanet(currentPlanet.name!)
            }
            
            pushFlagsDict()
            traveledToDict[currentPlanet.name!] = true
            velocity = 0
            pushPositionToServer()
            setSpeedBoostTimeLabel()
        }
    }
    
    let currentFlag = "Flag"
    
    func checkFlags()
    {
        let flagName = "\(currentPlanet.name!) \(currentFlag)"
        if flagsDict[flagName] == nil
        {
            flagsDict[flagName] = ["number": 1, "timestamp": timestamp as Any]
            pushFlagsDict()
            loadDate(nil)
            consoleView.setNotification("You have obtained '\(flagName.replacingOccurrences(of: ",", with: "."))'!")
        }
    }
    
    func pushFlagsDict()
    {
        userDefaults.set(flagsDict, forKey: StorageKey.flags)
    }
    
    func addVisitorToPlanet(_ name: String)
    {

        if traveledToDict[name] != true
        {
            traveledToDict[name] = true
            NSLog("added visitor \(username!) to \(name)")
        }
    }
    
    var rotationOffset : CGFloat = 0.0
    
    @objc func rotationRecognized(sender: UIRotationGestureRecognizer)
    {
        if sender.state == .changed {
            let rotation = sender.rotation + rotationOffset
            camera?.zRotation = rotation
            
            for planetLabel in planetLabelDict.values
            {
                planetLabel.zRotation = rotation
            }
            
            movePlanetLabels()
        }
        
        if sender.state == .began
        {
            rotationOffset = camera!.zRotation - sender.rotation
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
            
            if camera!.xScale > CGFloat(30.0) {
                rocket.size = CGSize(width: camera!.xScale * 20 / 4, height: camera!.yScale * 40 / 4)
                rocket.alpha = 0.5
            }
            else {
                rocket.size = CGSize(width: 20.0, height: 40.0)
                rocket.alpha = 1.0
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
            
            for planetLabel in planetLabelDict.values
            {
                planetLabel.xScale = newScale
                planetLabel.yScale = newScale
                
                
            }
            
            movePlanetLabels()
            
            
            
            if camera!.xScale > CGFloat(1.5)
            {
                for key in starfieldDict.keys
                {
                    self.enumerateChildNodes(withName: key, using: ({
                        (node, error) in
                        setView(view: node, hide: true, setStartAlpha: false)
                    }))
                }
                setView(view: consoleView, hide: true)
                setView(view: setACourseButton, hide: true)
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
                setView(view: consoleView, hide: false)
                setView(view: setACourseButton, hide: false)
            }
            
            sender.scale = 1.0
        }
    }
    
    @objc func updatePlanetLabels()
    {
        updatePlanetLabelsTimer.invalidate()
        BG {
            var tempLabelNodeArray = [PlanetLabel]()
            for node in (self.camera?.containedNodeSet())!
            {
                if node is PlanetLabel
                {
                    tempLabelNodeArray.append(node as! PlanetLabel)
                }
            }
            
            tempLabelNodeArray.sort(by: {
                if $0.planet == self.travelingTo || $0.planet == self.currentPlanet
                {
                    return false
                }
                else if $1.planet == self.travelingTo || $1.planet == self.currentPlanet
                {
                    return true
                }
                return $0.planet.radius < $1.planet.radius
            })
            
            if tempLabelNodeArray.count > 1
            {
                
                for i in stride(from: tempLabelNodeArray.count - 1, to: 0, by: -1)
                {
                    let label1 = tempLabelNodeArray[i]
                    if label1.willBeHidden == false
                    {
                        for j in stride(from: i - 1, to: -1, by: -1)
                        {
                            let label2 = tempLabelNodeArray[j]
                            if label1.intersects(label2)
                            {
                                label2.willBeHidden = true
                                
                            }
                        }
                    }
                }
                
                for i in 0 ..< tempLabelNodeArray.count
                {
                    let label = tempLabelNodeArray[i]
                    
                    if label.alpha == 1.0 && label.willBeHidden == true
                    {
                        UI {
                            setView(view: label, hide: true, setStartAlpha: false)
                        }
                    }
                    else if label.alpha == 0.0 && label.willBeHidden == false
                    {
                        UI {
                            setView(view: label, hide: false, setStartAlpha: false)
                        }
                    }
                    label.willBeHidden = false
                    
                }
            }
            
            UI {
                self.startUpdatePlanetLabelsTimer()
            }
        }
    }
    
    func hardLoad()
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
                self.preparePlanetPositionTimestampForColdStart()
                self.loadPlanets({                      //part 3: load planets
                    
                    //self.addGameViews()
                    self.setCurrentAndTravelingPlanets()
                    
                    self.drawObjects()
                    if (self.currentPlanet != nil)
                    {
                        self.moveRocketToCurrentPlanet()
                    }
                    self.checkIfBoostedOrLanded()

                    self.startPushTimer()
                    self.calculateVelocities()
                    self.startCalculateVelocityTimer()
                    self.startLoadDateTimer()
                    self.startLoadPlanetImagesTimer()
                    self.startUpdatePlanetLabelsTimer()
                    self.setSpeedLabel()
                    self.setSpeedBoostTimeLabel()
                    self.setTimeToPlanetLabel()
                    self.createStarfield()
                    self.camera?.xScale = 1
                    self.camera?.yScale = 1
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
        setView(view: menuButton, hide: false)
        
        setView(view: goButton, hide: true)
        setView(view: cancelButton, hide: true)
        formatConsole(setACourseView: false)
        
        
        if camera?.parent == nil {
            self.addChild(camera!)
        }
    }
    
    func formatConsole(setACourseView: Bool)
    {
        if setACourseView {
            view?.window!.constraintWithIdentifier(constraintEnum.consoleHeight.rawValue)!.constant = 375
            view?.window!.constraintWithIdentifier(constraintEnum.consoleBottom.rawValue)!.constant = -175
            consoleView.preparePlanetList()
        }
        else
        {
            view?.window!.constraintWithIdentifier(constraintEnum.consoleHeight.rawValue)!.constant = 225
            view?.window!.constraintWithIdentifier(constraintEnum.consoleBottom.rawValue)!.constant = -25
            consoleView.prepareGo()
        }
        UIView.animate(withDuration: 0.5)
        {
            self.view?.window!.layoutIfNeeded()
        }
    }
    
    func makeStartElementsInvisible()
    {
        setView(view: rocket, hide: true)
        setView(view: consoleView, hide: true)
        setView(view: setACourseButton, hide: true)
        setView(view: loadingLabel, hide: false)
        setView(view: menuButton, hide: true)
        setView(view: goButton, hide: true)
        setView(view: cancelButton, hide: true)
        setView(view: menuView, hide: true)
        
        self.removeAllChildren()
        
        for planet in planetDict.values
        {
            planet.fillTexture = nil
        }
        
        
    }
    
    func getUserData(_ group: DispatchGroup)
    {
        if let savedName = userDefaults.string(forKey: StorageKey.nickname)
        {
            username = savedName
        }
        coordinatesSet = userDefaults.bool(forKey: StorageKey.coordinatesSet)
        traveledToDict = userDefaults.dictionary(forKey: StorageKey.traveledTo) as? [String: Bool] ?? [String: Bool]()

        if let tempFlagsDict = userDefaults.dictionary(forKey: StorageKey.flags) as? [String: Any] {
            flagsDict = tempFlagsDict
        }
        group.leave()
    }
    
    func nicknameSetup()
    {
        let nickname = "\(Words.adjectives[Int.random(in: 0 ..< Words.adjectives.count)])\(Words.nouns[Int.random(in: 0 ..< Words.nouns.count)])\(Int.random(in: 0 ..< 10000))"
        username = nickname
        userDefaults.set(nickname, forKey: StorageKey.nickname)
        hardLoad()
    }

    func addGameViews()
    {
        self.view?.addSubview(consoleView)
    }
    
    func startPushTimer()
    {
        pushTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(pushPositionToServer), userInfo: nil, repeats: true)
    }
    
    func startUpdatePlanetLabelsTimer()
    {
        updatePlanetLabelsTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePlanetLabels), userInfo: nil, repeats: false)
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

    private func shouldUpdatePlanetPositionTimestampOnColdStart() -> Bool
    {
        if coordinatesSet == false {
            return true
        }
        return travelingToName == nil && currentPlanetName != nil
    }

    private func preparePlanetPositionTimestampForColdStart()
    {
        if planetPositionTimestamp == nil {
            planetPositionTimestamp = userDefaults.object(forKey: StorageKey.planetPositionTimestamp) as? Int
        }
        guard shouldUpdatePlanetPositionTimestampOnColdStart() else { return }
        planetPositionTimestamp = Int(Date().timeIntervalSince1970 * 1000)
    }
    
    func loadDate(_ group: DispatchGroup! )
    {
        let now = Date()
        timestamp = Int(now.timeIntervalSince1970 * 1000)
        if (group != nil)
        {
            group.leave()
        }
        NSLog("date loaded")
    }
    
    func loadPlanetList( _ group: DispatchGroup)
    {
        planetList = orbitDefinitions.map { $0.name }
        starList = []
        group.leave()
        NSLog("planet list loaded")
    }
    
    func loadPlanets( _ callback: @escaping () -> () )
    {
        let positions = computeOrbitPositions(for: planetPositionDate)
        for definition in orbitDefinitions
        {
            guard let position = positions[definition.name] else { continue }
            let x = Int(position.x * coordMultiplier * AU)
            let y = Int(position.y * coordMultiplier * AU)
            let planet = Planet(name: definition.name,
                                radius: definition.radius,
                                startingPlanet: definition.startingPlanet,
                                x: x,
                                y: y,
                                color: definition.color,
                                type: definition.type)
            planetDict[definition.name] = planet
        }
        callback()
    }

    func computeOrbitPositions(for date: Date) -> [String: (x: Double, y: Double, z: Double)]
    {
        var positions = [String: (x: Double, y: Double, z: Double)]()
        for definition in orbitDefinitions
        {
            if let fixed = definition.fixedPositionAU
            {
                positions[definition.name] = fixed
                continue
            }
            if let kepler = definition.kepler
            {
                positions[definition.name] = keplerianPositionAU(elements: kepler, date: date)
                continue
            }
            if let satellite = definition.satellite,
               let parent = definition.orbits,
               let parentPosition = positions[parent]
            {
                let satellitePosition = satellitePositionAU(elements: satellite, date: date)
                positions[definition.name] = (x: parentPosition.x + satellitePosition.x,
                                              y: parentPosition.y + satellitePosition.y,
                                              z: parentPosition.z + satellitePosition.z)
                continue
            }
            positions[definition.name] = (x: 0, y: 0, z: 0)
        }
        return positions
    }

    func updatePlanetPositions()
    {
        guard planetDict.isEmpty == false else { return }
        let positions = computeOrbitPositions(for: planetPositionDate)
        for definition in orbitDefinitions
        {
            guard let position = positions[definition.name],
                  let planet = planetDict[definition.name] else { continue }
            planet.x = Int(position.x * coordMultiplier * AU)
            planet.y = Int(position.y * coordMultiplier * AU)
        }
        if positionX != nil && positionY != nil
        {
            movePlanets()
        }
    }
    
    func drawObjects()
    {
        for planet in planetDict.values
        {
            //planet.isHidden = true
            planet.zPosition = CGFloat(-1 / planet.radius)
            if planet.startingPlanet == true //process the starting planet first
            {
                
                rocket = SKSpriteNode(imageNamed: "\(blueOrNormal).png")
                rocket.size = CGSize(width: 20, height: 40)
                rocket.zPosition = 2

                self.addChild(rocket)
                camera!.position = CGPoint(x: 0, y: 0)
                rocket.position = camera!.position
                self.addChild(planet)
                
                if !coordinatesSet
                {
                    NSLog("coordinates not set")
                    coordinatesSet = true
                    positionX = planet.x
                    positionY = planet.y + Int(planet.radius) * Int(coordMultiplier)
                    userDefaults.set(true, forKey: StorageKey.coordinatesSet)
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
            if planet.startingPlanet == false
            {
                planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
                self.addChild(planet)
            }
            
            let planetLabel = PlanetLabel(planet: planet)
            planetLabel.position = CGPoint(x: planet.position.x, y: planet.position.y + CGFloat(planet.radius!) + 10.0)
            planetLabel.fontSize = 12
            self.addChild(planetLabel)
            planetLabelDict[planet.name!] = planetLabel
            physicsWorld.contactDelegate = self
            
        }
    }
    
    override func sceneDidLoad() {

    }
    
    @objc func pushPositionToServer()
    {
        let travelingToName = travelingTo != nil ? travelingTo.name : "nil"
        let currentPlanetName = currentPlanet != nil ? currentPlanet.name : "nil"
        
        if positionX == nil
        {
            return
        }

        userDefaults.set(
            ["positionX" : positionX!,
             "positionY" : positionY!,
             "velocityX" : velocityX,
             "velocityY" : velocityY,
             "timestamp": Int(Date().timeIntervalSince1970 * 1000),
             "travelingTo" : travelingToName as Any,
             "currentPlanet" : currentPlanetName as Any,
             "velocity" : velocity,
             "nextSpeedBoostTime": nextSpeedBoostTime,
             "willLandOnPlanetTime" : willLandOnPlanetTime],
            forKey: StorageKey.position)
    }
    
    func getPositionFromServer(_ group: DispatchGroup!)
    {
        if let coordDict = userDefaults.dictionary(forKey: StorageKey.position)
        {
            velocity = coordDict["velocity"] as? Double ?? 0
            positionX = coordDict["positionX"] as? Int
            positionY = coordDict["positionY"] as? Int
            velocityX = coordDict["velocityX"] as? Double ?? 0
            velocityY = coordDict["velocityY"] as? Double ?? 0
            travelingToName = coordDict["travelingTo"] as? String
            currentPlanetName = coordDict["currentPlanet"] as? String
            if travelingToName == "nil" {
                travelingToName = nil
            }
            if currentPlanetName == "nil" {
                currentPlanetName = nil
            }
            nextSpeedBoostTime = coordDict["nextSpeedBoostTime"] as? Int ?? Int.max
            willLandOnPlanetTime = coordDict["willLandOnPlanetTime"] as? Int ?? Int.max

            if let oldTimestamp = coordDict["timestamp"] as? Int
            {
                let millisecondsElapsed = timestamp - oldTimestamp
                NSLog("\(millisecondsElapsed) milliseconds since last load")
                if (timestamp > willLandOnPlanetTime) {
                    positionX = 0
                    positionY = 0
                }
                else if let posX = positionX, let posY = positionY {
                    positionX = posX + Int(velocityX / millisecondsPerHour * Double(millisecondsElapsed))
                    positionY = posY + Int(velocityY / millisecondsPerHour * Double(millisecondsElapsed))
                }
            }
        }

        if positionX == nil || positionY == nil {
            coordinatesSet = false
            travelingToName = nil
            currentPlanetName = nil
            userDefaults.set(false, forKey: StorageKey.coordinatesSet)
        }

        if (group != nil)
        {
            group.leave()
        }
    }
    
    func checkIfBoostedOrLanded()
    {
        if (self.timestamp > willLandOnPlanetTime && travelingTo != nil)
        {
            currentPlanet = travelingTo
            travelingTo = nil
            moveRocketToCurrentPlanet()
        }
        else if (self.timestamp > self.nextSpeedBoostTime && travelingTo != nil)
        {
            nextSpeedBoostTime = Int.max
            consoleView.setNotification("Your speed has doubled!")
            NSLog("speed boosted")
            velocity *= 2
            
            setTimes()
            calculateVelocities()
        }
        else
        {
            NSLog("speed not boosted, need to wait \(self.nextSpeedBoostTime - self.timestamp) milliseconds")
            self.setSpeedBoostTimeLabel()
            self.setTimeToPlanetLabel()
        }
    }
    
    func setTimes()
    {
        center.removeAllPendingNotificationRequests()
        
        let group = DispatchGroup()
        group.enter()
        loadDate(group)
        
        group.notify(queue: .main) {
            guard let planet = self.travelingTo else { return }
            planet.calculateDistance(x: self.positionX, y: self.positionY)
            self.willLandOnPlanetTime = self.timestamp + Int(self.travelingTo.distance / Double(self.velocity) * 3600000.0)

            self.nextSpeedBoostTime = self.timestamp + 43200000
            self.setSpeedBoostTimeLabel()
            self.setTimeToPlanetLabel()
            NSLog("next speed boost time set: \(self.nextSpeedBoostTime)")
            self.pushPositionToServer()
            
            if (self.willLandOnPlanetTime > self.nextSpeedBoostTime)
            {
                let speedBoostContent = UNMutableNotificationContent()
                speedBoostContent.title = "You have an available speed boost!"
                speedBoostContent.body = ""
                speedBoostContent.sound = UNNotificationSound.default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double((self.nextSpeedBoostTime - self.timestamp) / 1000), repeats: false)
                let request = UNNotificationRequest(identifier: "Speed Boost", content: speedBoostContent, trigger: trigger)
                
                self.center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
            }
            let willLandContent = UNMutableNotificationContent()
            willLandContent.title = "You have landed on \(self.travelingTo.name!)"
            willLandContent.body = ""
            willLandContent.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double((self.willLandOnPlanetTime - self.timestamp) / 1000), repeats: false)
            let request = UNNotificationRequest(identifier: "Landed", content: willLandContent, trigger: trigger)
            
            self.center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })

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
        center.removeAllPendingNotificationRequests()
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
        checkFlags()
    }
    
    func movePlanets()
    {
        for planet in planetDict.values
        {
            planet.position = CGPoint(x: Double(planet.x - positionX!) / coordMultiplier, y: Double(planet.y - positionY!) / coordMultiplier)
        }
        movePlanetLabels()

    }
    
    func movePlanetLabels()
    {
        for planetLabel in planetLabelDict.values
        {
            if let planet = planetLabel.planet
            {
                if let rot = camera?.zRotation
                {
                    let xRot = cos(rot + .pi / 2)
                    let yRot = sin(rot + .pi / 2)
                    let xPoint = planet.position.x + xRot * (CGFloat(planet.radius) + 5 * camera!.xScale)
                    let yPoint = planet.position.y + yRot * (CGFloat(planet.radius) + 5 * camera!.xScale)
                    planetLabel.position = CGPoint(x: xPoint, y: yPoint)
                }
            }
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
                else if planet.type == "Star" && planet.name == "The Sun"
                {
                    speedSum += 15000
                }
                else if planet.type == "Star"
                {
                    speedSum += 100000
                }
                else if planet.type == "Red Dwarf Star"
                {
                    speedSum += 70000
                }
                else if planet.type == "Asteroid"
                {
                    speedSum += 2000
                }
                else if planet.type == "Comet"
                {
                    speedSum += 6666
                }
                else if planet.type == "Black Hole"
                {
                    speedSum += 200000
                }
                else if planet.type == "Brick World"
                {
                    speedSum += 123456
                }
            }
        }
        return Double(speedSum)
    }

    @objc func loadPlanetImages()
    {
        loadPlanetImagesTimer.invalidate()
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            for key in self.planetTexturesDict.keys
            {
                if let planet = self.planetDict[key]
                {
                    if self.camera!.xScale < CGFloat(planet.radius * 2) && (self.camera?.contains(planet))!
                    {
                        if planet.fillTexture == nil
                        {
                            if let image = UIImage(named: "\(planet.name!)")
                            {
                                planet.fillTexture = SKTexture.init(image: image)
                                planet.fillColor = .white
                                print("filled \(planet.name!) texture")
                            }
                        }
                    }
                    else
                    {
                        if planet.fillTexture != nil
                        {
                            planet.fillTexture = nil
                            planet.fillColor = planet.color
                            print("reset \(planet.name!) texture")

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
            
            movePlanets()
            
            moveStarField(timeDiff)
            checkTouchDown()

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planetDict.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
                    starfield.zPosition = -2
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
    
}

enum constraintEnum: String {
    case consoleWidth, consoleHeight, consoleBottom, consoleCenterX
}


