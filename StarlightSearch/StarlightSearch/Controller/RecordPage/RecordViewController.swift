//
//  RecordViewController.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import GoogleMobileAds

public enum GameType: String {
    case ALL    = "ALL"
    case RATING = "RATING"
    case NORMAL = "NORMAL"
}

// 모스트픽 구조체
public struct MostCharacterData: Codable {
    var characterId : String?
    var characterName : String?
    var winCount : Int?
    var loseCount : Int?
    var killCount : Int?
    var deathCount : Int?
    var assistCount : Int?
    var attackPoint : Int?
    var damagePoint : Int?
    var playCount : Int?
}

// 전체 경기 구조체
struct AllMatchesData: Codable {
    var date : String?
    var gameTypeId : String?
    var matchId : String?
    var playInfo : MatchesData.playInfo?
}

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum SearchErrorType: String {
        case INVALID_NICKNAME    = "INVALID_NICKNAME" // 올바르지 않은 닉네임
        case FAIL_PLAYER_API     = "FAIL_PLAYER_API" // 플레이어 검색에 실패
        case FAIL_MATCHES_API    = "FAIL_MATCHES_API" // 공성전내역 검색에 실패
        case SERVER_ERROR        = "SERVER_ERROR" // API 서버 점검중
    }
    
    // 탑메뉴
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var hateButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    
    // 개인정보
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var clanLabel: UILabel!
    @IBOutlet weak var tierLabel: UILabel!
    @IBOutlet weak var rpLabel: UILabel!
    
    // 게임 선택 탭
    @IBOutlet weak var allGameButton: UIButton!
    @IBOutlet weak var ratingGameButton: UIButton!
    @IBOutlet weak var normalGameButton: UIButton!
    @IBOutlet weak var gameDataLabel: UILabel!
    
    // 목록 정보
    @IBOutlet weak var matchesInfo: UILabel!
    
    // 모스트
    @IBOutlet weak var mostpicView: UIControl!
    @IBOutlet weak var mostpicViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mostpicViewY: NSLayoutConstraint!
    @IBOutlet weak var mostProfileImage: UIImageView!
    @IBOutlet weak var mostNicknameLabel: UILabel!
    @IBOutlet weak var mostGameDataLabel: UILabel!
    @IBOutlet weak var mostKdaLabel: UILabel!
    @IBOutlet weak var mostDamageLabel: UILabel!
    @IBOutlet weak var noMostpicView: UIView!
    
    // 광고
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var adViewDeviderHeight: NSLayoutConstraint!
    var adBannerView: GADBannerView!
    
    // 전적 목록
    @IBOutlet weak var recordTableView: UITableView!
    @IBOutlet weak var noContentsView: UIView!
    
    // 에러 뷰
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorText: UILabel!
    
    var loadingView: LoadingView = LoadingView()
    
    var requestNickname: String = "" // 검색된 닉네임
    var selectedGameType: GameType = .ALL // 표시할 게임 타입
    var allMatchesData: [AllMatchesData]? // 전체 게임 데이터
    var ratingMatchesData: MatchesData? // 공식전 게임 데이터
    var normalMatchesData: MatchesData? // 일반전 게임 데이터
    var requestRecordDetailMatchId: String = "" // 전적상세로 이동할 매치ID
    var bigSizeTableViewHeight: CGFloat = 0

    // MARK:- Basic
    /** 매칭 상세페이지로 전환하기 전에 호출 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callRecordDetail", let destination = segue.destination as? RecordDetailViewController {
            destination.requestMatchId = requestRecordDetailMatchId
            destination.playerNickname = requestNickname
        }
        else if segue.identifier == "callRecordGraph", let destination = segue.destination as? RecordGraphViewController {
            destination.allMatchesDataSource = allMatchesData
            destination.ratingMatchesDataSource = ratingMatchesData
            destination.normalMatchesDataSource = normalMatchesData
            destination.requestNickname = requestNickname
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true

        requestPlayer() // 검색 시작
        
        initAdBanner() // 광고 뷰 그리기
        
        updateTopMenuButton()
    }
    
    
    // MARK:- API
    /** 플레이어 API */
    private func requestPlayer() {
        startLoading()

        UserInformation.shared.responseDate = nil
        NeopleApiManager.shared.requestPlayer(nickname: requestNickname, responseCompletion: { (data: PlayerData) in
            if data.rows?.count ?? 0 > 0 {
                let playerData: PlayerData.row = (data.rows?[0])!
                SSLog("[API] 플레이어 검색 API 성공 : \(playerData.nickname ?? "NULL"), \(playerData.playerId ?? "NULL")")
                
                if playerData.playerId == nil || playerData.playerId == "" {
                    // 올바르지 않은 닉네임 입니다.
                    self.errorProcess(type: .INVALID_NICKNAME)
                }
                else {
                    self.requestMatches(playerId: playerData.playerId ?? "", gameTypeId: "rating")
                    self.requestMatches(playerId: playerData.playerId ?? "", gameTypeId: "normal")
                    UserInformation.shared.responseDate = nil
                }
            }
            else {
                SSLog("[API] 플레이어 검색 API 실패 : 데이터가 비어있음")
                // 올바르지 않은 닉네임 입니다.
                self.errorProcess(type: .INVALID_NICKNAME)
            }
        }) { (err) in
            SSLog("[API] 플레이어 검색 API 실패 : \(String(describing: err.localizedDescription))")
            if err.statusCode == 503 {
                // 서버 점검중
                self.errorProcess(type: .SERVER_ERROR)
            }
            else {
                // 플레이어 검색에 실패하였습니다.
                self.errorProcess(type: .FAIL_PLAYER_API)
            }
        }
    }
    
    /** 플레이어 매칭기록 조회 API */
    private func requestMatches(playerId: String, gameTypeId: String) {
        NeopleApiManager.shared.requestMatches(playerId: playerId, gameTypeId: gameTypeId, responseCompletion: { (data: MatchesData) in
            SSLog("[API] 플레이어 매칭기록 조회 API 성공 : \(data.nickname ?? "NULL")")
            
            if gameTypeId == "rating" {
                self.ratingMatchesData = data
                self.completeMatchesApi()
            }
            else if gameTypeId == "normal" {
                self.normalMatchesData = data
                self.completeMatchesApi()
            }
        }) { (err) in
            SSLog("[API] 플레이어 매칭기록 조회 API 실패 : \(String(describing: err.localizedDescription))")
            // 공성전 내역을 불러오는데 실패하였습니다.
            self.errorProcess(type: .FAIL_MATCHES_API)
        }
    }
    
    
    // MARK:- 뷰 그리기
    /** 개인정보 그리기 */
    func updateProfileView() {
        if ratingMatchesData == nil {
            return
        }
        
        if let url = URL(string: UserInformation.shared.imageUrlDict[ratingMatchesData?.tierName ?? ""] ?? "") {
            profileImage.kf.setImage(with: url, placeholder: UIImage(named: "rank_unrank"))
        }
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.layer.borderColor = getColor(hexRGB: BLACK_COLOR)?.cgColor
        profileImage.layer.borderWidth = 2
        profileImage.clipsToBounds = true
        
        nicknameLabel.text = ratingMatchesData?.nickname
        gradeLabel.text = "\(String(ratingMatchesData?.grade ?? 0))급"
        clanLabel.text = "클랜   \(ratingMatchesData?.clanName ?? "-")"
        if ratingMatchesData?.tierName != nil && ratingMatchesData?.ratingPoint != nil && ratingMatchesData?.maxRatingPoint != nil {
            tierLabel.text = "티어   \(ratingMatchesData?.tierName ?? "-")"
            rpLabel.text = "RP     \(String(ratingMatchesData?.ratingPoint ?? 0))점 (최대 \(String(ratingMatchesData?.maxRatingPoint ?? 0))점)"
        }
        else {
            tierLabel.text = "티어   -"
            rpLabel.text = "RP   배치고사 미진행"
        }
    }
    
    /** 게임선택 탭 그리기 */
    func updateGameSelectView(type: GameType) {
        if ratingMatchesData == nil || normalMatchesData == nil {
            return
        }
        
        self.selectedGameType = type
        
        switch type {
        case .ALL:
            allGameButton.setTitleColor(getColor(hexRGB: WHITE_COLOR), for: .normal)
            allGameButton.backgroundColor = getColor(hexRGB: MAIN_COLOR)
            allGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 17)
            ratingGameButton.setTitleColor(getColor(hexRGB: RED_COLOR), for: .normal)
            ratingGameButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            ratingGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 17)
            normalGameButton.setTitleColor(getColor(hexRGB: BLUE_COLOR), for: .normal)
            normalGameButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            normalGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 17)
            
            gameDataLabel.text = "정보 조회 실패"
            if ratingMatchesData?.records?.count ?? 0 > 0 {
                var win: Float = 0.0
                var lose: Float = 0.0
                var stop: Float = 0.0
                for i in 0 ..< (ratingMatchesData?.records?.count ?? 1) {
                    if ratingMatchesData?.records?[i].gameTypeId == "rating" {
                        let record = ratingMatchesData?.records?[i]
                        win = win + Float(record?.winCount ?? 0)
                        lose = lose + Float(record?.loseCount ?? 0)
                        stop = stop + Float(record?.stopCount ?? 0)
                    }
                    else if ratingMatchesData?.records?[i].gameTypeId == "normal" {
                        let record = ratingMatchesData?.records?[i]
                        win = win + Float(record?.winCount ?? 0)
                        lose = lose + Float(record?.loseCount ?? 0)
                        stop = stop + Float(record?.stopCount ?? 0)
                    }
                }
                let winAve = (win / (win+lose == 0 ? 1 : win+lose)) * 100
                if getModelName() == "iPhoneSE" {
                    gameDataLabel.text = "총 전적  |  \(Int(win))승 \(Int(lose))패 \(Int(stop))중단"
                }
                else {
                    gameDataLabel.text = "총 전적  |  \(Int(win))승 \(Int(lose))패 \(Int(stop))중단  |  승률 \(String(format: "%.2f", winAve))%"
                }
            }
            
            matchesInfo.text = "현재시즌 최근 90일간 \(String(allMatchesData?.count ?? 0))게임"
            break
        case .RATING:
            allGameButton.setTitleColor(getColor(hexRGB: BLACK_COLOR), for: .normal)
            allGameButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            allGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 17)
            ratingGameButton.setTitleColor(getColor(hexRGB: WHITE_COLOR), for: .normal)
            ratingGameButton.backgroundColor = getColor(hexRGB: MAIN_COLOR)
            ratingGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 17)
            normalGameButton.setTitleColor(getColor(hexRGB: BLUE_COLOR), for: .normal)
            normalGameButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            normalGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 17)
            
            gameDataLabel.text = "정보 조회 실패"
            if ratingMatchesData?.records?.count ?? 0 > 0 {
                for i in 0 ..< (ratingMatchesData?.records?.count ?? 1) {
                    if ratingMatchesData?.records?[i].gameTypeId == "rating" {
                        let record = ratingMatchesData?.records?[i]
                        let sum = Float(record?.loseCount ?? 0) + Float(record?.winCount ?? 0)
                        let winAve = (Float(record?.winCount ?? 0) / (sum == 0 ? 1 : sum)) * 100
                        
                        if getModelName() == "iPhoneSE" {
                            gameDataLabel.text = "총 전적  |  \(record?.winCount ?? 0)승 \(record?.loseCount ?? 0)패 \(record?.stopCount ?? 0)중단"
                        }
                        else {
                            gameDataLabel.text = "총 전적  |  \(record?.winCount ?? 0)승 \(record?.loseCount ?? 0)패 \(record?.stopCount ?? 0)중단  |  승률 \(String(format: "%.2f", winAve))%"
                        }
                    }
                }
            }
            
            matchesInfo.text = "현재시즌 최근 90일간 \(String(ratingMatchesData?.matches?.rows?.count ?? 0))게임"
            break
        case .NORMAL:
            allGameButton.setTitleColor(getColor(hexRGB: BLACK_COLOR), for: .normal)
            allGameButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            allGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 17)
            ratingGameButton.setTitleColor(getColor(hexRGB: RED_COLOR), for: .normal)
            ratingGameButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            ratingGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 17)
            normalGameButton.setTitleColor(getColor(hexRGB: WHITE_COLOR), for: .normal)
            normalGameButton.backgroundColor = getColor(hexRGB: MAIN_COLOR)
            normalGameButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 17)
            
            gameDataLabel.text = "정보 조회 실패"
            if ratingMatchesData?.records?.count ?? 0 > 0 {
                for i in 0 ..< (ratingMatchesData?.records?.count ?? 1) {
                    if ratingMatchesData?.records?[i].gameTypeId == "normal" {
                        let record = ratingMatchesData?.records?[i]
                        let sum = Float(record?.loseCount ?? 0) + Float(record?.winCount ?? 0)
                        let winAve = (Float(record?.winCount ?? 0) / (sum == 0 ? 1 : sum)) * 100
                        
                        if getModelName() == "iPhoneSE" {
                            gameDataLabel.text = "총 전적  |  \(record?.winCount ?? 0)승 \(record?.loseCount ?? 0)패 \(record?.stopCount ?? 0)중단"
                        }
                        else {
                            gameDataLabel.text = "총 전적  |  \(record?.winCount ?? 0)승 \(record?.loseCount ?? 0)패 \(record?.stopCount ?? 0)중단  |  승률 \(String(format: "%.2f", winAve))%"
                        }
                    }
                }
            }
            
            matchesInfo.text = "현재시즌 최근 90일간 \(String(normalMatchesData?.matches?.rows?.count ?? 0))게임"
            break
        }
    
        mostpicViewY.constant = 0
        
        updateMostpicView()
        
        recordTableView.setContentOffset(.zero, animated: false)
        recordTableView.reloadData()
        self.view.layoutIfNeeded()
        recordTableView.setContentOffset(.zero, animated: false)
    }
    
    /** 모스트픽 그리기 */
    func updateMostpicView() {
        noMostpicView.isHidden = true
        var matchesDatas = [MatchesData].init()
        
        switch selectedGameType {
        case .ALL:
            if ratingMatchesData != nil {
                matchesDatas.append(ratingMatchesData!)
            }
            if normalMatchesData != nil {
                matchesDatas.append(normalMatchesData!)
            }
            break
        case .RATING:
            if ratingMatchesData != nil {
                matchesDatas.append(ratingMatchesData!)
            }
            break
        case .NORMAL:
            if normalMatchesData != nil {
                matchesDatas.append(normalMatchesData!)
            }
            break
        }
        
        if let mostpic = getMostCharacter(data: matchesDatas) {
            mostProfileImage.layer.cornerRadius = mostProfileImage.frame.height/2
            mostProfileImage.layer.borderWidth = 2
            mostProfileImage.layer.borderColor = getColor(hexRGB: MAIN_COLOR)?.cgColor
            mostProfileImage.clipsToBounds = true
            if let url = URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + (mostpic.characterId ?? ""))) {
                mostProfileImage.kf.setImage(with: url, placeholder: UIImage(named: "img_random"))
            }
            mostNicknameLabel.text = mostpic.characterName
            var sum: Float = (Float(mostpic.winCount ?? 0) + Float(mostpic.loseCount ?? 0))
            if sum == 0 {
                sum = 1
            }
            let ave = (Float(mostpic.winCount ?? 0) / sum) * 100
            mostGameDataLabel.text = "\(String(Int(sum)))전 \(String(mostpic.winCount ?? 0))승 \(String(mostpic.loseCount ?? 0))패 (\(String(format: "%.2f", ave))%)"
            let kill = round(Float(mostpic.killCount ?? 0) / Float(mostpic.playCount ?? 1))
            let death = round(Float(mostpic.deathCount ?? 0) / Float(mostpic.playCount ?? 1))
            let assist = round(Float(mostpic.assistCount ?? 0) / Float(mostpic.playCount ?? 1))
            var kda: Float = 0
            if death == 0 {
                kda = ((Float(kill) + Float(assist)) / Float(1)) * 1.2
            }
            else {
                kda = (Float(kill) + Float(assist)) / Float(death)
            }
            mostKdaLabel.text = "평균 \(String(Int(kill)))킬 \(String(Int(death)))데스 \(String(Int(assist)))도움   KDA \(String(format: "%.1f", kda))"
            
            if getModelName() == "iPhoneSE" {
                mostDamageLabel.text = "평균 공격량 \(parsePoint(point: (mostpic.attackPoint ?? 0)/(mostpic.playCount ?? 1))) 평균 피해량 \(parsePoint(point: (mostpic.damagePoint ?? 0)/(mostpic.playCount ?? 1)))"
            }
            else {
                mostDamageLabel.text = "평균 공격량 \(parsePoint(point: (mostpic.attackPoint ?? 0)/(mostpic.playCount ?? 1)))   평균 피해량 \(parsePoint(point: (mostpic.damagePoint ?? 0)/(mostpic.playCount ?? 1)))"
            }
        }
        else {
            noMostpicView.isHidden = false
        }
    }
    
    /** 광고 그리기 */
    func initAdBanner() {
        // 뷰 생성
        adBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(adBannerView)
        adView.addConstraints(
            [NSLayoutConstraint(item: adBannerView!,
                                attribute: .centerY,
                                relatedBy: .equal,
                                toItem: adView,
                                attribute: .centerY,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: adBannerView!,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: adView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
        if HIDE_ADVIEW {
            adViewHeight.constant = 0
            adViewDeviderHeight.constant = 0
        }
        
        // 속성 설정
        adBannerView.adUnitID = IS_DEBUG ? AdMobBannerIdTest : AdMobRecordBannerId
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    
    /** 탑메뉴 버튼 그리기 */
    func updateTopMenuButton() {
        if containsPlayerType(type: .LIKE, playerNickname: requestNickname) {
            likeButton.setImage(UIImage(named: "img_heart_sel"), for: .normal)
        }
        else {
            likeButton.setImage(UIImage(named: "img_heart_nor"), for: .normal)
        }
        
        if containsPlayerType(type: .HATE, playerNickname: requestNickname) {
            hateButton.setImage(UIImage(named: "img_broken_heart_sel"), for: .normal)
        }
        else {
            hateButton.setImage(UIImage(named: "img_broken_heart_nor"), for: .normal)
        }
        
        if containsBookmark(playerNickname: requestNickname) {
            bookmarkButton.setImage(UIImage(named: "img_star_sel"), for: .normal)
        }
        else {
            bookmarkButton.setImage(UIImage(named: "img_star_nor"), for: .normal)
        }
    }
    
    
    // MARK:- ETC
    /** api통신이 모두 완료됐으면 정보를 표시함 */
    func completeMatchesApi() {
        if ratingMatchesData != nil && normalMatchesData != nil {
            updateProfileView() // 유저정보 부분 그려줌
            calcAllMatchesData()
            updateGameSelectView(type: self.selectedGameType) // 경기선택탭 그려줌
            recordTableView.reloadData() // 경기정보 부분 그려줌
            
            // 즐겨찾기에 등록돼있으면 급수 업데이트
            if containsBookmark(playerNickname: requestNickname) {
                updateBookmark(playerNickname: requestNickname, grade: gradeLabel.text ?? "-급")
            }
            
            stopLoading()
        }
    }
    
    /** 전체 게임 데이터 계산 */
    func calcAllMatchesData() {
        allMatchesData = [AllMatchesData]()
        
        for i in 0 ... (ratingMatchesData?.matches?.rows?.count ?? 0) {
            for j in 0 ... (normalMatchesData?.matches?.rows?.count ?? 0) {
                var newData: AllMatchesData? = nil
                
                if i == ratingMatchesData?.matches?.rows?.count {
                    // ratingMatchesData 사이클을 다 돌았을 경우 남은 normalMatchesData 데이터 채워줌
                    if j < (normalMatchesData?.matches?.rows?.count ?? 0) {
                        let normalData = normalMatchesData?.matches?.rows?[j]
                        newData = AllMatchesData.init(date: normalData?.date, gameTypeId: "normal", matchId: normalData?.matchId, playInfo: normalData?.playInfo)
                    }
                }
                else if j == normalMatchesData?.matches?.rows?.count {
                    if i < (ratingMatchesData?.matches?.rows?.count ?? 0) {
                        // normalMatchesData 사이클을 다 돌았을 경우 남은 ratingMatchesData 데이터 채워줌
                        let ratingData = ratingMatchesData?.matches?.rows?[i]
                        newData = AllMatchesData.init(date: ratingData?.date, gameTypeId: "rating", matchId: ratingData?.matchId, playInfo: ratingData?.playInfo)
                    }
                }
                else {
                    // 일반적인 경우
                    let ratingData = ratingMatchesData?.matches?.rows?[i]
                    let normalData = normalMatchesData?.matches?.rows?[j]
                    
                    if ratingData!.date!.compare(normalData!.date!).rawValue == 1 {
                        newData = AllMatchesData.init(date: ratingData?.date, gameTypeId: "rating", matchId: ratingData?.matchId, playInfo: ratingData?.playInfo)
                    }
                    else {
                        newData = AllMatchesData.init(date: normalData?.date, gameTypeId: "normal", matchId: normalData?.matchId, playInfo: normalData?.playInfo)
                    }
                }
                
                // allMatchesData에 item 추가
                if newData != nil {
                    let isContains = allMatchesData?.contains(where: { (containsData) -> Bool in
                        if containsData.matchId == newData!.matchId {
                            return true
                        }
                        else {
                            return false
                        }
                    })
                    if isContains == false {
                        allMatchesData?.append(newData!)
                    }
                }
            }
        }
    }
    
    /** 로딩 시작 */
    func startLoading() {
        loadingView.startLoading(vc: self)
    }
    
    /** 로딩 종료 */
    func stopLoading() {
        loadingView.stopLoading()
    }
    
    /** 검색시 에러났을때 처리 */
    func errorProcess(type: SearchErrorType) {
        var errorString = ""
        switch type {
        case .INVALID_NICKNAME:
            errorString = "올바르지 않은 닉네임입니다."
            
            // 즐겨찾기에 해당 닉네임이 등록돼 있으면 그 즐겨찾기 삭제
            if containsBookmark(playerNickname: requestNickname) {
                removeBookmark(playerNickname: requestNickname)
            }
            break
        case .FAIL_PLAYER_API:
            errorString = "플레이어 검색 실패.\n잠시 후 다시 시도해주세요."
            break
        case .FAIL_MATCHES_API:
            errorString = "공성전 내역 조회 실패.\n잠시 후 다시 시도해주세요."
            break
        case .SERVER_ERROR:
            errorString = "오픈API 서버 점검 중입니다.\n잠시 후 다시 시도해주세요."
            break
        }
        
        sendAnalytics(type: .ERROR, event: ANALYTICS_EVENT.ERROR_MATCH_RECORD.rawValue, value: errorString)
        
        likeButton.isHidden = true
        hateButton.isHidden = true
        bookmarkButton.isHidden = true
        graphButton.isHidden = true
        
        errorText.text = errorString
        errorView.isHidden = false
        
        stopLoading()
    }
    
    
    // MARK:- TableView Delegate, Datasource
    /** 아이템 반환 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecordTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
        
        switch selectedGameType {
        case .ALL:
            if (allMatchesData?.count ?? 0) > indexPath.row {
                cell.setData(data: (allMatchesData?[indexPath.row] ?? nil))
            }
            break
        case .RATING:
            if (ratingMatchesData?.matches?.rows?.count ?? 0) > indexPath.row {
                cell.setData(data: (ratingMatchesData?.matches?.rows?[indexPath.row] ?? nil))
            }
            break
        case .NORMAL:
            if (normalMatchesData?.matches?.rows?.count ?? 0) > indexPath.row {
                cell.setData(data: (normalMatchesData?.matches?.rows?[indexPath.row] ?? nil))
            }
            break
        }
        
        return cell
    }
    
    /** 아이템 갯수 반환 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch selectedGameType {
        case .ALL:
            count = (ratingMatchesData?.matches?.rows?.count ?? 0) + (normalMatchesData?.matches?.rows?.count ?? 0)
        case .RATING:
            count =  ratingMatchesData?.matches?.rows?.count ?? 0
        case .NORMAL:
            count =  normalMatchesData?.matches?.rows?.count ?? 0
        }
        
        if count == 0 {
            recordTableView.isHidden = true
            noContentsView.isHidden = false
        }
        else {
            recordTableView.isHidden = false
            noContentsView.isHidden = true
        }
        
        return count
    }
    
    /** 아이템 클릭 이벤트 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recordTableView {
            if let cell = recordTableView.cellForRow(at: indexPath) as? RecordTableViewCell {
                requestRecordDetailMatchId = cell.getMatchId()
                performSegue(withIdentifier: "callRecordDetail", sender: self)
            }
        }
    }
    
    /** 스크롤했을때 모스트픽 감추는 애니메이션 */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var count = 0
        switch selectedGameType {
        case .ALL:
            count = (ratingMatchesData?.matches?.rows?.count ?? 0) + (normalMatchesData?.matches?.rows?.count ?? 0)
        case .RATING:
            count =  ratingMatchesData?.matches?.rows?.count ?? 0
        case .NORMAL:
            count =  normalMatchesData?.matches?.rows?.count ?? 0
        }
        
        if bigSizeTableViewHeight == 0 {
            bigSizeTableViewHeight = recordTableView.bounds.height + mostpicViewHeight.constant
        }
        let allCellsHeight = recordTableView.rowHeight * CGFloat(count)
        if bigSizeTableViewHeight < allCellsHeight {
            if scrollView.contentOffset.y != 0 {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.25, animations: {
                    self.mostpicViewY.constant = 80
                    self.view.layoutIfNeeded()
                })
            }
            else {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.25, animations: {
                    self.mostpicViewY.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    
    // MARK:- 클릭 이벤트
    /** 이전 버튼 클릭 이벤트 */
    @IBAction func onClickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /** 선호플레이어 버튼 클릭 이벤트 */
    @IBAction func onClickLikeButton(_ sender: Any) {
        if containsPlayerType(type: .LIKE, playerNickname: requestNickname) {
            removePlayerType(type: .LIKE, playerNickname: requestNickname)
        }
        else {
            addPlayerType(type: .LIKE, playerNickname: requestNickname, comment: "-")
        }
        updateTopMenuButton()
    }
    
    /** 블랙리스트 버튼 클릭 이벤트 */
    @IBAction func onClickHateButton(_ sender: Any) {
        if containsPlayerType(type: .HATE, playerNickname: requestNickname) {
            removePlayerType(type: .HATE, playerNickname: requestNickname)
        }
        else {
            addPlayerType(type: .HATE, playerNickname: requestNickname, comment: "-")
        }
        updateTopMenuButton()
    }
    
    /** 즐겨찾기 버튼 클릭 이벤트 */
    @IBAction func onClickBookmarkButton(_ sender: Any) {
        if containsBookmark(playerNickname: requestNickname) {
            removeBookmark(playerNickname: requestNickname)
            SSToast.show(msg: "즐겨찾기를 해제하였습니다.")
        }
        else {
            if addBookmark(playerNickname: requestNickname, grade: gradeLabel.text ?? "-급") {
                SSToast.show(msg: "즐겨찾기에 추가되었습니다.")
            }
            else {
                SSToast.show(msg: "즐겨찾기 가능 인원은\n 최대 3명입니다.")
            }
        }
        updateTopMenuButton()
    }
    
    /** 통계 버튼 클릭 이벤트 */
    @IBAction func onClickGraphButton(_ sender: Any) {
        performSegue(withIdentifier: "callRecordGraph", sender: self)
    }
    
    /** 전체 버튼 클릭 이벤트 */
    @IBAction func onClickAllButton(_ sender: Any) {
        updateGameSelectView(type: .ALL)
    }
    
    /** 공식전 버튼 클릭 이벤트 */
    @IBAction func onClickRatingButton(_ sender: Any) {
        updateGameSelectView(type: .RATING)
    }
    
    /** 일반전 버튼 클릭 이벤트 */
    @IBAction func onClickNormalButton(_ sender: Any) {
        updateGameSelectView(type: .NORMAL)
    }
}
