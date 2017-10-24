//
//  UITextField+Localization.swift
//  Pods
//
//  Created by Will Powell on 02/01/2017.
//
//

import Foundation

private var localizationKey: UInt8 = 3

extension UITextField {
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
            let placeHolderKey = "\(localizeKey).Placeholder";
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: placeHolderKey), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: placeHolderKey), object: nil);
        }
    }
    
    /// setup requirements for localization listening
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        if let localizeKey = self.LocalizeKey {
            let placeHolderKey = "\(localizeKey).Placeholder";
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: placeHolderKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: placeHolderKey), object: nil)
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
            let placeHolderKey = "\(localizeKey).Placeholder";
            if var placeholder = self.placeholder {
                let languageString = Localization.get(placeHolderKey, alternate:placeholder)
                placeholder = languageString
            }else{
                let languageString = Localization.get(placeHolderKey, alternate:placeHolderKey)
                self.placeholder = languageString
            }
        }
    }
}
