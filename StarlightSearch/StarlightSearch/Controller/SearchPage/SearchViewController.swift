//
//  ViewController.swift
//  StarlightSearch
//
//  Created by CUDO on 23/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundTouchView: UIView!
    
    @IBOutlet weak var splashView: SplashView!
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewY: NSLayoutConstraint!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var recentNicknameView: UIView!
    
    @IBOutlet weak var bookmarkView: UIView!
    
    var requesSearchtNickname: String = ""
    
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashView.finishHandler = {
            self.splashFinish()
        }
        
        // 인트로
        checkUpdate()
        saveImageUrlMatchFile()
        initSearchPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotification()
        
        updateRecentSearch()
        updateBookmark()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeNotification()
    }
    
    
    // MARK:- Override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callRecord", let destination = segue.destination as? RecordViewController {
            destination.requestNickname = requesSearchtNickname
        }
    }

    
    // MARK:- 스플래시
    /** 스플래시 종료 부분 */
    func splashFinish() {
        SSLog("[스플래시] 종료 호출")
        if splashView != nil {
            SSLog("[스플래시] 종료")
            splashView.removeFromSuperview()
            splashView = nil
        }
    }
    
    /** 업데이트 확인 */
    func checkUpdate() {
        requestDropBoxTextFile(type: .NOTI) { (text) in
            let notiArray = text.components(separatedBy: "|")
            if notiArray.count > 2{
                if needkUpdate(newVersion: notiArray[0]) {
                    PopupUtils.showPopup(vc: self, title: "업데이트", msg: "새로운 버전이 출시되었습니다.\n앱스토어로 이동하시겠습니까?", buttons: ["취소", "확인"]) { (title) in
                        switch title {
                        case "취소":
                            break
                        case "확인":
                            if let url = URL(string: AppStoreUrl) {
                                UIApplication.shared.openURL(url)
                            }
                            break
                        default: break
                        }
                        self.showNoti(notiVersion: Int(notiArray[1]) ?? 0, msg: notiArray[2])
                    }
                }
                else {
                    self.showNoti(notiVersion: Int(notiArray[1]) ?? 0, msg: notiArray[2])
                }
            }
        }
    }
    
    /** 공지사항 노출 */
    func showNoti(notiVersion: Int, msg: String) {
        if notiVersion > getIntData(key: PREF_KEY.READED_NOTI_VER.rawValue) { // 새 공지가 나왔으면
            PopupUtils.showPopup(vc: self, title: "공지사항", msg: msg, buttons: ["다시보지 않기", "확인"]) { (title) in
                switch title {
                case "다시보지 않기":
                    setIntData(val: notiVersion, key: PREF_KEY.READED_NOTI_VER.rawValue)
                    break
                case "확인":
                    break
                default: break
                }
            }
        }
    }
    
    /** 이미지Url매치 파일 저장 */
    func saveImageUrlMatchFile() {
        requestDropBoxTextFile(type: .IMAGE_URL) { (text) in
            let items = text.components(separatedBy: "\n")
            for item in items {
                let data = item.components(separatedBy: "|")
                if data.count > 1 {
                    UserInformation.shared.imageUrlDict[data[0]] = data[1]
                }
            }
        }
    }
    
    
    // MARK:- 검색
    /** 초기화 */
    func initSearchPage() {
        searchField.delegate = self
        
        let backgroundtapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        backgroundTouchView.addGestureRecognizer(backgroundtapGesture)
    }
    
    /** 검색 시작 */
    func searchNickname(nickname: String) {
        hideKeyboard()
        
        if nickname == "" {
            SSToast.show(msg: "검색 실패.\n닉네임을 입력해주세요.")
            return
        }
        else if nickname == "-" {
            PopupUtils.showPopup(vc: self, title: "검색 오류", msg: "닉네임을 확인해 주세요.", buttons: ["확인"])
            return
        }
        
        requesSearchtNickname = nickname
        performSegue(withIdentifier: "callRecord", sender: self)
        searchField.text = ""
        addRecentSearchData(nickname: nickname)
    }
    
    /** 키보드 숨기기 */
    @objc func hideKeyboard() {
        searchField.resignFirstResponder()
    }
    
    
    // MARK:- 최근검색, 즐겨찾기
    /** 최근검색 닉네임 업데이트 */
    func updateRecentSearch() {
        for view in recentNicknameView.subviews {
            view.isHidden = true
        }
        
        if getBoolData(key: PREF_KEY.USE_RECENT_SEARCH.rawValue) ?? true {
            if let nicknamesString = getStringData(key: PREF_KEY.RECENT_SEARCH.rawValue){
                if nicknamesString != "" {
                    var stringArray = nicknamesString.components(separatedBy: "|")
                    if stringArray.contains("") {
                        stringArray.remove(at: stringArray.firstIndex(of: "")!)
                    }
                    
                    for i in 0 ..< stringArray.count {
                        for view in recentNicknameView.subviews {
                            if view.tag == i {
                                view.isHidden = false
                                if let name = view as? UIButton {
                                    if (name.titleLabel?.text ?? "") != "" {
                                        name.setTitle(stringArray[i], for: .normal)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /** 즐겨찾기 닉네임 업데이트 */
    func updateBookmark() {
        let views = bookmarkView.subviews
        for view in views {
            view.isHidden = true
        }
        
        let bookmark = getBookmark()
        for i in 0 ..< bookmark.count {
            for view in views {
                if view.tag == i {
                    view.isHidden = false
                    if let name = view as? UIButton {
                        if (name.titleLabel?.text ?? "") != "" {
                            //name.titleLabel?.text = bookmark[i][0]
                            name.setTitle(bookmark[i][0], for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK:- Notification
    func addNotification() {
        removeNotification()
        
        // Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAnimate(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAnimate(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAnimate(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /** 키보드가 나타나고 사라질때 */
    @objc func keyboardWillAnimate(notification: Notification) {
        if let userInfo = notification.userInfo
        {
            switch notification.name
            {
            case UIResponder.keyboardWillShowNotification:
                if let keyboardSize: CGSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size {
                    self.view.layoutIfNeeded()
                    UIView.animate(withDuration: 2.5, animations: {
                        let keyboardHeight = keyboardSize.height
                        let contentViewBottom = UIScreen.main.bounds.height - (self.contentView.frame.height + self.contentView.frame.origin.y)
                        let value = keyboardHeight - contentViewBottom
                        if value > 0 {
                            self.contentViewY.constant = self.contentViewY.constant - value
                        }
                        self.view.layoutIfNeeded()
                    })
                }
                break
            case UIResponder.keyboardDidShowNotification:
                break
            case UIResponder.keyboardWillHideNotification:
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 2.5, animations: {
                    self.contentViewY.constant = -65
                    self.view.layoutIfNeeded()
                })
                break
            case UIResponder.keyboardDidHideNotification:
                break
            default: break
            }
        }
    }
    
    
    // MARK:- 네오플 API
    /** 플레이어 정보 API */
    private func requestPlayerInfo(playerId: String, handler: @escaping (String, Int) -> Void) {
        NeopleApiManager.shared.requestPlayerInfo(playerId: playerId, responseCompletion: { (data: PlayerInfoData) in
            SSLog("[API] 플레이어 정보 API 성공 : \(data.nickname ?? "NULL")")
            handler(data.nickname ?? "-", data.grade ?? 0)
        }) { (err) in
            SSLog("[API] 플레이어 정보 API 실패 : \(String(describing: err.localizedDescription))")
            handler("-", 0)
        }
    }
    
    
    // MARK:- TextField Delegate
    /** 입력을 시작할 때 */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    /** 검색버튼 감지 */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            searchNickname(nickname: searchField.text ?? "")
            return false
        }
        return true
    }
    
    
    // MARK:- 클릭 이벤트
    /** 설정버튼 클릭 이벤트 */
    @IBAction func onClickSettingButton(_ sender: Any) {
        performSegue(withIdentifier: "callSetting", sender: self)
        hideKeyboard()
    }
    
    /** 검색버튼 클릭 이벤트 */
    @IBAction func onClickSearchButton(_ sender: Any) {
        searchNickname(nickname: searchField.text ?? "")
    }
    
    /** 최근 검색 ID 클릭 이벤트 */
    @IBAction func onClickRecentSearchNickname(_ sender: Any) {
        let button = sender as! UIButton
        searchNickname(nickname: button.titleLabel?.text ?? "")
    }
    
    /** 즐겨찾기 해제버튼 */
    @IBAction func onClickBookmarkDelete(_ sender: Any) {
        hideKeyboard()
        
        let button = sender as! UIButton
        let tag = button.tag
        var name = ""
        
        for view in bookmarkView.subviews {
            if let bookmarkName = view as? UIButton {
                if bookmarkName.tag == tag && bookmarkName != button {
                    name = bookmarkName.titleLabel?.text ?? ""
                }
            }
        }
        
        if name != "" {
            PopupUtils.showPopup(vc: self, title: "즐겨찾기 해제", msg: "정말 '\(name)'님을\n즐겨찾기에서 해제하시겠습니까?", buttons: ["취소","해제"]) { [weak self] (title) in
                switch title {
                case "취소":
                    break
                case "해제":
                    removeBookmark(playerNickname: name)
                    self?.updateBookmark()
                    break
                default: break
                }
            }
        }
    }
    
    /** 즐겨찾기 클릭 이벤트 */
    @IBAction func onClickBookmark(_ sender: Any) {
        let button = sender as! UIButton
        searchNickname(nickname: button.titleLabel?.text ?? "")
    }
}
