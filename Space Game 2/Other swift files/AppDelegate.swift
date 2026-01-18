//
//  AppDelegate.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/21/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import UIKit
import SpriteKit

var scene: GameScene!


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func moveToGameScene()
    {
        self.window?.rootViewController?.view = SKView()

        if let view = self.window?.rootViewController?.view as! SKView? {
            
            scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    var window: UIWindow?
    var username: String!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("launching")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.spaceColor
        self.window!.rootViewController = UIViewController()
        self.window!.makeKeyAndVisible()
        self.moveToGameScene()
        
        return true
    }
    
    func invalidateSceneTimers()
    {
        scene.pushTimer?.invalidate()
        scene.loadDateTimer?.invalidate()
        scene.calcVelocityTimer?.invalidate()
        scene.loadPlanetImagesTimer?.invalidate()
        scene.updatePlanetLabelsTimer?.invalidate()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if scene != nil
        {
            scene.pushPositionToServer()
            invalidateSceneTimers()
        }
        print("resigned")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("entered background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        
        print("entered foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if scene != nil {

            scene.hardLoad()
            scene.localTime = Date().timeIntervalSinceReferenceDate
        }
        
        print("became active")
    }
    
    

    func applicationWillTerminate(_ application: UIApplication) {
        if scene != nil
        {
            scene.pushPositionToServer()
        }
        print("terminated")
    }

   
}

