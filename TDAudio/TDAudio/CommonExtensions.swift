//
//  CommonExtensions.swift
//  Audio
//
//  Created by TH on 9/7/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import MediaPlayer
import UICheckbox_Swift


extension UIView {
    func fadeIn(duration: TimeInterval = 3.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        
        weak var weakSelf = self
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            weakSelf?.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 3.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        weak var weakSelf = self
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            weakSelf?.alpha = 0.0
        }, completion: completion)
    }
    
    //rotation animation, to stop, use MyView.layer.removeAllAnimations()
    func rotate360Degrees(duration: CFTimeInterval = 2) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
   
}

extension UIView {
    
    /// The ratio (from 0.0 to 1.0, inclusive) of the view's corner radius
    /// to its width. For example, a 50% radius would be specified with
    /// `cornerRadiusRatio = 0.5`.
    var cornerRadiusRatio: CGFloat {
        get {
            return layer.cornerRadius / frame.width
        }
        
        set {
            // Make sure that it's between 0.0 and 1.0. If not, restrict it
            // to that range.
            let normalizedRatio = max(0.0, min(1.0, newValue))
            layer.cornerRadius = frame.width * normalizedRatio
        }
    }
    
}

extension UIView {
    func getContraint(withIdentifier : String) -> NSLayoutConstraint? {
        for constraint in self.constraints where (constraint.identifier == withIdentifier){
            return constraint
        }
        return nil
    }
}


extension Date {
    var millisecondsSince1970:Double {
        return Double((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}


extension UINavigationBar {
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

