//
//  DateFormatter+Localization.swift
//  Pods
//
//  Created by Will Powell on 12/06/2017.
//
//

import Foundation
import ObjectiveC

private var localizationKey: UInt8 = 5

extension DateFormatter{
    /// Localization Key used to reference the unique translation and text required.
    @IBInspectable
    public var LocalizeKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &localizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            updateLocalisation();
        }
    }
    
    public func updateLocalisation() {
        if ((self.LocalizeKey?.isEmpty) != nil){
            let dateFormatText = self.dateFormat;
            if dateFormatText != nil && (dateFormatText?.characters.count)! > 0 {
                let normalKey = "\(self.LocalizeKey!)";
                let languageString = Localization.get(normalKey, alternate:dateFormatText!)
                if languageString.characters.count > 0  && languageString != normalKey {
                    self.dateFormat = languageString
                }
            }
        }
    }

}
