//
//  LoadingView.swift
//  StarlightSearch
//
//  Created by CUDO on 20/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    private let xibName: String = "LoadingView"
    private let TYPING_DELAY: TimeInterval = 0.03
    private let WAITING_DELAY: TimeInterval = 0.5
    private var step: Int = 0
    
    @IBOutlet weak var loadingText: UILabel!
    
    
    // MARK:- 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    /** 초기화 */
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    
    // MARK:- 시작/종료 관련
    /** 로딩 시작 */
    func startLoading(vc: UIViewController) {
        self.frame = vc.view.frame
        vc.view.addSubview(self)
        loadingText.text = ""
        startLoadingText()
    }
    
    /** 로딩 종료 */
    func stopLoading() {
        self.perform(#selector(exitLoading), with: nil, afterDelay: 1.5)
    }
    @objc private func exitLoading() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startLoadingText), object: nil)
        self.removeFromSuperview()
    }
    
    
    // MARK:- 로딩 텍스트 애니메이션
    /** 로딩 텍스트 애니메이션 */
    @objc private func startLoadingText() {
        switch step {
        case 0:
            loadingText.text = "_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 1:
            loadingText.text = "ㄹ_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 2:
            loadingText.text = "로_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 3:
            loadingText.text = "롣_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 4:
            loadingText.text = "로디_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 5:
            loadingText.text = "로딩_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 6:
            loadingText.text = "로딩ㅈ_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 7:
            loadingText.text = "로딩주_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 8:
            loadingText.text = "로딩중_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 9:
            loadingText.text = "로딩중._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 10:
            loadingText.text = "로딩중.._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 11:
            loadingText.text = "로딩중..._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 12:
            let attributedString = NSMutableAttributedString(string: "로딩중..._")
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: getColor(hexRGB: WHITE_COLOR)!, range: ("로딩중..._" as NSString).range(of: "로딩중..._"))
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: getColor(hexRGB: MAIN_COLOR)!, range: ("로딩중..._" as NSString).range(of: "_"))
            loadingText.attributedText = attributedString
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 13:
            loadingText.text = "로딩중..._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 14:
            loadingText.text = "로딩중.._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 15:
            loadingText.text = "로딩중._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 16:
            loadingText.text = "로딩중.._"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 17:
            loadingText.text = "로딩_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 18:
            loadingText.text = "로_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 19:
            loadingText.text = "_"
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 20:
            loadingText.text = " "
            step = step + 1
            self.perform(#selector(startLoadingText), with: nil, afterDelay: WAITING_DELAY)
            break
        default:
            step = 0
            self.perform(#selector(startLoadingText), with: nil, afterDelay: 0)
            break
        }
    }
}
