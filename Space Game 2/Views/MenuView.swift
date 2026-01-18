//
//  MenuView.swift
//  Space Game 2
//
//  Created by Aaron Becker on 4/11/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import UIKit

class MenuView : UIView{
    let flagsButton = UIButton()
    let backButton = UIButton()
    let flagScrollView = UIScrollView()
    //let flagTableView = UITableView()
    weak var gameScene: GameScene!
    var flagNames = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(flagsButton)
        formatButton(flagsButton)
        flagsButton.addTarget(self, action:#selector(buttonPressed), for: .touchUpInside)
        flagsButton.setTitle("Flags", for: .normal)
        flagsButton.translatesAutoresizingMaskIntoConstraints = false
        flagsButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        flagsButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 20).isActive = true
        flagsButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        flagsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(backButton)
        backButton.addTarget(self, action:#selector(buttonPressed), for: .touchUpInside)
        backButton.setImage(UIImage(named: "backIcon"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        backButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(flagScrollView)
        flagScrollView.isHidden = true
        flagScrollView.translatesAutoresizingMaskIntoConstraints = false
        flagScrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        flagScrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 15).isActive = true
        flagScrollView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        flagScrollView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -5).isActive = true
        
        

        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    convenience init(frame: CGRect, gamescene: GameScene)
    {
        self.init(frame: frame)
        self.gameScene = gamescene
        self.flagNames = Array(gamescene.flagsDict.keys)
        print(gamescene.flagsDict)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func formatButton(_ button: UIButton)
    {
        button.setTitleColor(UIColor.white, for: .normal)
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor("000000").withAlphaComponent(0.8)
        button.setBackgroundColor(color: UIColor("111111").withAlphaComponent(1.0), forState: UIControl.State.highlighted)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func buttonPressed(_ button: UIButton)
    {
        if button == backButton
        {
            if flagScrollView.isHidden == false
            {
                setView(view: flagScrollView, hide: true)
                setView(view: flagsButton, hide: false)
            }
            else
            {
                gameScene.hideMenu()
                
            }
        }
        else if button == flagsButton
        {
            for view in flagScrollView.subviews
            {
                view.removeFromSuperview()
            }
            flagNames = Array(gameScene.flagsDict.keys)
            
            flagNames.sort(by: {
                let timestamp0 = (gameScene.flagsDict[$0] as! [String: Any])["timestamp"] as? Int ?? 0
                let timestamp1 = (gameScene.flagsDict[$1] as! [String: Any])["timestamp"] as? Int ?? 0
                return timestamp0 < timestamp1
            })
            
            let verticalSpacing : CGFloat = 120
            setView(view: flagsButton, hide: true)
            
            let imageWidth : CGFloat = 190
            let imageHeight : CGFloat = 100
            let scrollViewContentSizeWidth : CGFloat = 300
            
            flagScrollView.contentSize = CGSize(width: Int(scrollViewContentSizeWidth), height: gameScene.flagsDict.keys.count * Int(verticalSpacing))
            
            
            for i in 0 ..< flagNames.count
            {
                let flagName = flagNames[i]
                let flagDict = gameScene.flagsDict[flagName] as! [String: Any]
                let flagNumber = flagDict["number"] as? Int ?? 0
                print("adding flag \(flagNames[i])")
                
                let image = UIImage(named: flagName) != nil ? UIImage(named: flagName) : UIImage(named: "FlagNotFound")
                
                let imageView = UIImageView(frame: CGRect(x: 0.0, y: CGFloat(i) * verticalSpacing, width: imageWidth, height: imageHeight))
                imageView.image = image
                flagScrollView.addSubview(imageView)
                
                if flagNumber <= 3 {
                    let flagNumberDict = [1: "border", 2: "silver border", 3: "bronze border"]
                    
                    if let borderImage = UIImage(named: flagNumberDict[flagNumber] ?? "") {
                        let imageView = UIImageView(frame: CGRect(x: 0.0, y: CGFloat(i) * verticalSpacing, width: imageWidth, height: imageHeight))
                        imageView.image = borderImage
                        flagScrollView.addSubview(imageView)
                    }
                }

                let flagLabel = UILabel(frame: CGRect(x: imageWidth + 5, y: CGFloat(i) * verticalSpacing, width: scrollViewContentSizeWidth - (imageWidth + 10), height: 100.0))
                flagLabel.font = UIFont(name: "Courier", size: 16)
                flagLabel.numberOfLines = 5
                flagLabel.text = flagName.replacingOccurrences(of: ",", with: ".")
                if flagNumber > 0
                {
                    flagLabel.text!.append(" #\(flagNumber)")
                }
                
                flagLabel.textColor = .white
                flagScrollView.addSubview(flagLabel)
            }
            setView(view: flagScrollView, hide: false)
        }
    }

}
