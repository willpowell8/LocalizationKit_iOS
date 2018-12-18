//
//  UISearchBar+Localization.swift
//  LocalizationKit
//
//  Created by Will Powell on 12/12/2017.
//

import UIKit

private var localizationKey: UInt8 = 5

extension UISearchBar {
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
            let promptKey = "\(localizeKey).Prompt";
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: promptKey), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: promptKey), object: nil);
        }
    }
    
    /// setup requirements for localization listening
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        if let localizeKey = self.LocalizeKey {
            let placeHolderKey = "\(localizeKey).Placeholder";
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: placeHolderKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: placeHolderKey), object: nil)
            let promptKey = "\(localizeKey).Prompt";
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: promptKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: promptKey), object: nil)
        }
    }
    
    /// update localization from notification on main thread
    @objc private func updateLocalizationFromNotification() {
        DispatchQueue.main.async(execute: {
            self.updateLocalisation()
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
    public func updateLocalisation() {
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            let placeHolderKey = "\(localizeKey).Placeholder";
            if let placeholder = self.placeholder {
                let languageString = Localization.get(placeHolderKey, alternate:placeholder)
                self.placeholder = languageString
            }else{
                let languageString = Localization.get(placeHolderKey, alternate:placeHolderKey)
                self.placeholder = languageString
            }
            
            let promptKey = "\(localizeKey).Prompt";
            if let prompt = self.prompt {
                let languageString = Localization.get(promptKey, alternate:prompt)
                if !languageString.isEmpty, languageString != " ", languageString != promptKey {
                    self.prompt = languageString
                }else{
                    self.prompt = nil
                }
            }else{
                let languageString = Localization.get(promptKey, alternate:promptKey)
                if !languageString.isEmpty {
                    self.prompt = languageString
                }else{
                    self.prompt = nil
                }
            }
        }
    }
}
