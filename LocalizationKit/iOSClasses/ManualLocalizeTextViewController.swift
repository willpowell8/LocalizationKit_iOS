//
//  ManualLocalizeTextViewController.swift
//  LocalizationKit
//
//  Created by Will Powell on 19/12/2017.
//

import UIKit

class ManualLocalizeTextViewController: UIViewController {
    
    @IBOutlet weak var textView:UITextView!
    var localizeView:UIView?
    
    public var localizationKey:String? {
        didSet{
            DispatchQueue.main.async {
                self.navigationItem.title = self.localizationKey
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let localizationKeyStr = localizationKey {
            textView.text = Localization.get(localizationKeyStr, alternate: "")
        }
        let backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissNow))
        navigationItem.leftBarButtonItem = backButton
        
        let saveButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneNow))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func doneNow(){
        guard let localizationKeyStr = self.localizationKey, let newString = textView.text else {
            return
        }
        Localization.set(localizationKeyStr, value: newString)
        dismissNow()
    }
    
    @objc func dismissNow(){
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
