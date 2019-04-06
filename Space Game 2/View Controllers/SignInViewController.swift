import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn
import SpriteKit
import GameplayKit


class SignInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    let SIGNIN_HEIGHT = CGFloat(40)
    let SIGNIN_WIDTH = CGFloat(140)
    let stayLoggedInSwitch = UISwitch()
    
    let switchWidth : CGFloat = 51
    let switchHeight : CGFloat = 31
    let switchLabel = UILabel()
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    let signInButton = GIDSignInButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance()?.signInSilently()
        switchLabel.font = UIFont(name: switchLabel.font.fontName, size: 12)

        signInButton.frame = CGRect(x: (self.view.frame.size.width - SIGNIN_WIDTH) / 2, y: self.view.frame.size.height - 200, width: SIGNIN_WIDTH, height: SIGNIN_HEIGHT)
        stayLoggedInSwitch.frame = CGRect(x: CGFloat(self.view.frame.size.width / 2) - switchWidth / 2, y: signInButton.frame.maxY + 30, width: switchWidth, height: switchHeight)
        switchLabel.text = "Keep me signed in"
        switchLabel.frame = CGRect(x: CGFloat(self.view.frame.size.width / 2)  - CGFloat(Math.textWidth(text: switchLabel.text!, font: switchLabel.font) / 2),
                                   y: CGFloat(stayLoggedInSwitch.frame.maxY + 5), width: CGFloat(Math.textWidth(text: switchLabel.text!, font: switchLabel.font)), height: 20)
        switchLabel.textColor = .white
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "spacegameLaunch")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func addSubViews()
    {
        self.view.addSubview(signInButton)
        self.view.addSubview(stayLoggedInSwitch)
        self.view.addSubview(switchLabel)
        UserDefaults.standard.set(false, forKey: "StaySignedIn")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
    

