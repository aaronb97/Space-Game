import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn


class SignInViewController: UIViewController, GIDSignInUIDelegate{
    
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
    
}
