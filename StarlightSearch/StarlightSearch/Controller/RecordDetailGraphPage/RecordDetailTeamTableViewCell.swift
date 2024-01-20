//
//  RecordDetailTeamTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 30/07/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class RecordDetailTeamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamResultLabel: UILabel!
    @IBOutlet weak var teamKdaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK:- View
    /** 데이터 세팅하여 뷰 그리기 */
    func setData(data: [MatchesDetailData.player], isWin: Bool, type: RecordDetailGraphViewController.GraphType) {
        // 승패
        if isWin {
            teamResultLabel.text = "승리 팀"
            contentView.backgroundColor = getColor(hexRGB: BLUE_COLOR, alpha: 0.7)
        }
        else {
            teamResultLabel.text = "패배 팀"
            contentView.backgroundColor = getColor(hexRGB: RED_COLOR, alpha: 0.7)
        }
        
        if data.count != 0 {
            var value = 0
            switch type {
            case .KILL:
                for player in data {
                    value = value + (player.playInfo?.killCount ?? 0)
                }
                teamKdaLabel.text = "총 \(String(value))킬  평균 \(String(value/data.count))킬"
                break
            case .DEATH:
                for player in data {
                    value = value + (player.playInfo?.deathCount ?? 0)
                }
                teamKdaLabel.text = "총 \(String(value))데스  평균 \(String(value/data.count))데스"
                break
            case .ASSIST:
                for player in data {
                    value = value + (player.playInfo?.assistCount ?? 0)
                }
                teamKdaLabel.text = "총 \(String(value))도움  평균 \(String(value/data.count))도움"
                break
            case .ATTACK:
                for player in data {
                    value = value + (player.playInfo?.attackPoint ?? 0)
                }
                teamKdaLabel.text = "총 공격량 \(parsePoint(point: value))  평균 \(parsePoint(point: value/data.count))"
                break
            case .DAMAGE:
                for player in data {
                    value = value + (player.playInfo?.damagePoint ?? 0)
                }
                teamKdaLabel.text = "총 피해량 \(parsePoint(point: value))  평균 \(parsePoint(point: value/data.count))"
                break
            case .BATTLE:
                for player in data {
                    value = value + (player.playInfo?.battlePoint ?? 0)
                }
                teamKdaLabel.text = "총 전투참여 \(String(value))  평균 \(String(value/data.count))"
                break
            case .SIGHT:
                for player in data {
                    value = value + (player.playInfo?.sightPoint ?? 0)
                }
                teamKdaLabel.text = "총 시야 \(String(value))  평균 \(String(value/data.count))"
                break
            }
        }
    }
}
