//
//  AppDelegate.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/21/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GameplayKit

var email: String!
var scene: GameScene!
var ref: DatabaseReference!
var signInViewController = SignInViewController()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let gUser = user else {
            signInViewController.addSubViews()
            return
        }
        guard let authentication = gUser.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("signed in")
            
            UserDefaults.standard.set(signInViewController.stayLoggedInSwitch.isOn, forKey: "StaySignedIn")
            
            self.moveToGameScene()
        }
    }
    
    
    
    func moveToGameScene()
    {
        self.window?.rootViewController?.view = SKView()
        
        email = Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: ",")
        
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
        FirebaseApp.configure()
        
        ref = Database.database().reference()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.signInSilently()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.spaceColor
        
        self.window!.rootViewController = signInViewController
        
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func showSignInScreen()
    {
        self.window?.rootViewController?.view = UIView()
        signInViewController = SignInViewController()
        self.window?.rootViewController = signInViewController
        signInViewController.addSubViews()
        scene = nil
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if scene != nil
        {
            scene.pushPositionToServer()
            scene.pushTimer.invalidate()
            scene.loadDateTimer.invalidate()
            scene.calcVelocityTimer.invalidate()
        }
        print("resigned")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print(UserDefaults.standard.bool(forKey: "StaySignedIn"))
        if UserDefaults.standard.bool(forKey: "StaySignedIn") == false
        {
            GIDSignIn.sharedInstance()?.signOut()
            print("signed out?")
        }
        print("entered background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        
        print("entered foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if scene != nil {

            scene.loadEverything()
            scene.localTime = Date().timeIntervalSinceReferenceDate
        }
        
        print("became active")
    }
    
    

    func applicationWillTerminate(_ application: UIApplication) {
        if UserDefaults.standard.bool(forKey: "StaySignedIn") == false
        {
            GIDSignIn.sharedInstance()?.signOut()
            print("signed out?")
        }
        if scene != nil
        {
            scene.pushPositionToServer()
        }
        print("terminated")
    }

   
}

