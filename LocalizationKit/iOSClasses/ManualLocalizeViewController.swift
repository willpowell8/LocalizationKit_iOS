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
    @IBOutlet weak var errorMessage:UILabel!
    
    var localizeView:UIView?
    
    public var localizationKey:String? {
        didSet{
            DispatchQueue.main.async {
                self.keyLabel.text = self.localizationKey
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.text = Localization.socket?.status == .connected ? "" : "Error: Not connected"
        languageLabel.text = Localization.languageCode
        if let localizationKeyStr = self.localizationKey {
            let localizationString = Localization.get(localizationKeyStr, alternate: "")
            textField.text = localizationString
            if Localization.socket?.status != .connected {
                textField.isEnabled = false
            }
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let localizationKeyStr = self.localizationKey, let newString = textField.text else {
            return
        }
        Localization.set(localizationKeyStr, value: newString)
    }
    
    @IBAction func changeToMultiLine(){
        guard let v = localizeView, let localizeKey = localizationKey else{
            return
        }
        self.dismiss(animated: true, completion: {
            let inline = InlineEditorHandler()
            inline.showAlert(view: v, localizationKey: localizeKey, forceMultiLine:true)
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

}
#endif
