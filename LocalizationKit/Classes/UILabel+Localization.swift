//
//  UILabel+Localization.swift
//  Pods
//
//  Created by Will Powell on 13/11/2016.
//
//

import Foundation
import ObjectiveC

private var localizationKey: UInt8 = 0

extension UILabel{
    /// Localization Key used to reference the unique translation and text required.
    @IBInspectable
    public var LocalizeKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationKey) as? String
        }
        set(newValue) {
            self.localizationClear()
            objc_setAssociatedObject(self, &localizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            updateLocalisation()
            localizationSetup();
        }
    }
    
    /// clear previous localization listeners
    func localizationClear(){
        NotificationCenter.default.removeObserver(self, name: Localization.ALL_CHANGE, object: nil);
        if LocalizeKey != nil && (LocalizeKey?.characters.count)! > 0 {
            
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: LocalizeKey!), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: LocalizeKey!), object: nil);
        }
    }
    
    /// setup requirements for localization listening
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: LocalizeKey!), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: LocalizeKey!), object: nil)
        
    }
    
    /// update localization from notification on main thread
    @objc private func updateLocalizationFromNotification() {
        //self.morphingEnabled = true
        DispatchQueue.main.async(execute: {
            self.updateLocalisation()
        })
        
    }
    
    /// trigger field highlight
    public func localizationHighlight() {
        DispatchQueue.main.async(execute: {
            let originalCGColor = self.layer.backgroundColor
            UIView.animate(withDuration: 0.4, animations: {
                self.layer.backgroundColor = UIColor.red.cgColor
                }, completion: { (okay) in
                    UIView.animate(withDuration: 0.4, delay: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.layer.backgroundColor = originalCGColor
                        }, completion: { (complete) in
                            
                    })
            })
        })
    }
    
    /// update the localization
    public func updateLocalisation() {
        if ((self.LocalizeKey?.isEmpty) != nil)  {
            if self.text == nil {
                let languageString = Localization.get(self.LocalizeKey!, alternate:self.LocalizeKey!)
                self.text = languageString
            }else{
                let languageString = Localization.get(self.LocalizeKey!, alternate:self.text!)
                self.text = languageString
            }
            
        } else {
            self.text = ""
        }
    }

}
