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
    @IBInspectable
    public var LocalizeKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &localizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            updateLocalisation()
            localizationSetup();
        }
    }
    
    func localizationClear(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func localizationSetup(){
        self.localizationClear()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        let eventHighlight = "LOC_HIGHLIGHT_\(LocalizeKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
        let eventText = "LOC_TEXT_\(LocalizeKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
        
    }
    
    @objc private func updateLocalizationFromNotification() {
        //self.morphingEnabled = true
        DispatchQueue.main.async(execute: {
            self.updateLocalisation()
        })
        
    }
    
    
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
