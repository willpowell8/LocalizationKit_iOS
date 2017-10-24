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
        inlineEditClear()
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: localizeKey), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: localizeKey), object: nil);
        }
    }
    
    
    
    /// setup requirements for localization listening
    func localizationSetup(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        if let localizeKey = LocalizeKey {
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: localizeKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: localizeKey), object: nil)
        }
        
        // Add Inline Editor Gesture
        inlineEditAddGestureRecognizer()

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
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            if let str = self.text {
                let languageString = Localization.get(localizeKey, alternate:str)
                self.text = languageString
            }else{
                let languageString = Localization.get(localizeKey, alternate:localizeKey)
                self.text = languageString
            }
            
        } else {
            self.text = ""
        }
    }

    //
    //  START INLINE EDIT
    //
    
    /// Inline Edit Gesture Recognizer Add
    func inlineEditAddGestureRecognizer(){
        if Localization.allowInlineEdit {
            self.isUserInteractionEnabled = true
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(inlineEditorGestureLongPress(_:)))
            longPressRecognizer.accessibilityLabel = "LONG_LOCALIZATION"
            self.addGestureRecognizer(longPressRecognizer)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(inlineEditStateUpdate), name: Localization.INLINE_EDIT_CHANGED, object: nil)
    }
    
    /// Inline Editor - gesture recognize Long Press
    func inlineEditorGestureLongPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began, let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            let inline = InlineEditorHandler()
            inline.showAlert(view: self, localizationKey: localizeKey)
        }
    }
    
    /// Inline Edit State Update
    func inlineEditStateUpdate(){
        if Localization.allowInlineEdit {
            var hasListener = false
            if let recognizers = self.gestureRecognizers {
                for recognizer in recognizers {
                    if recognizer.accessibilityLabel == "LONG_LOCALIZATION" {
                        hasListener = true
                    }
                }
            }
            if hasListener == false {
                inlineEditAddGestureRecognizer()
            }
        }else{
            if let recognizers = self.gestureRecognizers {
                for recognizer in recognizers {
                    if recognizer.accessibilityLabel == "LONG_LOCALIZATION" {
                        self.removeGestureRecognizer(recognizer)
                    }
                }
            }
        }
    }
    
    func inlineEditClear(){
        NotificationCenter.default.removeObserver(self, name: Localization.INLINE_EDIT_CHANGED, object: nil);
        if let recognizers = self.gestureRecognizers {
            for recognizer in recognizers {
                if recognizer.accessibilityLabel == "LONG_LOCALIZATION" {
                    self.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    //
    //  END INLINE EDIT
    //
}
