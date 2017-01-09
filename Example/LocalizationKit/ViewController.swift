//
//  ViewController.swift
//  LocalizationKit
//
//  Created by Will Powell on 11/08/2016.
//  Copyright (c) 2016 Will Powell. All rights reserved.
//

import UIKit
import LocalizationKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeLanguage(_ sender:AnyObject){
        let localizedString = "Select Language".localize
        print("\(localizedString!)");
        
        let alertController = UIAlertController(title: localizedString!, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        Localization.availableLanguages { (languages) in
            for language in languages {
                let action = UIAlertAction(title: language.localizedName, style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage(language.key)
                })
                alertController.addAction(action)
            }
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion:{})
            });
        }
    }

}

