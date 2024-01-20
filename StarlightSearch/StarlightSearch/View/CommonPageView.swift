//
//  CommonPageView.swift
//  StarlightSearch
//
//  Created by CUDO on 27/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class CommonPageView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    private let xibName: String = "CommonPageView"
    
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
    
    /** 표시할 내용 세팅 */
    func setData(title: String, text: String){
        titleLabel.text = title
        textView.text = text
    }
    
    /** 처음 부분으로 스크롤 */
    func setScrollStartPoint(){
        textView.setContentOffset(.zero, animated: false)
    }
    
    /** 이전 버튼 클릭 이벤트 */
    @IBAction func onClickBackButton(_ sender: Any) {
        self.removeFromSuperview()
        textView.setContentOffset(.zero, animated: false)
    }
}
