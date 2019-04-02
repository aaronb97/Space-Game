import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn
import SpriteKit
import GameplayKit


class SignInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    let SIGNIN_HEIGHT = CGFloat(40)
    let SIGNIN_WIDTH = CGFloat(140)
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance()?.signInSilently()

        let signInButton = GIDSignInButton()

        signInButton.frame = CGRect(x: (self.view.frame.size.width - SIGNIN_WIDTH) / 2, y: self.view.frame.size.height - 100, width: SIGNIN_WIDTH, height: SIGNIN_HEIGHT)
        self.view.addSubview(signInButton)

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    override func didMove(to view: SKView) {
//        self.view?.backgroundColor = .spaceColor
//        self.view?.window?.backgroundColor = .spaceColor
//        self.backgroundColor = .spaceColor
//
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().delegate = self
//        //GIDSignIn.sharedInstance().signIn()
//
//        let signInButton = GIDSignInButton()
//        signInButton.isHidden = false
//
//        //signInButton.frame = CGRect(x: ((self.scene?.view!.frame.size.width)! - SIGNIN_WIDTH) / 2, y: (self.scene?.view!.frame.size.height)! - 100, width: SIGNIN_WIDTH, height: SIGNIN_HEIGHT)
//        signInButton.frame = CGRect(x: 10, y: 50, width: SIGNIN_WIDTH, height: SIGNIN_HEIGHT)
//
//        self.scene?.view?.addSubview(signInButton)
//        print(signInButton)
//
//    }
}
    

