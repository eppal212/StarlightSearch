//
//  RecordTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 03/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import Kingfisher

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var kdaLabel: UILabel!
    @IBOutlet weak var damageLabel: UILabel!
    
    var matchId: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /** 전체탭 눌렀을때 셀 표시 */
    func setData(data: AllMatchesData?) {
        if data == nil {
            noDataView.isHidden = false
        }
        else {
            noDataView.isHidden = true
            
            matchId = data?.matchId ?? ""
            
            if data?.playInfo?.result == "win" {
                winLabel.isHidden = false
                loseLabel.isHidden = true
                
                if data?.gameTypeId == "rating" {
                    winLabel.text = "공\n식\n승\n리"
                }
                else if data?.gameTypeId == "normal" {
                    winLabel.text = "일\n반\n승\n리"
                }
                else {
                    winLabel.text = "승\n리"
                }
                
                profileImage.layer.borderColor = getColor(hexRGB: BLUE_COLOR)?.cgColor
            }
            else if data?.playInfo?.result == "lose" {
                winLabel.isHidden = true
                loseLabel.isHidden = false
                
                if data?.gameTypeId == "rating" {
                    loseLabel.text = "공\n식\n패\n배"
                }
                else if data?.gameTypeId == "normal" {
                    loseLabel.text = "일\n반\n패\n배"
                }
                else {
                    loseLabel.text = "패\n배"
                }
                
                profileImage.layer.borderColor = getColor(hexRGB: RED_COLOR)?.cgColor
            }
            
            profileImage.layer.cornerRadius = profileImage.frame.height/2
            profileImage.layer.borderWidth = 2
            profileImage.clipsToBounds = true
            if let characterId = data?.playInfo?.characterId {
                profileImage.kf.setImage(with: URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + characterId)), placeholder: UIImage(named: "img_random"))
            }
            
            var partyPlayer = "솔로"
            if (data?.playInfo?.partyUserCount ?? 1) > 1 {
                partyPlayer = "\(String(data?.playInfo?.partyUserCount ?? 1))인"
            }
            if getModelName() == "iPhoneSE" {
                nicknameLabel.text = "\(data?.playInfo?.characterName ?? "UNKNOWN")"
            }
            else {
                nicknameLabel.text = "\(data?.playInfo?.characterName ?? "UNKNOWN")(\(partyPlayer)\((data?.playInfo?.random ?? false) ? "/랜덤" : ""))" // 캐릭터이름(4인/랜덤)
            }
            
            dateLabel.text = data?.date // '19.05.02 15:14
            
            // 플레이타임 00분 00초
            let playTime = data?.playInfo?.playTime ?? 0
            if playTime == 0 {
                playTimeLabel.text = ""
            }
            else {
                playTimeLabel.text = "\(String(playTime/60))분 \(String(playTime%60))초"
            }
            
            let kill = data?.playInfo?.killCount ?? 0
            let death = data?.playInfo?.deathCount ?? 1
            let assi = data?.playInfo?.assistCount ?? 0
            var kda: Float = 0
            if death == 0 {
                kda = (Float(kill+assi) / 1) * 1.2
            }
            else {
                kda = Float(kill+assi) / Float(death)
            }
            kdaLabel.text = "\(String(kill))킬 \(String(death))데스 \(String(assi))도움  KDA \(String(format: "%.1f", kda))" // 0킬 0데스 0도움  KDA 0.0
            
            damageLabel.text = "공격량 \(parsePoint(point: data?.playInfo?.attackPoint ?? 0))   피해량 \(parsePoint(point: data?.playInfo?.damagePoint ?? 0))" // 공격량 10000   피해량 10000
        }
    }
    
    /** 공식,일반탭 눌렀을때 셀 표시 */
    func setData(data: MatchesData.row?) {
        let matchesData = AllMatchesData.init(date: data?.date, gameTypeId: "", matchId: data?.matchId, playInfo: data?.playInfo)
        setData(data: matchesData)
    }

    /** MatchId 조회 */
    func getMatchId() -> String {
        return matchId
    }
}
