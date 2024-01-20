//
//  RecordGraphViewController.swift
//  StarlightSearch
//
//  Created by CUDO on 06/07/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import GoogleMobileAds

// 모스트픽 구조체
public struct RecordGraphCharacterData: Codable {
    var characterId : String?
    var characterName : String?
    var winCount : Int?
    var loseCount : Int?
    var killCount : Int?
    var deathCount : Int?
    var assistCount : Int?
    var attackPoint : Int?
    var damagePoint : Int?
    var battlePoint : Int?
    var sightPoint : Int?
    var playCount : Int?
}

class RecordGraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum ChartType: String {
        case CHARACTER = "CHARACTER"
        case GRAPH     = "GRAPH"
    }
    
    // 탑메뉴
    @IBOutlet weak var titleLabel: UILabel!
    
    // 통계 선택 탭
    @IBOutlet weak var characterButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    
    // 게임 타입 선택 탭
    @IBOutlet weak var allGameButton: UIButton!
    @IBOutlet weak var ratingGameButton: UIButton!
    @IBOutlet weak var normalGameButton: UIButton!
    
    // 캐릭터 목록
    @IBOutlet weak var characterListTableView: UITableView!
    
    // 그래프들
    @IBOutlet weak var graphScrollView: UIScrollView!
    @IBOutlet weak var recordGraphView: RecordGraphView!
    @IBOutlet weak var recordGraphViewHeight: NSLayoutConstraint!
    
    // 에러 뷰
    @IBOutlet weak var noDataView: UIView!
    
    // 광고
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    var adBannerView: GADBannerView!
    
    var requestNickname = ""
    var allMatchesDataSource: [AllMatchesData]?
    var ratingMatchesDataSource: MatchesData?
    var normalMatchesDataSource: MatchesData?
    var allMatchesData: [RecordGraphCharacterData]? // 전체 게임 데이터
    var ratingMatchesData: [RecordGraphCharacterData]? // 공식전 게임 데이터
    var normalMatchesData: [RecordGraphCharacterData]? // 일반전 게임 데이터
    
    var selectedChartType: ChartType = .CHARACTER // 표시할 차트 타입
    var selectedGameType: GameType = .ALL // 표시할 게임 타입
    
    var BOLD_FONT: UIFont? = nil
    var MEDIUM_FONT: UIFont? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAdBanner() // 광고 뷰 그리기
        
        BOLD_FONT = characterButton.titleLabel?.font
        MEDIUM_FONT = graphButton.titleLabel?.font
        
        calcCharacterData()
        
        // 초기 메뉴 선택 값
        titleLabel.text = "[\(requestNickname)]님의 통계"
        setChartType(type: .CHARACTER)
    }
    
    
    // MARK:- 뷰 그리기
    /** 캐릭터 통계/그래프 선택 */
    func setChartType(type: ChartType) {
        
        selectedChartType = type
        
        switch type {
        case .CHARACTER:
            characterButton.backgroundColor = getColor(hexRGB: MAIN_COLOR)
            characterButton.setTitleColor(getColor(hexRGB: WHITE_COLOR), for: .normal)
            characterButton.titleLabel?.font = BOLD_FONT
            graphButton.backgroundColor = getColor(hexRGB: WHITE_COLOR)
            graphButton.setTitleColor(getColor(hexRGB: MAIN_COLOR), for: .normal)
            graphButton.titleLabel?.font = MEDIUM_FONT
            break
        case .GRAPH:
            characterButton.backgroundColor = getColor(hexRGB:WHITE_COLOR)
            characterButton.setTitleColor(getColor(hexRGB: MAIN_COLOR), for: .normal)
            characterButton.titleLabel?.font = MEDIUM_FONT
            graphButton.backgroundColor = getColor(hexRGB: MAIN_COLOR)
            graphButton.setTitleColor(getColor(hexRGB: WHITE_COLOR), for: .normal)
            graphButton.titleLabel?.font = BOLD_FONT
            break
        }
        
        setGameType(type: .ALL)
    }
    
    /** 전체/공식전/일반전 선택 */
    func setGameType(type: GameType) {
        
        selectedGameType = type
        
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
            break
        }
        
        updateMainView()
    }
    
    /** 어떤 데이터를 표시할건지 선택 */
    func updateMainView() {
        
        // 데이터 있는지 먼저 체크
        var isNoData = false
        switch selectedGameType {
        case .ALL:
            if allMatchesData == nil || allMatchesData!.isEmpty {
                isNoData = true
            }
            break
        case .RATING:
            if ratingMatchesData == nil || ratingMatchesData!.isEmpty {
                isNoData = true
            }
            break
        case .NORMAL:
            if normalMatchesData == nil || normalMatchesData!.isEmpty {
                isNoData = true
            }
            break
        }
        if isNoData {
            characterListTableView.isHidden = true
            graphScrollView.isHidden = true
            noDataView.isHidden = false
            return
        }
        
        // 보여줄 뷰 확인
        switch selectedChartType {
        case .CHARACTER:
            characterListTableView.isHidden = false
            graphScrollView.isHidden = true
            recordGraphView.setGameType(type: selectedGameType) // 미리 한 번 그려둠
            noDataView.isHidden = true
            characterListTableView.setContentOffset(.zero, animated: false)
            characterListTableView.reloadData()
            characterListTableView.layoutIfNeeded()
            characterListTableView.setContentOffset(.zero, animated: false)
            break
        case .GRAPH:
            characterListTableView.isHidden = true
            graphScrollView.isHidden = false
            noDataView.isHidden = true
            recordGraphView.setGameType(type: selectedGameType)
            recordGraphViewHeight.constant = recordGraphView.getViewHeight()
            
            graphScrollView.setContentOffset(.zero, animated: false)
            graphScrollView.layoutIfNeeded()
            graphScrollView.setContentOffset(.zero, animated: false)
            break
        }
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
        adBannerView.adUnitID = IS_DEBUG ? AdMobBannerIdTest : AdMobRecordGraphBannerId
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    
    
    // MARK:- 데이터 처리
    /** 캐릭터별 분류 */
    func calcCharacterData() {
        
        // 사용할 데이터 선택
        var matchesDatas = [MatchesData].init()
        if ratingMatchesDataSource != nil {
            matchesDatas.append(ratingMatchesDataSource!)
        }
        ratingMatchesData = getRecordGraphCharacter(datas: matchesDatas)
        
        if normalMatchesDataSource != nil {
            matchesDatas.append(normalMatchesDataSource!)
        }
        allMatchesData = getRecordGraphCharacter(datas: matchesDatas)
        
        matchesDatas.removeAll()
        if normalMatchesDataSource != nil {
            matchesDatas.append(normalMatchesDataSource!)
        }
        normalMatchesData = getRecordGraphCharacter(datas: matchesDatas)
        
        // 계산한 값 그래프 뷰에도 세팅
        recordGraphView.initView(all: allMatchesData ?? nil, rating: ratingMatchesData ?? nil, normal: normalMatchesData ?? nil)
    }
    
    
    // MARK:- TableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecordGraphTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordGraphTableViewCell", for: indexPath) as! RecordGraphTableViewCell
        
        switch selectedGameType {
        case .ALL:
            if (allMatchesData?.count ?? 0) > indexPath.row {
                cell.setData(data: (allMatchesData?[indexPath.row] ?? nil), index: indexPath.row)
            }
            break
        case .RATING:
            if (ratingMatchesData?.count ?? 0) > indexPath.row {
                cell.setData(data: (ratingMatchesData?[indexPath.row] ?? nil), index: indexPath.row)
            }
            break
        case .NORMAL:
            if (normalMatchesData?.count ?? 0) > indexPath.row {
                cell.setData(data: (normalMatchesData?[indexPath.row] ?? nil), index: indexPath.row)
            }
            break
        }
        return cell
    }
    
    /** 행 갯수 반환 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedGameType {
        case .ALL:
            return allMatchesData?.count ?? 0
        case .RATING:
            return ratingMatchesData?.count ?? 0
        case .NORMAL:
            return normalMatchesData?.count ?? 0
        }
    }
    
    
    // MARK:- 클릭 이벤트
    /** 이전 버튼 클릭 이벤트 */
    @IBAction func onClickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /** 캐릭터별 전적 버튼 클릭 이벤트 */
    @IBAction func onClickCharacterButton(_ sender: Any) {
        setChartType(type: .CHARACTER)
    }
    
    /** 캐릭터별 그래프 버튼 클릭 이벤트 */
    @IBAction func onClickGraphButton(_ sender: Any) {
        setChartType(type: .GRAPH)
    }
    
    /** 전체 버튼 클릭 이벤트 */
    @IBAction func onClickAllButton(_ sender: Any) {
        setGameType(type: .ALL)
    }
    
    /** 공식전 버튼 클릭 이벤트 */
    @IBAction func onClickRatingButton(_ sender: Any) {
        setGameType(type: .RATING)
    }
    
    /** 일반전 버튼 클릭 이벤트 */
    @IBAction func onClickNormalButton(_ sender: Any) {
        setGameType(type: .NORMAL)
    }
}
