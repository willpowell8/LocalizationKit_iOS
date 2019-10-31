//
//  UIBarButtonItem+Localization.swift
//  Pods
//
//  Created by Will Powell on 02/01/2017.
//
//

import UIKit

private var localizationKey: UInt8 = 2

extension UIBarItem {
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
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: localizeKey), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: localizeKey), object: nil);
        }
    }
    
    /// setup requirements for localization listening
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: localizeKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: localizeKey), object: nil)
        }
    }
    
    /// update localization from notification on main thread
    @objc private func updateLocalizationFromNotification() {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.updateLocalisation()
        })
    }
    
    /// trigger field highlight
    @objc public func localizationHighlight() {
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
    @objc public func updateLocalisation() {
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            if title == nil {
                let languageString = Localization.get(localizeKey, alternate:self.LocalizeKey!)
                title = languageString
            }else{
                let languageString = Localization.get(localizeKey, alternate:self.title!)
                title = languageString
            }
        } else {
            title = ""
        }
    }
}
