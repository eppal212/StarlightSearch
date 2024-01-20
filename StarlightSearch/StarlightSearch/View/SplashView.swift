//
//  SplashView.swift
//  StarlightSearch
//
//  Created by CUDO on 27/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class SplashView: UIView {
    
    private let xibName: String = "SplashView"
    private let TYPING_DELAY: TimeInterval = 0.03
    private let WAITING_DELAY: TimeInterval = 0.3
    private var isFinished: Bool = false
    private var step: Int = 0
    
    @IBOutlet weak var introText: UILabel!
    
    var finishHandler: (() -> Void)? // 스플래시 종료 핸들러
    
    
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
        
        self.isHidden = false
        
        startIntroText()
    }
    
    
    // MARK:- 종료관련
    /** 스플래시 종료 */
    @objc func finishSplash() {
        if finishHandler != nil {
            finishHandler!()
        }
    }
    
    
    // MARK:- 인트로 텍스트 애니메이션
    /** 인트로 텍스트 애니메이션 */
    @objc private func startIntroText() {
        switch step {
        case 0:
            introText.text = "_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 1:
            introText.text = " "
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 2:
            introText.text = "ㅅ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 3:
            introText.text = "스_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 4:
            introText.text = "슽_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 5:
            introText.text = "스테_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 6:
            introText.text = "스텔_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 7:
            introText.text = "스텔ㄹ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 8:
            introText.text = "스텔라_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 9:
            introText.text = "스텔라,_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 10:
            introText.text = "스텔라, "
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: WAITING_DELAY)
            break
        case 11:
            introText.text = "스텔라, ㅈ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 12:
            introText.text = "스텔라, 저_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 13:
            introText.text = "스텔라, 전_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 14:
            introText.text = "스텔라, 전ㅈ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 15:
            introText.text = "스텔라, 전저_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 16:
            introText.text = "스텔라, 전적_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 17:
            introText.text = "스텔라, 전적ㄱ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 18:
            introText.text = "스텔라, 전적거_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 19:
            introText.text = "스텔라, 전적검_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 20:
            introText.text = "스텔라, 전적검ㅅ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 21:
            introText.text = "스텔라, 전적검새_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 22:
            introText.text = "스텔라, 전적검색_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 23:
            introText.text = "스텔라, 전적검색ㅇ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 24:
            introText.text = "스텔라, 전적검색으_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 25:
            introText.text = "스텔라, 전적검색을_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 26:
            introText.text = "스텔라, 전적검색을 _"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 27:
            introText.text = "스텔라, 전적검색을 ㅅ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 28:
            introText.text = "스텔라, 전적검색을 시_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 29:
            introText.text = "스텔라, 전적검색을 싲_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 30:
            introText.text = "스텔라, 전적검색을 시자_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 31:
            introText.text = "스텔라, 전적검색을 시작_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 32:
            introText.text = "스텔라, 전적검색을 시작ㅎ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 33:
            introText.text = "스텔라, 전적검색을 시작하_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 34:
            introText.text = "스텔라, 전적검색을 시작한_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 35:
            introText.text = "스텔라, 전적검색을 시작한ㄷ_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 36:
            introText.text = "스텔라, 전적검색을 시작한다_"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 37:
            introText.text = "스텔라, 전적검색을 시작한다._"
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: TYPING_DELAY)
            break
        case 38:
            introText.text = "스텔라, 전적검색을 시작한다. "
            step = step + 1
            self.perform(#selector(startIntroText), with: nil, afterDelay: WAITING_DELAY)
            break
        default:
            self.perform(#selector(finishSplash), with: nil, afterDelay: 0)
        }
    }
}
