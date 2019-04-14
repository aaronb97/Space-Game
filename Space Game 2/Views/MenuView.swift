//
//  MenuView.swift
//  Space Game 2
//
//  Created by Aaron Becker on 4/11/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import UIKit

class MenuView : UIView, UITableViewDelegate, UITableViewDataSource {
    
    let signOutButton = UIButton()
    let flagsButton = UIButton()
    let backButton = UIButton()
    let flagTableView = UITableView()
    weak var gameScene: GameScene!
    var flagNames = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(signOutButton)
        formatButton(signOutButton)
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -30).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(flagsButton)
        formatButton(flagsButton)
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
        
        addSubview(flagTableView)
        flagTableView.isHidden = true
        flagTableView.translatesAutoresizingMaskIntoConstraints = false
        flagTableView.leftAnchor.constraint(equalTo: self.safeLeftAnchor).isActive = true
        flagTableView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10).isActive = true
        flagTableView.rightAnchor.constraint(equalTo: self.safeRightAnchor).isActive = true
        flagTableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor).isActive = true
        flagTableView.delegate = self
        flagTableView.dataSource = self
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    convenience init(frame: CGRect, gamescene: GameScene)
    {
        self.init(frame: frame)
        self.gameScene = gamescene
        self.flagNames = Array(gamescene.flagsDict.keys)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func formatButton(_ button: UIButton)
    {
        button.setTitleColor(UIColor.white, for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action:#selector(buttonPressed), for: .touchUpInside)
        button.backgroundColor = UIColor("000000").withAlphaComponent(0.8)
        button.setBackgroundColor(color: UIColor("111111").withAlphaComponent(1.0), forState: UIControl.State.highlighted)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func buttonPressed(_ button: UIButton)
    {
        if button == signOutButton
        {
            gameScene.prepareSignOut()
        }
        else if button == backButton
        {
            if flagTableView.isHidden == false
            {
                setView(view: flagTableView, hide: true)
                setView(view: flagsButton, hide: false)
            }
            else
            {
                gameScene.hideMenu()
            }
        }
        else if button == flagsButton
        {
            setView(view: flagsButton, hide: true)
            flagNames = Array(gameScene.flagsDict.keys)
            flagTableView.reloadData()
            setView(view: flagTableView, hide: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return flagNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        let flagNumber = (gameScene.flagsDict[flagNames[indexPath.row]] as! [String: Any])["number"] as! Int
        let flagNumberText = flagNumber > 0 ? "#\(flagNumber)" : ""
        cell?.textLabel?.text = "\(flagNames[indexPath.row].replacingOccurrences(of: ",", with: ".")) \(flagNumberText)"
        return cell!
    }
}
