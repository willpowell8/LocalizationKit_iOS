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
        if let localizeKey = self.LocalizeKey, !localizeKey.isEmpty{
            if let dateFormatText = self.dateFormat, dateFormatText.characters.count > 0 {
                let languageString = Localization.get(localizeKey, alternate:dateFormatText)
                if languageString.characters.count > 0  && languageString != localizeKey {
                    self.dateFormat = languageString
                }
            }
        }
    }

}
