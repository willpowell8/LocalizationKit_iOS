//
//  UIBarButtonItem+Localization.swift
//  Pods
//
//  Created by Will Powell on 02/01/2017.
//
//

#if os(iOS)
import Foundation

extension UIBarButtonItem {
    override public func updateLocalisation() {
        if( self.title != nil && (self.title?.characters.count)!>0 ){
            super.updateLocalisation();
        }
        
    }
}
#endif
