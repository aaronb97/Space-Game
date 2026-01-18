//
//  Math.swift
//  Space Game 2
//
//  Created by Aaron Becker on 3/30/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit
import UIKit

let AU = 149597871.0
let parsec = 3.086e+13
let framesPerHour : Double = 216000
let millisecondsPerHour : Double = 3600000
let secondsPerHour : Double = 3600
let coordMultiplier = 100.0
let julianDayJ2000 = 2451545.0
let lightYearInAU = 63241.077

struct KeplerianElements {
    let a: Double
    let e: Double
    let i: Double
    let L: Double
    let longPeri: Double
    let longNode: Double
    let LDot: Double
}

struct SatelliteElements {
    let semiMajorAxisKm: Double
    let e: Double
    let i: Double
    let longNode: Double
    let argPeri: Double
    let meanAnomalyAtEpoch: Double
    let meanMotionDegPerDay: Double
}

func julianDay(from date: Date) -> Double {
    let secondsPerDay = 86400.0
    return 2440587.5 + date.timeIntervalSince1970 / secondsPerDay
}

func normalizeDegrees(_ degrees: Double) -> Double {
    var value = degrees.truncatingRemainder(dividingBy: 360.0)
    if value < 0 {
        value += 360.0
    }
    return value
}

func keplerianPositionAU(elements: KeplerianElements, date: Date) -> (x: Double, y: Double, z: Double) {
    let centuries = (julianDay(from: date) - julianDayJ2000) / 36525.0
    let meanLongitude = normalizeDegrees(elements.L + elements.LDot * centuries)
    let meanAnomaly = normalizeDegrees(meanLongitude - elements.longPeri)
    let argPeri = normalizeDegrees(elements.longPeri - elements.longNode)
    return orbitalPositionAU(a: elements.a,
                             e: elements.e,
                             i: elements.i,
                             longNode: elements.longNode,
                             argPeri: argPeri,
                             meanAnomaly: meanAnomaly)
}

func satellitePositionAU(elements: SatelliteElements, date: Date) -> (x: Double, y: Double, z: Double) {
    let days = julianDay(from: date) - julianDayJ2000
    let meanAnomaly = normalizeDegrees(elements.meanAnomalyAtEpoch + elements.meanMotionDegPerDay * days)
    return orbitalPositionAU(a: elements.semiMajorAxisKm / AU,
                             e: elements.e,
                             i: elements.i,
                             longNode: elements.longNode,
                             argPeri: elements.argPeri,
                             meanAnomaly: meanAnomaly)
}

func orbitalPositionAU(a: Double, e: Double, i: Double, longNode: Double, argPeri: Double, meanAnomaly: Double) -> (x: Double, y: Double, z: Double) {
    let meanAnomalyRad = meanAnomaly * Double.pi / 180.0
    let eccentricAnomaly = solveEccentricAnomaly(meanAnomaly: meanAnomalyRad, e: e)
    let trueAnomaly = 2.0 * atan2(sqrt(1 + e) * sin(eccentricAnomaly / 2.0), sqrt(1 - e) * cos(eccentricAnomaly / 2.0))
    let radius = a * (1 - e * cos(eccentricAnomaly))

    let iRad = i * Double.pi / 180.0
    let longNodeRad = longNode * Double.pi / 180.0
    let argPeriRad = argPeri * Double.pi / 180.0
    let cosLongNode = cos(longNodeRad)
    let sinLongNode = sin(longNodeRad)
    let cosI = cos(iRad)
    let sinI = sin(iRad)
    let argument = argPeriRad + trueAnomaly
    let cosArg = cos(argument)
    let sinArg = sin(argument)

    let x = radius * (cosLongNode * cosArg - sinLongNode * sinArg * cosI)
    let y = radius * (sinLongNode * cosArg + cosLongNode * sinArg * cosI)
    let z = radius * (sinArg * sinI)
    return (x, y, z)
}

func solveEccentricAnomaly(meanAnomaly: Double, e: Double) -> Double {
    var eccentricAnomaly = meanAnomaly
    for _ in 0..<12 {
        let delta = (eccentricAnomaly - e * sin(eccentricAnomaly) - meanAnomaly) / (1 - e * cos(eccentricAnomaly))
        eccentricAnomaly -= delta
        if abs(delta) < 1e-8 {
            break
        }
    }
    return eccentricAnomaly
}

func raDecDistToEclipticAU(raHours: Double, raMinutes: Double, raSeconds: Double, decDegrees: Double, decMinutes: Double, decSeconds: Double, distanceLightYears: Double) -> (x: Double, y: Double, z: Double) {
    let raDegrees = (raHours * 15.0) + (raMinutes * 15.0 / 60.0) + (raSeconds * 15.0 / 3600.0)
    let decSign = decDegrees < 0 ? -1.0 : 1.0
    let decAbs = abs(decDegrees) + (decMinutes / 60.0) + (decSeconds / 3600.0)
    let dec = decSign * decAbs

    let raRad = raDegrees * Double.pi / 180.0
    let decRad = dec * Double.pi / 180.0
    let distanceAU = distanceLightYears * lightYearInAU

    let xEq = distanceAU * cos(decRad) * cos(raRad)
    let yEq = distanceAU * cos(decRad) * sin(raRad)
    let zEq = distanceAU * sin(decRad)

    let obliquity = 23.43928 * Double.pi / 180.0
    let x = xEq
    let y = yEq * cos(obliquity) + zEq * sin(obliquity)
    let z = -yEq * sin(obliquity) + zEq * cos(obliquity)
    return (x, y, z)
}

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

