//
//  String+Localization.swift
//  Pods
//
//  Created by Will Powell on 02/01/2017.
//
//

import Foundation


extension String {
    /**
        returns the localized text
    */
    public var localize: String? {
        get {
            guard let localizationKey = self.stringLocalizationKey() else{
                print("You cannot localize a zero length string");
                return self;
            }
            return Localization.get(localizationKey, alternate: self);
        }
        set(newValue) {
            
        }
    }
    
    /**
        gets identifier string from string text. Built of form String.*Your String*
    */
    private func stringLocalizationKey() -> String? {
        if(self.characters.count > 0){
            var newString = "String.\(self)"
            newString = newString.replacingOccurrences(of: " ", with: ".", options: .literal, range: nil)
            let character = CharacterSet(charactersIn:"0123456789.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
            return newString.trimmingCharacters(in: character);
        }else{
            return nil;
        }
    }
}
