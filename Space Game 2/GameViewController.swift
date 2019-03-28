//
//  GameViewController.swift
//  SpaceRace
//
//  Created by Aaron Becker on 3/13/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if let view = self.view as! SKView? {
        
        
        
//                self.view = SKView()
//                
//                if let view = self.view as! SKView? {
//                    // Load the SKScene from 'GameScene.sks'
//                    let scene = GameScene(size: view.bounds.size)
//                    // Set the scale mode to scale to fit the window
//                    scene.scaleMode = .aspectFill
//                    
//                    
//                    
//                    // Present the scene
//                    view.presentScene(scene)
//                    
//                    
//                    view.ignoresSiblingOrder = true
//                    
//                    view.showsFPS = true
//                    view.showsNodeCount = true
//                }
//               
       // }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
