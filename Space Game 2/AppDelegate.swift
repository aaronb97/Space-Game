//
//  AppDelegate.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/21/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var username: String!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        username =  UserDefaults.standard.value(forKey: "username") as? String
        
        print(username)
        return true
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setUsername(_ username: String)
    {
        self.username = username
        UserDefaults.standard.setValue(username, forKey: "username")
    }
    
    func getUsername() -> String! {
        return self.username
    }

}

