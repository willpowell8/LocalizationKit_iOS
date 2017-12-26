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
    
    fileprivate var keyboardHeight: CGFloat = 0.0
    
    var localizationKey:String? {
        didSet{
            DispatchQueue.main.async {
                self.navigationItem.title = self.localizationKey
            }
        }
    }
    @IBOutlet fileprivate var footerConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let localizationKeyStr = localizationKey {
            textView.text = Localization.get(localizationKeyStr, alternate: "")
        }
        let backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissNow))
        navigationItem.leftBarButtonItem = backButton
        
        let saveButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneNow))
        navigationItem.rightBarButtonItem = saveButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardEvent(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                footerConstraint.constant = 0.0
            } else {
                footerConstraint.constant = endFrameHeight
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
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
