//
//  RecordTeamTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 20/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class RecordTeamTableViewCell: UITableViewCell {

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
    func setData(data: [MatchesDetailData.player], isWin: Bool) {
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
            // kda
            var teamKill = 0
            for player in data {
                teamKill = teamKill + (player.playInfo?.killCount ?? 0)
            }
            
            var teamDeath = 0
            for player in data {
                teamDeath = teamDeath + (player.playInfo?.deathCount ?? 0)
            }
            
            var teamAssist = 0
            for player in data {
                teamAssist = teamAssist + (player.playInfo?.assistCount ?? 0)
            }
            
            teamKdaLabel.text = "총 \(String(teamKill))킬 | \(String(teamDeath))데스 | \(String(teamAssist))도움"
        }
    }
}
