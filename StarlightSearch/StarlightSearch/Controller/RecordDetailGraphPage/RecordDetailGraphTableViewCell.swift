//
//  RecordDetailGraphTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 12/07/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class RecordDetailGraphTableViewCell: UITableViewCell {

    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var leadingBar: UIView!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet var barWidth: NSLayoutConstraint!
    
    @IBOutlet weak var errorView: UIView!
    
    var playerData: MatchesDetailData.player?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /** 캐릭터별 기록 */
    func setData(winTeam: [MatchesDetailData.player], loseTeam: [MatchesDetailData.player], index: Int, type: RecordDetailGraphViewController.GraphType, playerNickname: String) {
        
        if winTeam.count == 0 || loseTeam.count == 0 {
            errorView.isHidden = false
        }
        else {
            errorView.isHidden = true
            
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
                characterImage.layer.cornerRadius = characterImage.frame.height/2
                characterImage.layer.borderWidth = 1.5
                characterImage.layer.borderColor = isWin ? getColor(hexRGB: BLUE_COLOR)?.cgColor : getColor(hexRGB: RED_COLOR)?.cgColor
                characterImage.clipsToBounds = true
                if let url = URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + (playerData?.playInfo?.characterId ?? ""))) {
                    characterImage.kf.setImage(with: url, placeholder: UIImage(named: "img_random"))
                }
                leadingBar.backgroundColor = isWin ? getColor(hexRGB: BLUE_COLOR) : getColor(hexRGB: RED_COLOR)
                
                characterName.text = "\(playerData?.nickname ?? "")(\(playerData?.playInfo?.characterName ?? ""))"
                
                var valuePoint: Int = 0
                var maxValuePoint: Int = 1
                switch type {
                case .KILL:
                    valuePoint = playerData?.playInfo?.killCount ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.killCount ?? 0) < (player2.playInfo?.killCount ?? 0)
                    })?.playInfo?.killCount ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.killCount ?? 0) < (player2.playInfo?.killCount ?? 0)
                    })?.playInfo?.killCount ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = String(valuePoint)
                    break
                case .DEATH:
                    valuePoint = playerData?.playInfo?.deathCount ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.deathCount ?? 0) < (player2.playInfo?.deathCount ?? 0)
                    })?.playInfo?.deathCount ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.deathCount ?? 0) < (player2.playInfo?.deathCount ?? 0)
                    })?.playInfo?.deathCount ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = String(valuePoint)
                    break
                case .ASSIST:
                    valuePoint = playerData?.playInfo?.assistCount ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.assistCount ?? 0) < (player2.playInfo?.assistCount ?? 0)
                    })?.playInfo?.assistCount ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.assistCount ?? 0) < (player2.playInfo?.assistCount ?? 0)
                    })?.playInfo?.assistCount ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = String(valuePoint)
                    break
                case .ATTACK:
                    valuePoint = playerData?.playInfo?.attackPoint ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.attackPoint ?? 0) < (player2.playInfo?.attackPoint ?? 0)
                    })?.playInfo?.attackPoint ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.attackPoint ?? 0) < (player2.playInfo?.attackPoint ?? 0)
                    })?.playInfo?.attackPoint ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = parsePoint(point: valuePoint)
                    break
                case .DAMAGE:
                    valuePoint = playerData?.playInfo?.damagePoint ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.damagePoint ?? 0) < (player2.playInfo?.damagePoint ?? 0)
                    })?.playInfo?.damagePoint ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.damagePoint ?? 0) < (player2.playInfo?.damagePoint ?? 0)
                    })?.playInfo?.damagePoint ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = parsePoint(point: valuePoint)
                    break
                case .BATTLE:
                    valuePoint = playerData?.playInfo?.battlePoint ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.battlePoint ?? 0) < (player2.playInfo?.battlePoint ?? 0)
                    })?.playInfo?.battlePoint ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.battlePoint ?? 0) < (player2.playInfo?.battlePoint ?? 0)
                    })?.playInfo?.battlePoint ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = parsePoint(point: valuePoint)
                    break
                case .SIGHT:
                    valuePoint = playerData?.playInfo?.sightPoint ?? 0
                    let winMax = winTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.sightPoint ?? 0) < (player2.playInfo?.sightPoint ?? 0)
                    })?.playInfo?.sightPoint ?? 1
                    let loseMax = loseTeam.max(by: { (player1, player2) -> Bool in
                        return (player1.playInfo?.sightPoint ?? 0) < (player2.playInfo?.sightPoint ?? 0)
                    })?.playInfo?.sightPoint ?? 1
                    maxValuePoint = winMax >= loseMax ? winMax : loseMax
                    value.text = parsePoint(point: valuePoint)
                    break
                }
                value.isHidden = true
                
                barWidth.constant = 0
                barView.backgroundColor = isWin ? getColor(hexRGB: BLUE_COLOR) : getColor(hexRGB: RED_COLOR)
                
                self.layoutIfNeeded()
                UIView.animate(withDuration: 1.25, animations: {
                    let maxWidth = self.graphView.bounds.width
                    self.barWidth.constant = maxWidth * CGFloat(Float(valuePoint)/(maxValuePoint==0 ? 1 : Float(maxValuePoint)*1.2))
                    self.layoutIfNeeded()
                }) { (flag) in
                    if flag {
                        self.value.isHidden = false
                    }
                }
            }
            
            if (playerData?.nickname ?? "") == playerNickname {
                contentView.backgroundColor = getColor(hexRGB: MAIN_COLOR, alpha: 0.2)
            }
            else {
                contentView.backgroundColor = getColor(hexRGB: WHITE_COLOR, alpha: 1.0)
            }
        }
    }
    
    /** 플레이어 정보가 안 내려왔을때 보여주는 내용 */
    func setEscapePlayer() {
        errorView.isHidden = false
    }
}
