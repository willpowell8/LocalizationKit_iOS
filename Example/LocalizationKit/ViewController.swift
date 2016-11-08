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
    
    @IBAction func changeLanguageFrench(_ sender:AnyObject){
        Localization.setLanguage("fr")
    }
    
    @IBAction func changeLanguageEnglish(_ sender:AnyObject){
        Localization.setLanguage("en")
    }

}

