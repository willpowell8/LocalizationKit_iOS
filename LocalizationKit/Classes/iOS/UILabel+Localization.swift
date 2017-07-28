//
//  UILabel+Localization.swift
//  Pods
//
//  Created by Will Powell on 13/11/2016.
//
//

#if os(iOS)
    import Foundation
    import ObjectiveC

    private var localizationKey: UInt8 = 0

    extension UILabel: UIPopoverPresentationControllerDelegate{
        
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
            NotificationCenter.default.removeObserver(self, name: Localization.INLINE_EDIT_CHANGED, object: nil);
            if let recognizers = self.gestureRecognizers {
                for recognizer in recognizers {
                    if recognizer.accessibilityLabel == "LONG_LOCALIZATION" {
                        self.removeGestureRecognizer(recognizer)
                    }
                }
            }
            if LocalizeKey != nil && (LocalizeKey?.characters.count)! > 0 {
                
                NotificationCenter.default.removeObserver(self, name: Localization.highlightEvent(localizationKey: LocalizeKey!), object: nil);
                NotificationCenter.default.removeObserver(self, name: Localization.localizationEvent(localizationKey: LocalizeKey!), object: nil);
            }
        }
        
        func addInlineEditListener(){
            if Localization.allowInlineEdit {
                self.isUserInteractionEnabled = true
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
                longPressRecognizer.accessibilityLabel = "LONG_LOCALIZATION"
                self.addGestureRecognizer(longPressRecognizer)
            }
        }
        
        /// setup requirements for localization listening
        func localizationSetup(){
            addInlineEditListener()
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.ALL_CHANGE, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateInlineEditState), name: Localization.INLINE_EDIT_CHANGED, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: LocalizeKey!), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizationFromNotification), name: Localization.localizationEvent(localizationKey: LocalizeKey!), object: nil)
            
        }
        
        func updateInlineEditState(){
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
                    addInlineEditListener()
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
        
        func longPressed(_ sender: UILongPressGestureRecognizer)
        {
            if sender.state == .recognized {
                let podBundle =  Bundle.init(for: Localization.self)
                let bundleURL = podBundle.url(forResource: "LocalizationKit" , withExtension: "bundle")
                let bundle = Bundle(url: bundleURL!)!
                let popController = ManualLocalizeViewController(nibName: "ManualLocalizeViewController", bundle: bundle)
                popController.localizationKey = self.LocalizeKey
                popController.preferredContentSize = CGSize(width: 296, height: 111)
                // set the presentation style
                popController.modalPresentationStyle = UIModalPresentationStyle.popover
                
                // set up the popover presentation controller
                popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                popController.popoverPresentationController?.delegate = self
                popController.popoverPresentationController?.sourceView = self
                popController.popoverPresentationController?.sourceRect = self.bounds
                
                // present the popover
                if let vc = getParent() {
                    vc.present(popController, animated: true, completion: nil)
                }
            }
        }
        
        func getParent() -> UIViewController?{
            var parentResponder: UIResponder? = self
            while parentResponder != nil {
                parentResponder = parentResponder!.next
                if let viewController = parentResponder as? UIViewController {
                    return viewController
                }
            }
            return nil
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

        public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return UIModalPresentationStyle.none
        }
    }
#endif
