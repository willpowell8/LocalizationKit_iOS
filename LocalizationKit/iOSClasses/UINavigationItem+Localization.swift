//
//  NavigationItem+Localization.swift
//  Pods
//
//  Created by Will Powell on 13/11/2016.
//
//

import Foundation
import ObjectiveC
import UIKit

private var localizationKey: UInt8 = 1

extension UINavigationItem {
    
    /// Localization Key used to reference the unique translation and text required.
    @IBInspectable
    public var LocalizeKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationKey) as? String
        }
        set(newValue) {
            self.localizaionClear()
            objc_setAssociatedObject(self, &localizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            updateLocalisation()
            localizationSetup();
        }
    }
    
    /// clear previous localization listeners
    func localizaionClear(){
        NotificationCenter.default.removeObserver(self, name: Localization.ALL_CHANGE, object: nil);
        if LocalizeKey != nil && (LocalizeKey?.characters.count)! > 0 {
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: LocalizeKey!), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: LocalizeKey!), object: nil);
        }
    }
    
    /// setup requirements for localization listening
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        if let localize = LocalizeKey {
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: localize), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: localize), object: nil)
        }
    }
    
    /// update localization from notification on main thread
    @objc private func updateLocalizationFromNotification() {
        DispatchQueue.main.async(execute: {
            self.updateLocalisation()
        })
        
    }
    
    /// trigger field highlight
    public func localizationHighlight() {
        /*DispatchQueue.main.async(execute: {
            let originalCGColor = self.layer.backgroundColor
            UIView.animate(withDuration: 0.4, animations: {
                self.layer.backgroundColor = UIColor.red.cgColor
            }, completion: { (okay) in
                UIView.animate(withDuration: 0.4, delay: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.layer.backgroundColor = originalCGColor
                }, completion: { (complete) in
                    
                })
            })
        })*/
    }
    
    /// update the localization
    public func updateLocalisation() {
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            if let title = self.title {
                let languageString = Localization.get(localizeKey, alternate:title)
                self.title = languageString
            }else{
                let languageString = Localization.get(localizeKey, alternate:"")
                self.title = languageString
            }
        } else {
            self.title = ""
        }
    }
}
