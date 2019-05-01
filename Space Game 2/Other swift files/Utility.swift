//
//  Math.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/30/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import GameplayKit


     let AU = 149597871.0
     let parsec = 3.086e+13
     let framesPerHour : Double = 216000
     let millisecondsPerHour : Double = 3600000
     let secondsPerHour : Double = 3600
     let coordMultiplier = 100.0
    
func setView(view: UIView, hide: Bool, option: UIView.AnimationOptions! = UIView.AnimationOptions.transitionCrossDissolve) {
    
        if let o = option
        {
            UIView.transition(with: view, duration: 0.5, options: o, animations: {
                view.isHidden = hide
            })
        }
        else {
            UIView.transition(with: view, duration: 0.5, animations: {
                view.isHidden = hide
            })
        }
    }

    func setView(view: SKNode!, hide: Bool, setStartAlpha: Bool = true)
    {
        if let node = view
        {
            if hide
            {
                if setStartAlpha
                {
                    node.alpha = 1.0
                }
                node.run(SKAction.fadeOut(withDuration: 0.5))
            }
            else
            {
                if setStartAlpha
                {
                    node.alpha = 0.0
                }
                node.run(SKAction.fadeIn(withDuration: 0.5))
            }
        }
    }
    
     func angleBetween(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return atan2(y2 - y1, x2 - x1)
    }
    
     func textWidth(text: String, font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }
    
     func distance(x1: Double, x2: Double, y1: Double, y2: Double) -> Double
    {
        return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
    }
    
     func distance(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) -> Double
    {
        return Double(sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)))
    }
    
     func formatDistance(_ number: Double) -> String
    {
        if number >= 1000000000000
        {
            return String(format: "%1.1f light years", number / 9.461e12)
        }
        if number >= 1000000000
        {
            return String(format: "%1.1f billion km", number / 1000000000)
        }
        else if number >= 1000000
        {
            return String(format: "%1.1f million km", number / 1000000)
        }
        else
        {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            return "\(numberFormatter.string(from: NSNumber(value: Int(number)))!) km"
        }
    }

    func formatSpeed(_ number: Double) -> String
    {
    if number >= 1.079e8
    {
        return String(format: "%1.1f times light speed", number / 1.079e9)
    }
    if number >= 1000000000
    {
        return String(format: "%1.1f billion km / hour", number / 1000000000)
    }
    else if number >= 1000000
    {
        return String(format: "%1.1f million km / hour", number / 1000000)
    }
    else
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return "\(numberFormatter.string(from: NSNumber(value: Int(number)))!) km"
    }
}
    
    
     func formatTime(_ seconds: Int) -> String
    {
        var returnText = ""
        
        var minutes = Double(seconds) / 60.0
        var hours = Double(minutes) / 60.0
        var days = Double(hours) / 24
        var years = Double(days) / 365
        let centuries = Double(years) / 100
        
        years = years.truncatingRemainder(dividingBy: 100.0)
        days = days.truncatingRemainder(dividingBy: 365.0)
        minutes = minutes.truncatingRemainder(dividingBy: 60.0)
        hours = hours.truncatingRemainder(dividingBy: 24.0)
        
        if centuries >= 1
        {
            returnText.append("\(Int(centuries))c ")
        }
        if centuries >= 1 || years >= 1
        {
            returnText.append("\(Int(years))y ")
        }
        if centuries >= 1 || years >= 1 || days >= 1
        {
            returnText.append("\(Int(days))d ")
        }
        if centuries >= 1 || years >= 1 || hours >= 1 || days >= 1
        {
            returnText.append("\(Int(hours))h ")
        }
        if centuries >= 1 || years >= 1 || minutes >= 1 || hours >= 1 || days >= 1
        {
            returnText.append("\(Int(minutes))m ")
        }
        else
        {
            return "< 1 minute"
        }
        return returnText
    }
    
     func showAlertMessage(_ vc: UIViewController, header: String, body: String) {
        
        let alertController = UIAlertController(title: header, message: body, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alertController, animated: true, completion: nil)
        
    }

    func sqrtPreserveSign(_ x: Double) -> Double
    {
        let posX = abs(x)
        return x > 0 ? sqrt(posX) : sqrt(posX) * -1
    }

    func BG(_ block: @escaping ()->Void) {
        DispatchQueue.global(qos: .default).async(execute: block)
    }

    func UI(_ block: @escaping ()->Void) {
        DispatchQueue.main.async(execute: block)
    }

