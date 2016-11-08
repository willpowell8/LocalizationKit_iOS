//
//  LangUILabel.swift
//  Pods
//
//  Created by Will Powell on 03/11/2016.
//
//

import UIKit

class LangUILabel: UILabel {
    
    private var _locLabel:String?
    
    @IBInspectable public var locLabel:String? {
        get {
            return _locLabel
        }
        set {
            _locLabel = newValue;
            updateLocalisation()
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.morphingEnabled = false
        if (self.text != nil){
            self.locLabel = self.text
        }
        
        setup()
    }
    
    func setup(){
        NotificationCenter.default.addObserver(self, selector: #selector(LangUILabel.updateFromNotification), name: Language.ALL_CHANGE, object: nil)
        let eventHighlight = "LOC_HIGHLIGHT_\(_locLabel!)"
        NotificationCenter.default.addObserver(self, selector: #selector(LangUILabel.highlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
        let eventText = "LOC_TEXT_\(_locLabel!)"
        NotificationCenter.default.addObserver(self, selector: #selector(LangUILabel.updateFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    public func updateFromNotification() {
        //self.morphingEnabled = true
        DispatchQueue.main.async(execute: {
            self.updateLocalisation()
        })
        
    }
    
    
    func highlightClose() {
        self.backgroundColor = UIColor.clear
        // Something after a delay
    }
    
    public func highlight() {
        //self.morphingEnabled = true
        DispatchQueue.main.async(execute: {
            let originalCGColor = self.layer.backgroundColor
            UIView.animate(withDuration: 0.4, animations: { 
                 self.layer.backgroundColor = UIColor.red.cgColor
            }, completion: { (okay) in
                UIView.animate(withDuration: 0.4, delay: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.layer.backgroundColor = originalCGColor
                    }, completion: { (complete) in
                        
                })
            })
            //self.backgroundColor = UIColor.red
        })
        //var timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(LangUILabel.highlightClose), userInfo: nil, repeats: false)
    }
    
    override public init(frame:CGRect) {
        super.init(frame: frame)
        //self.morphingEnabled = false
        if (self.text != nil){
            self.locLabel = self.text
        }
        NotificationCenter.default.addObserver(self, selector: #selector(LangUILabel.updateFromNotification), name: NSNotification.Name(rawValue:"LOCALIZATION_CHANGED"), object: nil)
        setup()
        
    }
    
    func updateLocalisation() {
        if ((self._locLabel?.isEmpty) != nil)  {
            var languageString = LocalizationKit.get(self._locLabel!, alternate:self._locLabel!)
            /*if self.uppercased == true {
                languageString = languageString.uppercased()
            }*/
            self.text = languageString
        } else {
            self.text = ""
        }
    }

}
