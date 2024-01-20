//
//  PopupUtils.swift
//  StarlightSearch
//
//  Created by CUDO on 01/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class PopupUtils: NSObject {
    static let USE_ALERTCONTROLLER = false
    
    static func showPopup(vc:UIViewController, title: String, msg: String, buttons: [String], isBackgoundTapEnable: Bool = false, buttonSelected:((String) -> Swift.Void)? = nil) {
        
        if(USE_ALERTCONTROLLER) {
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            buttons.forEach { (btnName) in
                let action = UIAlertAction(title: btnName, style: .default) { (action:UIAlertAction) in
                    if let buttonSelected = buttonSelected {
                        buttonSelected(btnName)
                    }
                }
                alertController.addAction(action)
            }
            
            vc.present(alertController, animated: false, completion: nil)
        } else {
            
            let popup = SSPopup(title: title, message: msg) { (popupSelf, buttonName) in
                
                if let buttonSelected = buttonSelected {
                    buttonSelected(buttonName)
                }
            }
            popup.isBackgoundTapEnable = isBackgoundTapEnable
            popup.addButtons(buttons: buttons)
            popup.modalPresentationStyle = .overFullScreen
            
            vc.present(popup, animated: false, completion: nil)
        }
        
    }
    
    static func showItemPopup(vc:UIViewController, name: String, rarity: String, info: String) {
        
        if(USE_ALERTCONTROLLER) {
            let alertController = UIAlertController(title: name, message: info, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "확인", style: .default) { (action:UIAlertAction) in
                // 처리 동작
            }
            alertController.addAction(action)
            
            vc.present(alertController, animated: false, completion: nil)
        } else {
            
            var titleColor = MAIN_COLOR
            switch rarity {
            case "104":
                titleColor = UNIQUE_COLOR
                break
            case "103":
                titleColor = RARE_COLOR
                break
            case "102":
                titleColor = UNCOMMON_COLOR
                break
            case "101":
                titleColor = BLACK_COLOR
                break
            default: break
            }
            
            let popup = SSPopup(title: name, titleColor: titleColor, message: info, messageColor: BLACK_COLOR) { (popupSelf, buttonName) in
                // 처리 동작
            }
            popup.addButtons(buttons: ["확인"])
            popup.modalPresentationStyle = .overFullScreen
            
            vc.present(popup, animated: false, completion: nil)
        }
        
    }
}
