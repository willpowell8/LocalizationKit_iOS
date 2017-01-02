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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeLanguage(_ sender:AnyObject){
        
        
        let localizedString = "Select Language".localize
        print("\(localizedString!)");
        
        let alertController = UIAlertController(title: localizedString!, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let englishAction = UIAlertAction(title: "English", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("en")
        })
        
        let frenchAction = UIAlertAction(title: "French", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("fr")
        })
        
        let germanAction = UIAlertAction(title: "German", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("de")
        })
        
        let spanishAction = UIAlertAction(title: "Spanish", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("es")
        })
        
        let italianAction = UIAlertAction(title: "Italian", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("it")
        })
        
        let chineseAction = UIAlertAction(title: "Chinese", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("cn")
        })
        
        let koreanAction = UIAlertAction(title: "Korean", style: .default, handler: {(alert: UIAlertAction!) in Localization.setLanguage("de")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        alertController.addAction(englishAction)
        alertController.addAction(frenchAction)
        alertController.addAction(germanAction)
        alertController.addAction(spanishAction)
        alertController.addAction(italianAction)
        alertController.addAction(chineseAction)
        alertController.addAction(koreanAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:{})
    }

}

