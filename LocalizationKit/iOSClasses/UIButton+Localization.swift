//
//  UIButton+Localization.swift
//  Pods
//
//  Created by Will Powell on 02/01/2017.
//
//

import Foundation

private var localizationKey: UInt8 = 4

extension UIButton {
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
        inlineEditClear()
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            let normalKey = "\(localizeKey).Normal";
            NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: normalKey), object: nil);
            NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: normalKey), object: nil);
        }
    }
    
    /// setup requirements for localization listening
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
        if let localizeKey = self.LocalizeKey {
            let normalKey = "\(localizeKey).Normal";
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: normalKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: normalKey), object: nil)
        }
        
        inlineEditAddGestureRecognizer()
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
    
    /**
        update the localization
    */
    public func updateLocalisation() {
        if let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            if let normalText = self.title(for: .normal), normalText.characters.count > 0 {
                let normalKey = "\(localizeKey).Normal"
                let languageString = Localization.get(normalKey, alternate:normalText)
                if self.title(for: .normal) != languageString {
                    self.setTitle(languageString, for: .normal);
                }
            }
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
    
    /// Inline Editor - gesture recognize Long Press
    func inlineEditorGestureLongPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began, let localizeKey = LocalizeKey, !localizeKey.isEmpty {
            let normalKey = "\(localizeKey).Normal";
            let inline = InlineEditorHandler()
            inline.showAlert(view: self, localizationKey: normalKey)
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
    
    
    
    //
    //  END INLINE EDIT
    //
}
