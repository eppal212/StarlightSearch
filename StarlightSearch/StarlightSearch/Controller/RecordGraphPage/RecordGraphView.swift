//
//  RecordGraphView.swift
//  StarlightSearch
//
//  Created by CUDO on 06/07/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

public enum RecordGraphBattlePointType: String {
    case ATTACK  = "ATTACK"
    case DAMAGE  = "DAMAGE"
    case BATTLE  = "BATTLE"
    case SIGHT   = "SIGHT"
}

class RecordGraphView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var winAverageGraphView: UIView!
    @IBOutlet weak var winAverageTableView: UITableView!
    @IBOutlet weak var winAverageTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var battlePointGraphView: UIView!
    @IBOutlet weak var battlePointTableView: UITableView!
    @IBOutlet weak var battlePointTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var battlePointAttackButton: UIButton!
    @IBOutlet weak var battlePointDamageButton: UIButton!
    @IBOutlet weak var battlePointBattleButton: UIButton!
    @IBOutlet weak var battlePointSightButton: UIButton!
    
    @IBOutlet weak var kdaGraphView: UIView!
    @IBOutlet weak var kdaTableView: UITableView!
    @IBOutlet weak var kdaTableViewHeight: NSLayoutConstraint!
    
    var contentView: UIView?
    
    var allMatchesDataSource: [RecordGraphCharacterData]? // 전체 게임 데이터
    var ratingMatchesDataSource: [RecordGraphCharacterData]? // 공식전 게임 데이터
    var normalMatchesDataSource: [RecordGraphCharacterData]? // 일반전 게임 데이터
    
    // 5판 이상 한 캐릭터들만
    var allMatchesData = [RecordGraphCharacterData]() // 전체 게임 데이터
    var ratingMatchesData = [RecordGraphCharacterData]() // 공식전 게임 데이터
    var normalMatchesData = [RecordGraphCharacterData]() // 일반전 게임 데이터
    
    // 승률 그래프용 데이터
    var allMatchesDataForWinAve: [RecordGraphCharacterData]? // 전체 게임 데이터
    var ratingMatchesDataForWinAve: [RecordGraphCharacterData]? // 공식전 게임 데이터
    var normalMatchesDataForWinAve: [RecordGraphCharacterData]? // 일반전 게임 데이터
    
    // KDA 그래프용 데이터
    var allMatchesDataForKda: [RecordGraphCharacterData]? // 전체 게임 데이터
    var ratingMatchesDataForKda: [RecordGraphCharacterData]? // 공식전 게임 데이터
    var normalMatchesDataForKda: [RecordGraphCharacterData]? // 일반전 게임 데이터
    
    var selectedGameType: GameType = .ALL // 표시할 게임 타입
    var selectedBattlePointType: RecordGraphBattlePointType = .ATTACK // 캐릭터별 전투기록 그래프에 표시할 데이터
    
    /** 뷰 초기화 */
    func initView(all: [RecordGraphCharacterData]?, rating: [RecordGraphCharacterData]?, normal: [RecordGraphCharacterData]?) {
        
        allMatchesDataSource = all
        ratingMatchesDataSource = rating
        normalMatchesDataSource = normal
        filteringData() // 5판 이상 플레이한 케릭터들만 추림
        
        if contentView == nil {
            let className = String(describing: type(of: self))
            contentView = Bundle.main.loadNibNamed(className, owner: self, options: nil)?.first as? UIView
            contentView?.frame = self.bounds
            if contentView != nil {
                addSubview(contentView!)
            }
        }
        
        // identifier 연결
        winAverageTableView.register(UINib(nibName: "RecordGraphItemTableViewCell", bundle: nil), forCellReuseIdentifier: "RecordGraphItemTableViewCell")
        battlePointTableView.register(UINib(nibName: "RecordGraphItemTableViewCell", bundle: nil), forCellReuseIdentifier: "RecordGraphItemTableViewCell")
        kdaTableView.register(UINib(nibName: "RecordGraphItemTableViewCell", bundle: nil), forCellReuseIdentifier: "RecordGraphItemTableViewCell")
    }
    
    /** 선택한 게임 타입에 맞춰 그래프 그려줌 */
    func setGameType(type: GameType) {
        selectedGameType = type
        
        updateWinAverageView()
        updatePointView()
        updateKDAView()
        
        winAverageTableViewHeight.constant = winAverageTableView.rowHeight * CGFloat(getRowCount())
        battlePointTableViewHeight.constant = battlePointTableView.rowHeight * CGFloat(getRowCount())
        kdaTableViewHeight.constant = battlePointTableView.rowHeight * CGFloat(getRowCount())
    }
    
    /** 승률 그래프 그리기 */
    func updateWinAverageView() {
        winAverageTableView.reloadData()
    }
    
    /** 전투기록 그래프 그리기 */
    func updatePointView() {
        battlePointTableView.reloadData()
        
        battlePointAttackButton.isSelected = false
        battlePointDamageButton.isSelected = false
        battlePointBattleButton.isSelected = false
        battlePointSightButton.isSelected = false
        switch selectedBattlePointType {
        case .ATTACK:
            battlePointAttackButton.isSelected = true
            break
        case .DAMAGE:
            battlePointDamageButton.isSelected = true
            break
        case .BATTLE:
            battlePointBattleButton.isSelected = true
            break
        case .SIGHT:
            battlePointSightButton.isSelected = true
            break
        }
    }
    
    /** KDA 그래프 그리기 */
    func updateKDAView() {
        kdaTableView.reloadData()
    }
    
    /** 뷰 높이 반환 */
    func getViewHeight() -> CGFloat {
        layoutIfNeeded()
        return winAverageGraphView.bounds.height + battlePointGraphView.bounds.height + kdaGraphView.bounds.height + 70
    }
    
    
    // MARK:- 데이터
    /** 5판 이상 플레이한 케릭터들만 추림 */
    func filteringData() {
        // 데이터 추림
        allMatchesData.removeAll()
        for data in allMatchesDataSource ?? [] {
            if data.playCount ?? 0 >= 5 {
                allMatchesData.append(data)
            }
        }
        ratingMatchesData.removeAll()
        for data in ratingMatchesDataSource ?? [] {
            if data.playCount ?? 0 >= 5 {
                ratingMatchesData.append(data)
            }
        }
        normalMatchesData.removeAll()
        for data in normalMatchesDataSource ?? [] {
            if data.playCount ?? 0 >= 5 {
                normalMatchesData.append(data)
            }
        }
        
        // 승률그래프용 데이터
        allMatchesDataForWinAve = allMatchesData.sorted { (item1, item2) -> Bool in
            return self.sortWinAve(item1: item1, item2: item2)
        }
        ratingMatchesDataForWinAve = ratingMatchesData.sorted { (item1, item2) -> Bool in
            return self.sortWinAve(item1: item1, item2: item2)
        }
        normalMatchesDataForWinAve = normalMatchesData.sorted { (item1, item2) -> Bool in
            return self.sortWinAve(item1: item1, item2: item2)
        }
        
        // kda그래프용 데이터
        allMatchesDataForKda = allMatchesData.sorted { (item1, item2) -> Bool in
            return self.sortKda(item1: item1, item2: item2)
        }
        ratingMatchesDataForKda = ratingMatchesData.sorted { (item1, item2) -> Bool in
            return self.sortKda(item1: item1, item2: item2)
        }
        normalMatchesDataForKda = normalMatchesData.sorted { (item1, item2) -> Bool in
            return self.sortKda(item1: item1, item2: item2)
        }
    }
    
    /** 승률이 높은 순서대로 정렬하기 위한 sorted 함수 내부과정을 따로 분리 */
    func sortWinAve(item1: RecordGraphCharacterData, item2: RecordGraphCharacterData) -> Bool {
        let item1WinAve = Float(item1.winCount ?? 0) / Float(item1.playCount ?? 1)
        let item2WinAve = Float(item2.winCount ?? 0) / Float(item2.playCount ?? 1)
        if item1WinAve < item2WinAve {
            return false
        }
        else {
            return true
        }
    }
    
    /** KDA가 높은 순서대로 정렬하기 위한 sorted 함수 내부과정을 따로 분리 */
    func sortKda(item1: RecordGraphCharacterData, item2: RecordGraphCharacterData) -> Bool {
        let kill1 = round(Float(item1.killCount ?? 0) / Float(item1.playCount ?? 1))
        let death1 = round(Float(item1.deathCount ?? 0) / Float(item1.playCount ?? 1))
        let assist1 = round(Float(item1.assistCount ?? 0) / Float(item1.playCount ?? 1))
        var item1kda: Float = 0
        if death1 == 0 {
            item1kda = ((Float(kill1) + Float(assist1)) / Float(1)) * 1.2
        }
        else {
            item1kda = (Float(kill1) + Float(assist1)) / Float(death1)
        }
        let kill2 = round(Float(item2.killCount ?? 0) / Float(item2.playCount ?? 1))
        let death2 = round(Float(item2.deathCount ?? 0) / Float(item2.playCount ?? 1))
        let assist2 = round(Float(item2.assistCount ?? 0) / Float(item2.playCount ?? 1))
        var item2kda: Float = 0
        if death2 == 0 {
            item2kda = ((Float(kill2) + Float(assist2)) / Float(1)) * 1.2
        }
        else {
            item2kda = (Float(kill2) + Float(assist2)) / Float(death2)
        }
        
        if item1kda < item2kda {
            return false
        }
        else {
            return true
        }
    }
    
    
    // MARK:- TableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecordGraphItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecordGraphItemTableViewCell", for: indexPath) as! RecordGraphItemTableViewCell
        
        if tableView == winAverageTableView {
            switch selectedGameType {
            case .ALL:
                if (allMatchesDataForWinAve?.count ?? 0) > indexPath.row {
                    cell.setWinAveData(datas: allMatchesDataForWinAve ?? [], index: indexPath.row)
                }
                break
            case .RATING:
                if (ratingMatchesDataForWinAve?.count ?? 0) > indexPath.row {
                    cell.setWinAveData(datas: ratingMatchesDataForWinAve ?? [], index: indexPath.row)
                }
                break
            case .NORMAL:
                if (normalMatchesDataForWinAve?.count ?? 0) > indexPath.row {
                    cell.setWinAveData(datas: normalMatchesDataForWinAve ?? [], index: indexPath.row)
                }
                break
            }
        }
        else if tableView == battlePointTableView {
            switch selectedGameType {
            case .ALL:
                if (allMatchesData.count) > indexPath.row {
                    cell.setBattleRecordData(datas: allMatchesData, index: indexPath.row, type: selectedBattlePointType)
                }
                break
            case .RATING:
                if (ratingMatchesData.count) > indexPath.row {
                    cell.setBattleRecordData(datas: ratingMatchesData, index: indexPath.row, type: selectedBattlePointType)
                }
                break
            case .NORMAL:
                if (normalMatchesData.count) > indexPath.row {
                    cell.setBattleRecordData(datas: normalMatchesData, index: indexPath.row, type: selectedBattlePointType)
                }
                break
            }
        }
        else if tableView == kdaTableView {
            switch selectedGameType {
            case .ALL:
                if (allMatchesDataForKda?.count ?? 0) > indexPath.row {
                    cell.setKdaData(datas: allMatchesDataForKda ?? [], index: indexPath.row)
                }
                break
            case .RATING:
                if (ratingMatchesDataForKda?.count ?? 0) > indexPath.row {
                    cell.setKdaData(datas: ratingMatchesDataForKda ?? [], index: indexPath.row)
                }
                break
            case .NORMAL:
                if (normalMatchesDataForKda?.count ?? 0) > indexPath.row {
                    cell.setKdaData(datas: normalMatchesDataForKda ?? [], index: indexPath.row)
                }
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRowCount()
    }
    
    func getRowCount() -> Int {
        switch selectedGameType {
        case .ALL:
            return allMatchesData.count
        case .RATING:
            return ratingMatchesData.count
        case .NORMAL:
            return normalMatchesData.count
        }
    }
    
    
    // MARK:- 클릭 이벤트
    /** 전투기록 버튼 클릭 이벤트 */
    @IBAction func onClickBattlePointGraphButton(_ sender: Any) {
        let button = sender as! UIButton
        switch button.tag {
        case 0:
            selectedBattlePointType = .ATTACK
            break
        case 1:
            selectedBattlePointType = .DAMAGE
            break
        case 2:
            selectedBattlePointType = .BATTLE
            break
        case 3:
            selectedBattlePointType = .SIGHT
            break
        default: break
        }
        updatePointView()
    }
}
