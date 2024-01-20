//
//  RecordDetailViewController.swift
//  StarlightSearch
//
//  Created by CUDO on 31/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RecordDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellToRecordDetailViewDelegate {
    
    @IBOutlet weak var gameResultLabel: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var gameInfoLabel: UILabel!
    @IBOutlet weak var matchDetailTableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    var adBannerView: GADBannerView!
    
    var loadingView: LoadingView = LoadingView()
    
    var requestMatchId: String = "" // 조회할 매치ID
    var playerNickname: String = "" // 검색한 당사자
    
    var winTeamData: [MatchesDetailData.player] = [MatchesDetailData.player]() // 승리팀 서버통신 데이터
    var loseTeamData: [MatchesDetailData.player] = [MatchesDetailData.player]() // 패배팀 서버통신 데이터
    
    var requesSearchtNickname: String = "" // 전적검색 요청할 닉네임
    var gameDateString: String = ""
    
    // MARK:- Override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callRecordFromRecordDetail", let destination = segue.destination as? RecordViewController {
            destination.requestNickname = requesSearchtNickname
        }
        else if segue.identifier == "callRecordDetailGraph", let destination = segue.destination as? RecordDetailGraphViewController {
            destination.winTeamData = winTeamData
            destination.loseTeamData = loseTeamData
            destination.playerNickname = playerNickname
            destination.gameDateString = gameDateString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestMatchesDetail()
        initAdBanner()
    }
    

    // MARK:- API
    /** 플레이어 매칭 상세정보 조회 API */
    private func requestMatchesDetail() {
        startLoading()
        
        NeopleApiManager.shared.requestMatchesDetail(matchId: requestMatchId, responseCompletion: { (data: MatchesDetailData) in
            SSLog("[API] 플레이어 매칭 상세정보 조회 API 성공 : \(data.date ?? "NULL")")
            self.calcMatchDetailData(data: data)
            
            let gameType = data.gameTypeId=="rating" ? "공식전" : "일반전"
            var playTimeString = ""
            if let players = data.players {
                for player in players {
                    if let playTime = player.playInfo?.playTime {
                        playTimeString = "\(String(playTime/60))분 \(String(playTime%60))초"
                        break
                    }
                }
            }
            self.gameInfoLabel.text = "\(gameType) | \(data.date ?? "") | \(playTimeString)"
            self.gameDateString = data.date ?? ""
            
            self.matchDetailTableView.reloadData()
            self.errorView.isHidden = true
            self.stopLoading()
        }) { (err) in
            SSLog("[API] 플레이어 매칭 상세정보 조회 API 실패 : \(String(describing: err.localizedDescription))")
            self.errorProcess()
        }
    }
    
    /** 데이터 가공 */
    func calcMatchDetailData(data: MatchesDetailData) {
        // 승리팀/패배팀
        if let teams = data.teams {
            for team in teams {
                // 팀의 플레이어들
                if let playerIds = team.players {
                    for playerId in playerIds {
                        // 실제 게임 플레이어들
                        if let players = data.players {
                            for player in players {
                                if player.playerId == playerId {
                                    if team.result == "win" {
                                        winTeamData.append(player)
                                    }
                                    else if team.result == "lose" {
                                        loseTeamData.append(player)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK:- View    
    /** 에러처리 */
    func errorProcess() {
        sendAnalytics(type: .ERROR, event: ANALYTICS_EVENT.ERROR_RECORD_DETAIL.rawValue, value: "전적 세부내역을 불러오는데 오류가 발생하였습니다.")
        graphButton.isHidden = true
        errorView.isHidden = false
        stopLoading()
    }
    
    /** 로딩 시작 */
    func startLoading() {
        loadingView.startLoading(vc: self)
    }
    
    /** 로딩 종료 */
    func stopLoading() {
        loadingView.stopLoading()
    }
    
    /** 광고 그리기 */
    func initAdBanner() {
        // 뷰 생성
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
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
        adViewHeight.constant = HIDE_ADVIEW ? 0 : adBannerView.bounds.height
        
        // 속성 설정
        adBannerView.adUnitID = IS_DEBUG ? AdMobBannerIdTest : AdMobRecordDetailBannerId
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    
    
    // MARK:- TableView Delegate
    /** 아이템 반환 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: RecordTeamTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordTeamTableViewCell", for: indexPath) as! RecordTeamTableViewCell
            cell.setData(data: winTeamData, isWin: true)
            return cell
        case 1,2,3,4,5:
            let cell: RecordDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailTableViewCell", for: indexPath) as! RecordDetailTableViewCell
            
            if winTeamData.count >= indexPath.row {
                // 정상데이터
                cell.setData(winTeam: winTeamData, loseTeam: loseTeamData, index: indexPath.row)
                cell.setDelegate(_delegate: self)
                if cell.getNickname() == playerNickname {
                    cell.setMainPlayer(isMain: true)
                }
                else {
                    cell.setMainPlayer(isMain: false)
                }
            }
            else {
                // 탈주인원
                cell.setEscapePlayer()
            }
            return cell
        case 6:
            let cell: RecordTeamTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordTeamTableViewCell", for: indexPath) as! RecordTeamTableViewCell
            cell.setData(data: loseTeamData, isWin: false)
            return cell
        default:
            let cell: RecordDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailTableViewCell", for: indexPath) as! RecordDetailTableViewCell
            
            if loseTeamData.count >= (indexPath.row-6) {
                // 정상데이터
                cell.setData(winTeam: winTeamData, loseTeam: loseTeamData, index: indexPath.row)
                cell.setDelegate(_delegate: self)
                if cell.getNickname() == playerNickname {
                    cell.setMainPlayer(isMain: true)
                }
                else {
                    cell.setMainPlayer(isMain: false)
                }
            }
            else {
                // 탈주인원
                cell.setEscapePlayer()
            }
            return cell
        }
    }
    
    /** 아이템 갯수 반환 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    /** 아이템 클릭 이벤트 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 6 {
            return
        }
        
        let cell: RecordDetailTableViewCell = matchDetailTableView.cellForRow(at: indexPath) as! RecordDetailTableViewCell
        
        if cell.escapeView.isHidden == false || cell.getNickname() == "" { // 내역이 표시되지 않고 있다면 이동하지 않음
            return
        }
        
        requesSearchtNickname = cell.getNickname()
        performSegue(withIdentifier: "callRecordFromRecordDetail", sender: self)
    }
    
    /** 아이템 높이값 반환 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 6 {
            return 35
        }
        else {
            return 118
        }
    }
    
    // MARK:- TableView CellToRecordDetailViewDelegate
    /** 아이템 팝업 */
    func showItemPopup(name: String, rarity: String, info: String) {
        PopupUtils.showItemPopup(vc: self, name: name, rarity: rarity, info: info)
    }
    
    
    // MARK:- 클릭 이벤트
    /** 이전 버튼 클릭 이벤트 */
    @IBAction func onClickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /** 통계 버튼 클릭 이벤트 */
    @IBAction func onClickGraphButton(_ sender: Any) {
        performSegue(withIdentifier: "callRecordDetailGraph", sender: self)
    }
}
