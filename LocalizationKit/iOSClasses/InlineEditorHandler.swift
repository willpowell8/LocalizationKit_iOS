//
//  InlineEditorHandler.swift
//  Pods
//
//  Created by Will Powell on 29/07/2017.
//
//

import Foundation

class InlineEditorHandler:NSObject,UIPopoverPresentationControllerDelegate {
    
    func showAlert(view:UIView, localizationKey:String, forceMultiLine:Bool = false){
        let podBundle =  Bundle.init(for: Localization.self)
        let bundleURL = podBundle.url(forResource: "LocalizationKit" , withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let localizationText = Localization.get(localizationKey, alternate: "")
        if forceMultiLine || localizationText.contains("\n") {
            let p = ManualLocalizeTextViewController(nibName: "ManualLocalizeTextViewController", bundle: bundle)
            p.localizationKey = localizationKey
            p.localizeView = view
            presentAlert(view, UINavigationController(rootViewController: p), showAsModal:false)
        }else{
            let p = ManualLocalizeViewController(nibName: "ManualLocalizeViewController", bundle: bundle)
            p.localizationKey = localizationKey
            p.localizeView = view
            presentAlert(view, p)
        }
    }
    
    func presentAlert(_ view:UIView,_ popController:UIViewController, showAsModal:Bool = true){
        if showAsModal {
            let height =  Localization.socket?.status == .connected ? CGFloat(111) : CGFloat(141)
            popController.preferredContentSize = CGSize(width: 296, height: height)
            // set the presentation style
            popController.modalPresentationStyle = UIModalPresentationStyle.popover
            
            // set up the popover presentation controller
            popController.popoverPresentationController?.permittedArrowDirections = [.up,.down]
            popController.popoverPresentationController?.delegate = self
            popController.popoverPresentationController?.sourceView = view
            popController.popoverPresentationController?.sourceRect = view.bounds
            popController.popoverPresentationController?.backgroundColor = UIColor.white
        }
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
