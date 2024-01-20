//
//  RecordDetailGraphViewController.swift
//  StarlightSearch
//
//  Created by CUDO on 12/07/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RecordDetailGraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum GraphType: Int {
        case KILL       = 0
        case DEATH      = 1
        case ASSIST     = 2
        case ATTACK     = 3
        case DAMAGE     = 4
        case BATTLE     = 5
        case SIGHT      = 6
    }
    
    @IBOutlet weak var gameDate: UILabel!
    
    // 그래프 선택 뷰
    @IBOutlet weak var graphTypeTap: UIView!
    @IBOutlet weak var killTypeButton: UIButton!
    @IBOutlet weak var deathTypeButton: UIButton!
    
    // 그래프
    @IBOutlet weak var graphTableView: UITableView!
    
    // 에러 뷰
    @IBOutlet weak var noDataView: UIView!
    
    // 광고
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    var adBannerView: GADBannerView!
    
    var winTeamData: [MatchesDetailData.player] = [MatchesDetailData.player]() // 승리팀 데이터
    var loseTeamData: [MatchesDetailData.player] = [MatchesDetailData.player]() // 패배팀 데이터
    
    var playerNickname: String = "" // 전적검색 요청할 닉네임
    var gameDateString: String = ""
    
    var selectedType: GraphType = .KILL // 표시할 데이터 타입
    
    var BOLD_FONT: UIFont? = nil
    var MEDIUM_FONT: UIFont? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAdBanner()
        
        BOLD_FONT = killTypeButton.titleLabel?.font
        MEDIUM_FONT = deathTypeButton.titleLabel?.font
        
        gameDate.text = gameDateString
        
        setGraphType(type: selectedType)
    }
    
    /** 선택한 타입에 맞춰 그래프 그려줌 */
    func setGraphType(type: GraphType) {
        selectedType = type
        
        for view in graphTypeTap.subviews {
            if let button = view as? UIButton {
                if button.tag == selectedType.rawValue {
                    button.backgroundColor = getColor(hexRGB: MAIN_COLOR)
                    button.setTitleColor(getColor(hexRGB: WHITE_COLOR), for: .normal)
                    button.titleLabel?.font = BOLD_FONT
                }
                else {
                    button.backgroundColor = getColor(hexRGB: WHITE_COLOR)
                    button.setTitleColor(getColor(hexRGB: MAIN_COLOR), for: .normal)
                    button.titleLabel?.font = MEDIUM_FONT
                }
            }
        }
        
        graphTableView.reloadData()
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
        adBannerView.adUnitID = IS_DEBUG ? AdMobBannerIdTest : AdMobRecordDetailGraphBannerId
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    

    // MARK:- TableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: RecordDetailTeamTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailTeamTableViewCell", for: indexPath) as! RecordDetailTeamTableViewCell
            cell.setData(data: winTeamData, isWin: true, type: selectedType)
            return cell
        case 1,2,3,4,5:
            let cell: RecordDetailGraphTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailGraphTableViewCell", for: indexPath) as! RecordDetailGraphTableViewCell
            
            if winTeamData.count >= indexPath.row {
                // 정상데이터
                cell.setData(winTeam: winTeamData, loseTeam: loseTeamData, index: indexPath.row, type: selectedType, playerNickname: playerNickname)
            }
            else {
                // 탈주인원
                cell.setEscapePlayer()
            }
            return cell
        case 6:
            let cell: RecordDetailTeamTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailTeamTableViewCell", for: indexPath) as! RecordDetailTeamTableViewCell
            cell.setData(data: loseTeamData, isWin: false, type: selectedType)
            return cell
        default:
            let cell: RecordDetailGraphTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailGraphTableViewCell", for: indexPath) as! RecordDetailGraphTableViewCell
            
            if loseTeamData.count >= (indexPath.row-6) {
                // 정상데이터
                cell.setData(winTeam: winTeamData, loseTeam: loseTeamData, index: indexPath.row, type: selectedType, playerNickname: playerNickname)
            }
            else {
                // 탈주인원
                cell.setEscapePlayer()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 6 {
            return 35
        }
        else {
            return 40
        }
    }
    
    
    // MARK:- 클릭 이벤트
    /** 이전 버튼 클릭 이벤트 */
    @IBAction func onClickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /** 그래프 타입 버튼 클릭 이벤트 */
    @IBAction func onClickGraphTypeButton(_ sender: Any) {
        let button = sender as! UIButton
        switch button.tag {
        case 0:
            setGraphType(type: .KILL)
            return
        case 1:
            setGraphType(type: .DEATH)
            return
        case 2:
            setGraphType(type: .ASSIST)
            return
        case 3:
            setGraphType(type: .ATTACK)
            return
        case 4:
            setGraphType(type: .DAMAGE)
            return
        case 5:
            setGraphType(type: .BATTLE)
            return
        case 6:
            setGraphType(type: .SIGHT)
            return
        default: return
        }
    }
}
