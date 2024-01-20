//
//  CDToast.swift
//  CudoUtils
//
//  Created by KimSeongIn on 14/09/2018.
//  Copyright © 2018 ChanKi Park. All rights reserved.
//

import Foundation
import UIKit

public class SSToast:UIView {
    private static let xibName = "SSToast"
    
    @IBOutlet weak var msgLabel: UILabel!
    
    private static let TOAST_BOX_PADDING_VERTICAL = 14.0 as CGFloat
    private static let TOAST_BOX_PADDING_HORIZONTAL = 42.0 as CGFloat
    private static let TOAST_BOX_MARGIN_HORIZONTAL = 14.0 as CGFloat
    private static let TOAST_BOX_MARGIN_BOTTOM = 70.0 as CGFloat
    private static let TOAST_ANIMATION_DURATION = 0.25 as TimeInterval
    private static let TOAST_LENGTH = 2.0 as TimeInterval
    
    public init(frame: CGRect, msg: String) {
        super.init(frame: frame)
        customInit(msg: msg)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit(msg: String) {
        let bundle = Bundle(identifier: AppBundleID)!
        let view = bundle.loadNibNamed(SSToast.xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        msgLabel.text = msg
    }
    
    public static func show(msg: String) {
        let toastView = SSToast(frame: CGRect.zero, msg: msg)
        toastView.alpha = 0.0
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(toastView)
            
            toastView.msgLabel.translatesAutoresizingMaskIntoConstraints = false
            toastView.translatesAutoresizingMaskIntoConstraints = false
            
            let labelLeadingConstraint = NSLayoutConstraint(item: toastView.msgLabel, attribute: .leading, relatedBy: .equal, toItem: toastView, attribute: .leading, multiplier: 1, constant: TOAST_BOX_PADDING_HORIZONTAL)
            let labelTrailingConstraint = NSLayoutConstraint(item: toastView.msgLabel, attribute: .trailing, relatedBy: .equal, toItem: toastView, attribute: .trailing, multiplier: 1, constant: TOAST_BOX_PADDING_HORIZONTAL * -1)
            let labelTopConstraint = NSLayoutConstraint(item: toastView.msgLabel, attribute: .top, relatedBy: .equal, toItem: toastView, attribute: .top, multiplier: 1, constant: TOAST_BOX_PADDING_VERTICAL)
            let labelBottomConstraint = NSLayoutConstraint(item: toastView.msgLabel, attribute: .bottom, relatedBy: .equal, toItem: toastView, attribute: .bottom, multiplier: 1, constant: TOAST_BOX_PADDING_VERTICAL * -1)
            toastView.addConstraints([labelLeadingConstraint, labelTrailingConstraint, labelTopConstraint, labelBottomConstraint])
            
            let toastViewLeadingConstraint = NSLayoutConstraint(item: toastView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: window, attribute: .leading, multiplier: 1, constant: TOAST_BOX_PADDING_HORIZONTAL)
            let toastViewTrailingConstraint = NSLayoutConstraint(item: toastView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: window, attribute: .trailing, multiplier: 1, constant: TOAST_BOX_PADDING_HORIZONTAL * -1)
            
            let bottomConstraint = NSLayoutConstraint(item: toastView, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1, constant: TOAST_BOX_MARGIN_BOTTOM * -1)
            let centerHorizontalConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant:0)
            window.addConstraints([toastViewLeadingConstraint, toastViewTrailingConstraint, bottomConstraint, centerHorizontalConstraint])
            
            UIView.animate(withDuration: TOAST_ANIMATION_DURATION, delay: 0.0, options: .curveEaseIn, animations: {
                toastView.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: TOAST_ANIMATION_DURATION, delay: TOAST_LENGTH, options: .curveEaseOut, animations: {
                    toastView.alpha = 0.0
                }, completion: {_ in
                    toastView.removeFromSuperview()
                })
            })
        }
        
    }
    
}
