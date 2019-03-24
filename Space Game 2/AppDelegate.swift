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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("signed in")
            self.window?.rootViewController?.view = SKView()
            
            if let view = self.window?.rootViewController?.view as! SKView? {
                
                let scene = GameScene(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                
                
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }

    var window: UIWindow?
    var username: String!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        let signInViewController: SignInViewController = SignInViewController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = signInViewController
        self.window!.backgroundColor = UIColor.black
        self.window!.makeKeyAndVisible()
        
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        
        
//        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
//        let fileName = "dict";
//
//        if let documentPath = paths.first {
//            let filePath = NSMutableString(string: documentPath).appendingPathComponent(fileName);
//
//            let URL = NSURL.fileURL(withPath: filePath)
//
//            let dictionary = NSMutableDictionary(capacity: 0);
//
//            dictionary.setValue(username, forKey: "username");
//
//            let success = dictionary.write(to: URL, atomically: true)
//            print("write: ", success);
//        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //GIDSignIn.sharedInstance().signOut()
    }

   
}

