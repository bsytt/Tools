//
//  UIBarButtonItemBadge.swift
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/3/3.
//  Copyright © 2019 bsy. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    
    private struct AssociatedKey {
        static var badge: UILabel = UILabel()
        static var badgeValue : NSString = "0"
        static var badgeBGColor : UIColor = .red
        static var badgeTextColor : UIColor = .white
        static var badgeFont : UIFont = .systemFont(ofSize: 12)
        static var badgePadding : Float = 6
    
        static var badgeMinSize : Float = 20
        static var badgeOriginX : Float = 0
        static var badgeOriginY : Float = -4
    
        static var shouldHideBadgeAtZero : Bool = true
        static var shouldAnimateBadge : Bool = true
    }

    public var badge: UILabel {
        get {
            var lbl = objc_getAssociatedObject(self, &AssociatedKey.badge) as? UILabel
            if lbl == nil {
                lbl = UILabel(frame: CGRect(x: CGFloat(self.badgeOriginX), y: CGFloat(self.badgeOriginY), width: 20.0, height: 20.0))
                self.badge = lbl!
                self.customView?.addSubview(lbl ?? UILabel())
                lbl?.textAlignment = .center
                
            }
            return lbl!
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.badge, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var badgeValue: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.badgeValue) as! String
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.badgeValue, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            badgeInit()
            updateBadgeValueAnimated(animated: true)
            refreshBadge()
        }
    }
    
    public var badgeBGColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.badgeBGColor) as? UIColor ?? .red
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.badgeBGColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            refreshBadge()
        }
    }

    public var badgeTextColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.badgeTextColor) as? UIColor ?? .white
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.badgeTextColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            refreshBadge()
        }
    }
    
    public var badgeFont: UIFont {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.badgeFont) as? UIFont ?? .systemFont(ofSize: 12)
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.badgeFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            refreshBadge()
        }
    }

    public var badgePadding: Float {
        get {
            let number = objc_getAssociatedObject(self, &AssociatedKey.badgePadding) as? NSNumber
            return  number?.floatValue ?? 6
        }
        
        set {
            let number = NSNumber(value:newValue)
            objc_setAssociatedObject(self, &AssociatedKey.badgePadding, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBadgeFrame()
        }
    }
    
    public var badgeMinSize: Float {
       get {
           let number = objc_getAssociatedObject(self, &AssociatedKey.badgeMinSize) as? NSNumber
           return  number?.floatValue ?? 20
       }
       
       set {
           let number = NSNumber(value:newValue)
           objc_setAssociatedObject(self, &AssociatedKey.badgeMinSize, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBadgeFrame()
       }
    }
    
    public var badgeOriginX: Float {
       get {
           let number = objc_getAssociatedObject(self, &AssociatedKey.badgeOriginX) as? NSNumber
            return  number?.floatValue ?? 0
       }
       
       set {
           let number = NSNumber(value:newValue)
           objc_setAssociatedObject(self, &AssociatedKey.badgeOriginX, number, .OBJC_ASSOCIATION_ASSIGN)
            updateBadgeFrame()
       }
    }
    
    public var badgeOriginY: Float {
       get {
           let number = objc_getAssociatedObject(self, &AssociatedKey.badgeOriginY) as? NSNumber
           return  number?.floatValue ?? -4
       }
       
       set {
           let number = NSNumber(value:newValue)
           objc_setAssociatedObject(self, &AssociatedKey.badgeOriginY, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBadgeFrame()
       }
    }

    public var shouldHideBadgeAtZero: Bool {
       get {
           let number = objc_getAssociatedObject(self, &AssociatedKey.shouldHideBadgeAtZero) as! NSNumber
           return  number.boolValue
       }
       
       set {
           let number = NSNumber(booleanLiteral: newValue)
           objc_setAssociatedObject(self, &AssociatedKey.shouldHideBadgeAtZero, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            refreshBadge()
       }
    }

    public var shouldAnimateBadge: Bool {
       get {
           let number = objc_getAssociatedObject(self, &AssociatedKey.shouldAnimateBadge) as? NSNumber
        return  number?.boolValue ?? true
       }
       
       set {
           let number = NSNumber(booleanLiteral: newValue)
           objc_setAssociatedObject(self, &AssociatedKey.shouldAnimateBadge, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            refreshBadge()
       }
    }
    

    
    func badgeInit() {
        var superview : UIView!
        var defaultOriginX:Float = 0
        if self.customView != nil {
            superview = self.customView

            defaultOriginX = Float(superview.frame.width) - Float(self.badgeMinSize/2);
            superview?.clipsToBounds = false
        }else {
            let view = self.value(forKey: "_view")
            superview = view as? UIView
            defaultOriginX = Float(superview.frame.width) - Float(self.badgeMinSize);

        }
        superview?.addSubview(badge)
        
        self.badgeBGColor   = .red
        self.badgeTextColor = .white
        self.badgeFont      = .systemFont(ofSize: 12)
        self.badgePadding   = 6
        self.badgeMinSize   = 8
        self.badgeOriginX   = defaultOriginX
        self.badgeOriginY   = -4
        self.shouldHideBadgeAtZero = true
        self.shouldAnimateBadge = true
    }

    func refreshBadge() {
        self.badge.textColor        = self.badgeTextColor
        self.badge.backgroundColor  = self.badgeBGColor
        self.badge.font             = self.badgeFont
        if self.badgeValue == "" || (
            self.badgeValue == "0" && self.shouldHideBadgeAtZero) {
            self.badge.isHidden = true
        }else {
            self.badge.isHidden = false
            updateBadgeValueAnimated(animated: true)
        }
    }
   
    func badgeExpectedSize() -> CGSize {
        let frameLabel = duplicateLabel(labelToCopy: self.badge)
        frameLabel.sizeToFit()
        let expectedLabelSize = frameLabel.frame.size
        return expectedLabelSize;
    }

    func updateBadgeFrame() {
        let expectedLabelSize = badgeExpectedSize()
        var minHeight = Float(expectedLabelSize.height)
        minHeight = (minHeight < self.badgeMinSize) ? self.badgeMinSize : Float(expectedLabelSize.height)
        var minWidth = Float(expectedLabelSize.width)
        let padding = self.badgePadding

        minWidth = (minWidth < minHeight) ? minHeight : Float(expectedLabelSize.width)
        self.badge.layer.masksToBounds = true
        self.badge.frame = CGRect(x: CGFloat(self.badgeOriginX), y: CGFloat(self.badgeOriginY), width: CGFloat(minWidth + padding), height: CGFloat(minHeight + padding))
        self.badge.layer.cornerRadius = CGFloat((minHeight + padding) / 2)
        
    }

    func updateBadgeValueAnimated(animated:Bool) {
        if animated && self.shouldAnimateBadge && badge.text != self.badgeValue{
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 4, 1.3, 1, 1)
            self.badge.layer.add(animation, forKey: "bounceAnimation")
        }
        var badgeV = self.badgeValue
        if (Int(self.badgeValue) ?? 0) > 99 {
            badgeV = "99+"
        }
        self.badge.text = badgeV
        if animated && self.shouldAnimateBadge {
            UIView.animate(withDuration: 0.2) {
                self.updateBadgeFrame()
            }
        }else {
            self.updateBadgeFrame()
        }
    }
    
    func duplicateLabel(labelToCopy:UILabel) -> UILabel {
        let duplicateLabel = UILabel(frame: labelToCopy.frame)
        duplicateLabel.text = labelToCopy.text
        duplicateLabel.font = labelToCopy.font
        return duplicateLabel
    }

    func removeBadge() {
        UIView.animate(withDuration: 0.2, animations: {
            self.badge.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (finished) in
            self.badge.removeFromSuperview()
        }
    }
}
