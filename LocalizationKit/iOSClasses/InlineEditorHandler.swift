//
//  InlineEditorHandler.swift
//  Pods
//
//  Created by Will Powell on 29/07/2017.
//
//

import Foundation

class InlineEditorHandler:NSObject,UIPopoverPresentationControllerDelegate {
    
    func showAlert(view:UIView, localizationKey:String){
        let podBundle =  Bundle.init(for: Localization.self)
        let bundleURL = podBundle.url(forResource: "LocalizationKit" , withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let popController = ManualLocalizeViewController(nibName: "ManualLocalizeViewController", bundle: bundle)
        popController.localizationKey = localizationKey//self.LocalizeKey
        popController.preferredContentSize = CGSize(width: 296, height: 111)
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = [.up,.down]
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = view
        popController.popoverPresentationController?.sourceRect = view.bounds
        popController.popoverPresentationController?.backgroundColor = UIColor.white
        
        // present the popover
        if let vc = getParent(view) {
            vc.present(popController, animated: true, completion: nil)
        }
    }
    
    func getParent(_ view:UIView) -> UIViewController?{
        var parentResponder: UIResponder? = view
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
