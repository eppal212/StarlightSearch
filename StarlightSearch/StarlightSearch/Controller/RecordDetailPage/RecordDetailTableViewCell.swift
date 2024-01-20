//
//  RecordDetailTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 18/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

/** Cell에서 전적세부내역을 호출하는 Delegate */
protocol CellToRecordDetailViewDelegate: class {
    func showItemPopup(name: String, rarity: String, info: String)
}

class RecordDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var kdaData: UILabel!
    @IBOutlet weak var kdaDetailData: UILabel!
    @IBOutlet weak var damageData: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var hateImage: UIImageView!
    
    @IBOutlet weak var position: UIButton!
    @IBOutlet weak var ability1: UIButton!
    @IBOutlet weak var ability2: UIButton!
    @IBOutlet weak var ability3: UIButton!
    
    @IBOutlet weak var item01: UIButton!
    @IBOutlet weak var item02: UIButton!
    @IBOutlet weak var item03: UIButton!
    @IBOutlet weak var item04: UIButton!
    @IBOutlet weak var item05: UIButton!
    @IBOutlet weak var item06: UIButton!
    @IBOutlet weak var item07: UIButton!
    @IBOutlet weak var item08: UIButton!
    @IBOutlet weak var item09: UIButton!
    @IBOutlet weak var item10: UIButton!
    @IBOutlet weak var item11: UIButton!
    @IBOutlet weak var item12: UIButton!
    @IBOutlet weak var item13: UIButton!
    @IBOutlet weak var item14: UIButton!
    @IBOutlet weak var item15: UIButton!
    @IBOutlet weak var item16: UIButton!

    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var escapeView: UIView!
    
    var delegate: CellToRecordDetailViewDelegate?
    
    var nickname = ""
    var playerData: MatchesDetailData.player?
    var attributeDetailData = [String:String]() // 특성 데이터
    var itemDetailData = [String:String]() // 장착아이템 데이터

    
    // MARK:- Basic
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // MARK:- View
    /** 데이터 세팅하여 뷰 그리기 */
    func setData(winTeam: [MatchesDetailData.player], loseTeam: [MatchesDetailData.player], index: Int) {
        if winTeam.count == 0 || loseTeam.count == 0 {
            errorView.isHidden = false
            escapeView.isHidden = true
        }
        else {
            errorView.isHidden = true
            escapeView.isHidden = true
            
            var isWin = false
            
            // 표시하려는 playerData 찾기
            var trueIndex = index - 1
            playerData = nil
            if winTeam.count > trueIndex {
                playerData = winTeam[trueIndex]
                isWin = true
            }
            else {
                trueIndex = index - 7
            }
            if playerData == nil {
                if loseTeam.count > trueIndex {
                    playerData = loseTeam[trueIndex]
                    isWin = false
                }
            }
            
            // 표시하려는 데이터가 없으면 끝
            if playerData == nil {
                errorView.isHidden = false
                return
            }
            else {
                nickname = playerData?.nickname ?? ""
                
                // 선호/블랙리스트 여부
                if containsPlayerType(type: .LIKE, playerNickname: nickname) {
                    likeImage.image = UIImage(named: "img_heart_sel")
                }
                else {
                    likeImage.image = UIImage(named: "img_heart_nor")
                }
                if containsPlayerType(type: .HATE, playerNickname: nickname) {
                    hateImage.image = UIImage(named: "img_broken_heart_sel")
                }
                else {
                    hateImage.image = UIImage(named: "img_broken_heart_nor")
                }
                
                // 캐릭터 이미지
                if isWin {
                    profileImage.layer.borderColor = getColor(hexRGB: BLUE_COLOR)?.cgColor
                }
                else {
                    profileImage.layer.borderColor = getColor(hexRGB: RED_COLOR)?.cgColor
                }
                profileImage.layer.cornerRadius = profileImage.frame.height/2
                profileImage.layer.borderWidth = 2
                profileImage.clipsToBounds = true
                if let characterId = playerData?.playInfo?.characterId {
                    profileImage.kf.setImage(with: URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + characterId)), placeholder: UIImage(named: "img_random"))
                }
                
                // 특성
                if let url = URL(string: UserInformation.shared.imageUrlDict[playerData?.position?.name ?? ""] ?? "") {
                    position.kf.setBackgroundImage(with: url, for: .normal, placeholder: UIImage(named: "img_random"))
                }
                position.layer.cornerRadius = (position.frame.height)/4
                position.clipsToBounds = true
                
                if let attributes = playerData?.position?.attribute {
                    for attr in attributes {
                        switch attr.level {
                        case 1:
                            ability1.kf.setBackgroundImage(with: URL(string: (API_TYPE.ATTRIBUTE_IMAGE.rawValue + (attr.id ?? ""))), for: .normal, placeholder: UIImage(named: "img_random"))
                            attributeDetailData[String(ability1.tag)] = attr.id
                            break
                        case 2:
                            ability2.kf.setBackgroundImage(with: URL(string: (API_TYPE.ATTRIBUTE_IMAGE.rawValue + (attr.id ?? ""))), for: .normal, placeholder: UIImage(named: "img_random"))
                            attributeDetailData[String(ability2.tag)] = attr.id
                            break
                        case 3:
                            ability3.kf.setBackgroundImage(with: URL(string: (API_TYPE.ATTRIBUTE_IMAGE.rawValue + (attr.id ?? ""))), for: .normal, placeholder: UIImage(named: "img_random"))
                            attributeDetailData[String(ability3.tag)] = attr.id
                            break
                        default: break
                        }
                    }
                }
                ability1.layer.cornerRadius = (ability1.frame.height)/4
                ability1.clipsToBounds = true
                ability2.layer.cornerRadius = (ability2.frame.height)/4
                ability2.clipsToBounds = true
                ability3.layer.cornerRadius = (ability3.frame.height)/4
                ability3.clipsToBounds = true
                
                // 유저 닉네임
                var partyPlayer = "솔로"
                if (playerData?.playInfo?.partyUserCount ?? 1) > 1 {
                    partyPlayer = "\(String(playerData?.playInfo?.partyUserCount ?? 1))인"
                }
                if getModelName() == "iPhoneSE" {
                    userNickname.text = "\(playerData?.nickname ?? "")"
                }
                else {
                    userNickname.text = "\(playerData?.nickname ?? "") (\(partyPlayer))"
                }
                
                // 캐릭터 이름
                characterName.text = "\(playerData?.playInfo?.characterName ?? "") (\((playerData?.playInfo?.random ?? false) ? "랜덤" : "셀렉")/Lv.\(playerData?.playInfo?.level ?? 0))"
                
                // kda
                let kill = playerData?.playInfo?.killCount ?? 0
                let death = playerData?.playInfo?.deathCount ?? 1
                let assi = playerData?.playInfo?.assistCount ?? 0
                kdaData.text = "\(String(kill))킬 / \(String(death))데스 / \(String(assi))도움"
                
                // kda Detail
                var kda: Float = 0
                if death == 0 {
                    kda = (Float(kill+assi) / 1) * 1.2
                }
                else {
                    kda = Float(kill+assi) / Float(death)
                }
                var teamKill = 0
                if isWin {
                    for player in winTeam {
                        teamKill = teamKill + (player.playInfo?.killCount ?? 0)
                    }
                }
                else {
                    for player in loseTeam {
                        teamKill = teamKill + (player.playInfo?.killCount ?? 0)
                    }
                }
//                var killPercent: Int = 0
//                if teamKill != 0 {
//                    killPercent = Int((Float(kill+assi) / Float(teamKill)) * 100.0)
//                }
                kdaDetailData.text = "KDA \(String(format: "%.1f", kda))"//   킬관여 \(killPercent>100 ? 100 : killPercent)%"
                
                // 데미지
                let attack = playerData?.playInfo?.attackPoint ?? 0
                let damage = playerData?.playInfo?.damagePoint ?? 0
                let battle = playerData?.playInfo?.battlePoint ?? 0
                let sight = playerData?.playInfo?.sightPoint ?? 0
                
                var allPlayers = winTeam
                for player in loseTeam {
                    allPlayers.append(player)
                }
                
                let attackRankArray = allPlayers.sorted { (item1, item2) -> Bool in
                    if (item1.playInfo?.attackPoint ?? 0) < (item2.playInfo?.attackPoint ?? 0) {
                        return false
                    }
                    else {
                        return true
                    }
                }
                let attackRank = getRank(array: attackRankArray, player: playerData)
                
                let damageRankArray = allPlayers.sorted { (item1, item2) -> Bool in
                    if (item1.playInfo?.damagePoint ?? 0) < (item2.playInfo?.damagePoint ?? 0) {
                        return false
                    }
                    else {
                        return true
                    }
                }
                let damageRank = getRank(array: damageRankArray, player: playerData)
                
                let battleRankArray = allPlayers.sorted { (item1, item2) -> Bool in
                    if (item1.playInfo?.battlePoint ?? 0) < (item2.playInfo?.battlePoint ?? 0) {
                        return false
                    }
                    else {
                        return true
                    }
                }
                let battleRank = getRank(array: battleRankArray, player: playerData)
                
                let sightRankArray = allPlayers.sorted { (item1, item2) -> Bool in
                    if (item1.playInfo?.sightPoint ?? 0) < (item2.playInfo?.sightPoint ?? 0) {
                        return false
                    }
                    else {
                        return true
                    }
                }
                let sightRank = getRank(array: sightRankArray, player: playerData)
                
                if getModelName() == "iPhoneSE" {
                    damageData.text = "공격량    \(parsePoint(point: attack))\n피해량    \(parsePoint(point: damage))\n전투참여 \(battle)\n시야       \(sight)"
                }
                else {
                    damageData.text = "공격량    \(parsePoint(point: attack)) (\(getRankString(rank: attackRank ?? 0)))\n피해량    \(parsePoint(point: damage)) (\(getRankString(rank: damageRank ?? 0)))\n전투참여 \(battle) (\(getRankString(rank: battleRank ?? 0)))\n시야       \(sight) (\(getRankString(rank: sightRank ?? 0)))"
                }
                
                // 아이템 이미지 세팅
                let itemArray = [item01, item02, item03, item04, item05, item06, item07, item08, item09, item10, item11, item12, item13, item14, item15, item16]
                itemDetailData.removeAll()
                for itemButton in itemArray {
                    itemButton?.layer.cornerRadius = (itemButton?.frame.height ?? 24)/4
                    itemButton?.clipsToBounds = true
                    
                    var isSetting = false
                    if playerData != nil && playerData!.items != nil {
                        for item in playerData!.items! {
                            if let slotCode = item.equipSlotCode {
                            
                                if String(itemButton?.tag ?? 0) == slotCode {
                                    if let itemId = item.itemId {
                                        itemButton?.kf.setBackgroundImage(with: URL(string: (API_TYPE.ITEM_IMAGE.rawValue + itemId)), for: .normal, placeholder: UIImage(named: "img_item_nil"), completionHandler: { (image, error, cacheType, imageURL) in
                                            if error != nil {
                                                itemButton?.setBackgroundImage(UIImage(named: "img_random"), for: .normal)
                                            }
                                        })
                                        itemDetailData[String(itemButton?.tag ?? 0)] = itemId
                                        
                                        isSetting = true
                                    }
                                }
                            }
                        }
                    }
                    
                    if isSetting == false {
                        itemButton?.setBackgroundImage(UIImage(named: "img_item_nil"), for: .normal)
                    }
                }
            }
        }
    }
    
    /** 델리게이트 세팅 */
    func setDelegate(_delegate: CellToRecordDetailViewDelegate) {
        delegate = _delegate
    }
    
    /** 검색한 주체 플레이어가 누군지 표시해주기 위해 */
    func setMainPlayer(isMain: Bool) {
        if isMain {
            contentView.backgroundColor = getColor(hexRGB: MAIN_COLOR, alpha: 0.2)
        }
        else {
            contentView.backgroundColor = getColor(hexRGB: WHITE_COLOR, alpha: 1.0)
        }
    }
    
    /** 탈주 플레이어 표시 */
    func setEscapePlayer() {
        escapeView.isHidden = false
        errorView.isHidden = true
    }

    
    // MARK:- Util
    /** 셀의 닉네임 반환 */
    func getNickname() -> String {
        return nickname
    }
    
    /** 배열속에서 몇등인지 */
    func getRank(array: [MatchesDetailData.player], player: MatchesDetailData.player?) -> Int?{
        return array.firstIndex { (item) -> Bool in
            if item.nickname == player?.nickname {
                return true
            }
            else {
                return false
            }
        }
    }
    
    /** 몇등인지 문자열값 반환 */
    func getRankString(rank: Int) -> String {
        switch rank {
        case 0: return "1st"
        case 1: return "2nd"
        case 2: return "3rd"
        default: return "\(String(rank+1))th"
        }
    }
    
    
    // MARK:- 버튼 클릭 이벤트
    /** 아이템 클릭 이벤트 */
    @IBAction func onClickItem(_ sender: Any) {
        let itemButton = sender as! UIButton
        if let itemId = itemDetailData[String(itemButton.tag)] {
            NeopleApiManager.shared.requestItemData(itemId: itemId, responseCompletion: { (data: ItemData) in
                self.delegate?.showItemPopup(name: data.itemName ?? "", rarity: data.rarityCode ?? "", info: "\(data.characterName ?? "공용")\(data.characterName==nil ? "" : " 전용")\n\(data.slotName ?? "")  \(data.rarityName ?? "")\n\n\n\(data.explain ?? "")")
            }) { (err) in
                SSLog("[API] 아이템 정보 조회 API 실패 : \(String(describing: err.localizedDescription))")
            }
        }
    }
    
    /** 특성 클릭 이벤트 */
    @IBAction func onClickAbility(_ sender: Any) {
        if let attrId1 = attributeDetailData[String(ability1.tag)], let attrId2 = attributeDetailData[String(ability2.tag)], let attrId3 = attributeDetailData[String(ability3.tag)] {
            NeopleApiManager.shared.requestAttributeData(attributeId: attrId1, responseCompletion: { (data1: AttributeData) in
                NeopleApiManager.shared.requestAttributeData(attributeId: attrId2, responseCompletion: { (data2: AttributeData) in
                    NeopleApiManager.shared.requestAttributeData(attributeId: attrId3, responseCompletion: { (data3: AttributeData) in
                        
                        var explainText1 = "[\(data1.attributeName ?? "")] (\(data1.positionName ?? ""))\n\(data1.explain ?? "")"
                        var explainText2 = "[\(data2.attributeName ?? "")] (\(data2.positionName ?? ""))\n\(data2.explain ?? "")"
                        var explainText3 = "[\(data3.attributeName ?? "")] (\(data3.positionName ?? ""))\n\(data3.explain ?? "")"
                        explainText1 = explainText1.replacingOccurrences(of: "\n\n", with: "\n")
                        explainText2 = explainText2.replacingOccurrences(of: "\n\n", with: "\n")
                        explainText3 = explainText3.replacingOccurrences(of: "\n\n", with: "\n")
                        
                        self.delegate?.showItemPopup(name: self.playerData?.position?.name ?? "", rarity: "101", info: "\(explainText1)\n\n\(explainText2)\n\n\(explainText3)")
                        
                    }) { (err) in
                        SSLog("[API] 포지션 특성3 정보 조회 API 실패 : \(String(describing: err.localizedDescription))")
                    }
                }) { (err) in
                    SSLog("[API] 포지션 특성2 정보 조회 API 실패 : \(String(describing: err.localizedDescription))")
                }
            }) { (err) in
                SSLog("[API] 포지션 특성1 정보 조회 API 실패 : \(String(describing: err.localizedDescription))")
            }
        }
    }
}
