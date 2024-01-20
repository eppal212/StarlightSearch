//
//  SettingViewController.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, CellToSettingViewDelegate {
    
    enum TapType: String {
        case LIKE         = "LIKE"
        case HATE         = "HATE"
        case USER_COMMENT = "USER_COMMENT"
    }
    
    @IBOutlet weak var backgroundTouchView: UIView!
    
    @IBOutlet weak var recentSearchNicknameEnableLabel: UILabel!
    
    @IBOutlet weak var likePlayerLabel: UILabel!
    @IBOutlet weak var likePlayerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var likePlayerTableView: UITableView!
    
    @IBOutlet weak var hatePlayerLabel: UILabel!
    @IBOutlet weak var hatePlayerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hatePlayerTableView: UITableView!
    
    @IBOutlet weak var userCommentLabel: UILabel!
    @IBOutlet weak var userCommentCooltimeLabel: UILabel!
    @IBOutlet weak var userCommentSendButton: UIButton!
    @IBOutlet weak var userCommentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userCommentTextView: UITextView!
    
    let licenseView = LicenseView()
    let devCommentView = CommonPageView()
    
    var nowEditingType: PLAYER_TYPE = .LIKE
    var nowEditingNickname: String = "-"
    
    var BOLD_FONT: UIFont? = nil
    var REGULAR_FONT: UIFont? = nil
    
    
    // MARK:- View
    override func viewDidLoad() {
        super.viewDidLoad()

        // 폰트 저장
        BOLD_FONT = likePlayerLabel.font
        REGULAR_FONT = hatePlayerLabel.font
        likePlayerLabel.font =  REGULAR_FONT
        
        checkUseRecentSearchNickname()
        likePlayerViewHeight.constant = 0
        hatePlayerViewHeight.constant = 0
        userCommentViewHeight.constant = 0
        if checkUserCommentEnable() {
            userCommentCooltimeLabel.isHidden = true
        }
        userCommentTextView.delegate = self
        
        let backgroundtapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        backgroundTouchView.addGestureRecognizer(backgroundtapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        licenseView.setScrollStartPoint()
        devCommentView.setScrollStartPoint()
    }
    
    /** 최근 검색 닉네임 사용 여부 */
    func checkUseRecentSearchNickname() {
        let isSkip = getBoolData(key: PREF_KEY.USE_RECENT_SEARCH.rawValue)!
        if isSkip {
            recentSearchNicknameEnableLabel.text = "사용"
        }
        else {
            recentSearchNicknameEnableLabel.text = "사용 안 함"
        }
    }
    
    /** 유저 한 마디 활성화 여부 */
    func checkUserCommentEnable() -> Bool{
        userCommentCooltimeLabel.isHidden = false
        resizeTap(type: .USER_COMMENT, isOpen: false)
        hideKeyboard()
        
        let sendedTime = getStringData(key: PREF_KEY.USER_COMMENT_TIME.rawValue)
        if sendedTime != nil && sendedTime != ""{
            // 시간 비교해서 쿨타임이 아니면 보여줌
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            
            let sendedDate = dateFormatter.date(from: sendedTime!)
            let nowDate = dateFormatter.date(from: getTodayDate(dateFormat: "yyyyMMddHHmmss"))
            
            if sendedDate != nil && nowDate != nil {
                let afterDate = Date(timeInterval: IS_DEBUG ? 1 : 600, since: sendedDate!)
                if afterDate < nowDate! {
                    return true
                }
            }
        }
        else {
            return true
        }
        
        return false
    }
    
    /** 탭 눌렀을때 크기 조절 */
    func resizeTap(type: TapType, isOpen: Bool) {
        if nowEditingNickname != "-" { // 코멘트 편집중이면 탭 변경 없음
            return
        }
        
        switch type {
        case .LIKE:
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if isOpen {
                    self.likePlayerLabel.font =  self.BOLD_FONT
                    self.likePlayerViewHeight.constant = 150
                }
                else {
                    self.likePlayerLabel.font =  self.REGULAR_FONT
                    self.likePlayerViewHeight.constant = 0
                }
                self.view.layoutIfNeeded()
            })
            break
        case .HATE:
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if isOpen {
                    self.hatePlayerLabel.font =  self.BOLD_FONT
                    self.hatePlayerViewHeight.constant = 150
                }
                else {
                    self.hatePlayerLabel.font =  self.REGULAR_FONT
                    self.hatePlayerViewHeight.constant = 0
                }
                self.view.layoutIfNeeded()
            })
            break
        case .USER_COMMENT:
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if isOpen {
                    self.userCommentLabel.font =  self.BOLD_FONT
                    self.userCommentViewHeight.constant = 123
                    self.userCommentSendButton.isHidden = false
                }
                else {
                    self.userCommentLabel.font =  self.REGULAR_FONT
                    self.userCommentViewHeight.constant = 0
                    self.userCommentSendButton.isHidden = true
                }
                self.view.layoutIfNeeded()
            })
            break
        }
    }
    
    /** 키보드 숨기기 */
    @objc func hideKeyboard() {
        userCommentTextView.resignFirstResponder()
    }
    
    
    // MARK:- TableView Delegate, Datasource
    /** 아이템 반환 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlayerTypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTypeTableViewCell", for: indexPath) as! PlayerTypeTableViewCell
        cell.delegate = self as CellToSettingViewDelegate
        
        if tableView == likePlayerTableView {
            cell.setData(data: getPlayerType(type: .LIKE)[indexPath.row], type: .LIKE)
        }
        else if tableView == hatePlayerTableView {
            cell.setData(data: getPlayerType(type: .HATE)[indexPath.row], type: .HATE)
        }
        cell.setCondition(nowEditingType: nowEditingType, nowEditingNickname: nowEditingNickname)
        
        return cell
    }
    
    /** 아이템 갯수 반환 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == likePlayerTableView {
            count = getPlayerType(type: .LIKE).count
        }
        else if tableView == hatePlayerTableView {
            count = getPlayerType(type: .HATE).count
        }
        
        return count
    }
    
    /** 아이템 클릭 이벤트 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var cell: PlayerTypeTableViewCell
//        if tableView == likePlayerTableView {
//            cell = likePlayerTableView.cellForRow(at: indexPath) as! PlayerTypeTableViewCell
//        }
//        else if tableView == hatePlayerTableView {
//            cell = hatePlayerTableView.cellForRow(at: indexPath) as! PlayerTypeTableViewCell
//        }
    }
    
    
    // MARK:- TextViewDelegate
    /** 유저 한 마디 입력하려고 할 때 다른 탭 닫음 */
    func textViewDidBeginEditing(_ textView: UITextView) {
        resizeTap(type: .LIKE, isOpen: false)
        resizeTap(type: .HATE, isOpen: false)
    }
    
    /** 글자수 제한 */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1500
    }
    
    
    // MARK:- CellToSettingViewDelegate
    /** 셀 입력 시작할때 다른 탭 닫음 */
    func closeOtherTap(nowType: PLAYER_TYPE) {
        switch nowType {
        case .LIKE:
            resizeTap(type: .HATE, isOpen: false)
            resizeTap(type: .USER_COMMENT, isOpen: false)
            break
        case .HATE:
            resizeTap(type: .LIKE, isOpen: false)
            resizeTap(type: .USER_COMMENT, isOpen: false)
            break
        }
    }
    
    /** 선호/블랙 플레이어 탭 스크롤 불가로 설정 */
    func setScrollEnable(isEnable: Bool, nowType: PLAYER_TYPE) {
        switch nowType {
        case .LIKE:
            likePlayerTableView.isScrollEnabled = isEnable
            break
        case .HATE:
            hatePlayerTableView.isScrollEnabled = isEnable
            break
        }
    }
    
    /** 선호/블랙 플레이어 테이블 갱신 */
    func reloadTableView(nowType: PLAYER_TYPE) {
        switch nowType {
        case .LIKE:
            self.likePlayerTableView.reloadData()
            break
        case .HATE:
            self.hatePlayerTableView.reloadData()
            break
        }
    }
    
    /** 선호/블랙 플레이어 코멘트 수정 */
    func didEdit(isStart: Bool, nowType: PLAYER_TYPE, nickname: String) {
        if isStart {
            nowEditingType = nowType
            nowEditingNickname = nickname
        }
        else {
            nowEditingNickname = "-"
        }
        reloadTableView(nowType: nowType)
    }
    
    /** 선호/블랙 플레이어 삭제 */
    func deletePlayerType(type: PLAYER_TYPE, nickname: String) {
        switch type {
        case .LIKE:
            PopupUtils.showPopup(vc: self, title: "선호플레이어 삭제", msg: "정말 '\(nickname)'님을\n선호 플레이어 목록에서 삭제하시겠습니까?", buttons: ["취소", "확인"]) { (text) in
                removePlayerType(type: type, playerNickname: nickname)
                self.reloadTableView(nowType: type)
            }
            break
        case .HATE:
            PopupUtils.showPopup(vc: self, title: "블랙리스트 삭제", msg: "정말 '\(nickname)'님을\n선호 블랙리스트 목록에서 삭제하시겠습니까?", buttons: ["취소", "확인"]) { (text) in
                removePlayerType(type: type, playerNickname: nickname)
                self.reloadTableView(nowType: type)
            }
            break
        }
    }
    
    
    // MARK:- 클릭 이벤트
    /** 이전 버튼 클릭 이벤트 */
    @IBAction func onClickBackButton(_ sender: Any) {
        hideKeyboard()
        didEdit(isStart: false, nowType: .LIKE, nickname: "-")
        self.navigationController?.popViewController(animated: true)
    }
    
    /** 최근 사용 닉네임 탭 클릭 이벤트 */
    @IBAction func onClickUseRecentSearchNicknameTap(_ sender: Any) {
        
        hideKeyboard()
        
        var isSkip = getBoolData(key: PREF_KEY.USE_RECENT_SEARCH.rawValue)!
        isSkip = !isSkip
        
        if isSkip {
            recentSearchNicknameEnableLabel.text = "사용"
        }
        else {
            recentSearchNicknameEnableLabel.text = "사용 안 함"
        }
        setBoolData(val: isSkip, key: PREF_KEY.USE_RECENT_SEARCH.rawValue)
    }
    
    /** 선호 플레이어 관리 탭 클릭 이벤트 */
    @IBAction func onClickLikePlayerTap(_ sender: Any) {
        
        hideKeyboard()
        
        if likePlayerViewHeight.constant == 0 {
            resizeTap(type: .LIKE, isOpen: true)
        }
        else {
            resizeTap(type: .LIKE, isOpen: false)
        }
    }
    
    /** 블랙리스트 관리 탭 클릭 이벤트 */
    @IBAction func onClickHatePlayerTap(_ sender: Any) {
        
        hideKeyboard()
        
        if hatePlayerViewHeight.constant == 0 {
            resizeTap(type: .HATE, isOpen: true)
        }
        else {
            resizeTap(type: .HATE, isOpen: false)
        }
    }
    
    /** 개발자 한 마디 탭 클릭 이벤트 */
    @IBAction func onClickShowDevCommentTap(_ sender: Any) {
        
        hideKeyboard()
        
        if nowEditingNickname != "-" { // 코멘트 편집중이면 탭 변경 없음
            return
        }
        
        self.view.addSubview(devCommentView)
        devCommentView.frame = self.view.bounds
        devCommentView.setData(title: "개발자 코멘트", text: "")
        requestDropBoxTextFile(type: .DEV_COMMENT) { (text) in
            self.devCommentView.setData(title: "개발자 코멘트", text: text)
        }
    }
    
    /** 사용자 한 마디 탭 클릭 이벤트 */
    @IBAction func onClickShowUserCommentTap(_ sender: Any) {
        
        hideKeyboard()
        
        if userCommentViewHeight.constant == 0 {
            if checkUserCommentEnable() {
                userCommentCooltimeLabel.isHidden = true
                userCommentTextView.text = ""
                resizeTap(type: .USER_COMMENT, isOpen: true)
            }
        }
        else {
            resizeTap(type: .USER_COMMENT, isOpen: false)
        }
    }
    
    /** 사용자 한 마디 전송 버튼 클릭 이벤트 */
    @IBAction func onClickSendUserComentButton(_ sender: Any) {
        if userCommentTextView.text == "" {
            return
        }
        
        sendAnalytics(type: .USER_COMMENT, event: ANALYTICS_TYPE.USER_COMMENT.rawValue, value: userCommentTextView.text)
        userCommentTextView.text = ""
        setStringData(val: getTodayDate(dateFormat: "yyyyMMddHHmmss"), key: PREF_KEY.USER_COMMENT_TIME.rawValue)
        SSToast.show(msg: "소중한 의견 감사합니다.")
        if checkUserCommentEnable() {
            userCommentCooltimeLabel.isHidden = true
        }
    }
    
    /** 오픈소스 라이센스 버튼 클릭 이벤트 */
    @IBAction func onClickOpenLicenseButton(_ sender: Any) {
        
        hideKeyboard()
        
        if nowEditingNickname != "-" { // 코멘트 편집중이면 탭 변경 없음
            return
        }
        
        self.view.addSubview(licenseView)
        licenseView.frame = self.view.frame
    }
}
