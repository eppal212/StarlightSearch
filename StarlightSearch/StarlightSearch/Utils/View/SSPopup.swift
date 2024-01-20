//
//  CDPopup.swift
//  CudoUtils
//
//  Created by KimSeongIn on 10/09/2018.
//  Copyright © 2018 ChanKi Park. All rights reserved.
//

import Foundation
import UIKit

public class SSPopup: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var buttonsLayout: UIView!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var textFieldContainerHeightConstraint: NSLayoutConstraint!
    private var titleStr: String?
    private var titleColor: String?
    private var msgStr: String?
    private var msgColor: String?
    private var buttons: [String]?
    private var useTextField: Bool = false
    private var placeholderText: String?
    private var autoDismissAfterAction: Bool = true
    private var inputMaxLength: Int = -1
    private var textFieldKeyboardType: UIKeyboardType?
    @IBOutlet weak var popupContainerBottomConstraint: NSLayoutConstraint!
    
    private var completionHandler: ((SSPopup, String)->Void)?
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var isBackgoundTapEnable : Bool = false
    
    public init(title: String?, message: String?, buttonSelected:((SSPopup, String) -> Swift.Void)? = nil) {
        super.init(nibName: "SSPopup", bundle: Bundle(identifier: AppBundleID))
        
        titleStr = title
        msgStr = message
        placeholderText = ""
        
        completionHandler = buttonSelected
    }
    
    public init(title: String?, titleColor: String?, message: String?, messageColor: String?, buttonSelected:((SSPopup, String) -> Swift.Void)? = nil) {
        super.init(nibName: "SSPopup", bundle: Bundle(identifier: AppBundleID))
        
        titleStr = title
        self.titleColor = titleColor
        msgStr = message
        msgColor = messageColor
        placeholderText = ""
        
        completionHandler = buttonSelected
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        titleLabel.text = titleStr
        msgLabel.text = msgStr
        if titleColor != nil {
            titleLabel.textColor = getColor(hexRGB: titleColor)
        }
        if msgColor != nil {
            msgLabel.textColor = getColor(hexRGB: msgColor)
        }
        
        if useTextField {
            textField.delegate = self
            if let ph = placeholderText {
                textField.attributedPlaceholder = NSAttributedString(string: ph, attributes:[NSAttributedString.Key.foregroundColor : getColor(hexRGB: BLACK_COLOR, alpha: 0.5) ?? "#000000"])
            }
            if let type = textFieldKeyboardType {
                textField.keyboardType = type
            }
            textFieldContainer.isHidden = false
            textFieldContainerHeightConstraint.constant = 45
        } else {
            textFieldContainer.isHidden = true
            textFieldContainerHeightConstraint.constant = 0
        }
        
        var rightButton:UIButton? = nil
        if let buttons = self.buttons?.reversed() {
            buttons.forEach { (buttonName) in
                let button = UIButton(type: .custom)
                button.isUserInteractionEnabled = true
                button.backgroundColor = UIColor.clear
                button.setTitleColor(getColor(hexRGB: "#15A695"), for: .normal)
                button.setTitleColor(getColor(hexRGB: "#0b584f"), for: .highlighted)
                button.setTitleColor(getColor(hexRGB: "#0b584f"), for: .focused)
                button.setTitleColor(getColor(hexRGB: "#15A695", alpha: 0.3), for: .disabled)
                button.setTitle(buttonName, for: .normal)
                button.titleLabel?.font =  UIFont(name: "HelveticaNeue-Regular", size: 16)
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.textAlignment = .center
                
                buttonsLayout.addSubview(button)
                
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalTo: buttonsLayout.heightAnchor, constant:0).isActive = true
                button.centerYAnchor.constraint(equalTo: buttonsLayout.centerYAnchor).isActive = true
                
                if(rightButton != nil) {
                    button.trailingAnchor.constraint(equalTo: rightButton!.leadingAnchor, constant:-37).isActive = true
                } else {
                    button.trailingAnchor.constraint(equalTo: buttonsLayout.trailingAnchor, constant:0).isActive = true
                }
                
                button.addTarget(self, action: #selector(btnPressed(sender:)), for: .touchUpInside)
                
                rightButton = button
            }
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.popupContainerBottomConstraint.constant -= keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.popupContainerBottomConstraint.constant = 0
    }
    
    // MARK:- Function
    
    public func addButtons(buttons: [String]) {
        self.buttons = buttons
    }
    
    public func getTextFieldText() -> String {
        return textField.text ?? ""
    }
    
    public func setTextFieldEnable(use: Bool, placeholder: String) {
        useTextField = use
        placeholderText = placeholder
    }
    
    public func setTextFieldInputMaxLegnth(max: Int) {
        inputMaxLength = max
    }
    
    public func setAutoDismissAfterAction(use: Bool) {
        autoDismissAfterAction = use
    }
    
    public func setTextFieldKeyboardType(type: UIKeyboardType) {
        textFieldKeyboardType = type
    }
    
    public func setMsgLabelText(text: String, color: UIColor) {
        msgLabel.text = text
        msgLabel.textColor = color
    }
    
    // MARK:- Event
    
    @IBAction func backgroundClick(_ sender: Any) {
        if isBackgoundTapEnable == true {
            dismiss(animated: false, completion: nil)
        }
    }
    @objc func btnPressed(sender: UIButton!) {
        if autoDismissAfterAction {
            dismiss(animated: false, completion: nil)
        }

        if let completionHandler = completionHandler {
            let btnName = sender.titleLabel?.text
            completionHandler(self, btnName!)
        }
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK:- TextField Delegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if inputMaxLength == -1 { return true }
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= inputMaxLength
    }
}
