//
//  ViewController.swift
//  LocalizationKit
//
//  Created by Will Powell on 11/08/2016.
//  Copyright (c) 2016 Will Powell. All rights reserved.
//

import UIKit
import LocalizationKit
import MBProgressHUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeLanguage(_ sender:AnyObject){
        let localizedString = "Select Language".localize
        let alertController = UIAlertController(title: localizedString!, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.presentationController
        print("\(localizedString!)");
        Localization.availableLanguages { (languages) in
            for language in languages {
                let action = UIAlertAction(title: language.localizedName, style: .default, handler: {(alert: UIAlertAction!) in
                    DispatchQueue.main.async(execute: {
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.label.text = "Loading ..."
                        hud.mode = .indeterminate
                        Localization.setLanguage(language.key, {
                            print("Language loaded");
                            DispatchQueue.main.async(execute: {
                                hud.hide(animated: true);
                            });
                        })
                    })
                })
                alertController.addAction(action)
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                    let btn = sender as! UIBarButtonItem
                    currentPopoverpresentioncontroller.barButtonItem = btn
                    currentPopoverpresentioncontroller.permittedArrowDirections = .up;
                }
            }
            DispatchQueue.main.async(execute: {
                
                self.present(alertController, animated: true, completion:{})
            });
        }
    }

}

