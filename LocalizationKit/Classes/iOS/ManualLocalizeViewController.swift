//
//  ManualLocalizeViewController.swift
//  Pods
//
//  Created by Will Powell on 28/07/2017.
//
//
#if os(iOS)
import UIKit

class ManualLocalizeViewController: UIViewController {
    
    @IBOutlet weak var keyLabel:UILabel!
    @IBOutlet weak var languageLabel:UILabel!
    @IBOutlet weak var textField:UITextField!
    
    public var localizationKey:String? {
        didSet{
            DispatchQueue.main.async {
                self.keyLabel.text = self.localizationKey
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.languageLabel.text = Localization.languageCode
        if let localizationKeyStr = self.localizationKey {
            let localizationString = Localization.get(localizationKeyStr, alternate: "")
            self.textField.text = localizationString
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if let localizationKeyStr = self.localizationKey {
            Localization.set(localizationKeyStr, value: textField.text!)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
#endif
