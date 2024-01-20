//
//  RecordGraphItemTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 07/07/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import Kingfisher

class RecordGraphItemTableViewCell: UITableViewCell {

    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet var barWidth: NSLayoutConstraint!
    
    var maxWidth: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        maxWidth = graphView.bounds.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    /** 캐릭터별 승률 */
    func setWinAveData(datas: [RecordGraphCharacterData], index: Int) {
        characterImage.layer.cornerRadius = characterImage.frame.height/2
        characterImage.layer.borderWidth = 1.5
        characterImage.layer.borderColor = getColor(hexRGB: MAIN_COLOR)?.cgColor
        characterImage.clipsToBounds = true
        if let url = URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + (datas[index].characterId ?? ""))) {
            characterImage.kf.setImage(with: url, placeholder: UIImage(named: "img_random"))
        }
        
        characterName.text = datas[index].characterName ?? ""
        
        let winAve = Float(datas[index].winCount ?? 0) / Float(datas[index].playCount ?? 1) * 100
        value.text = "\(String(format: "%.1f", winAve))%"
        value.isHidden = true
        barWidth.constant = 0
        
        self.layoutIfNeeded()
        barWidth.constant = 0
        UIView.animate(withDuration: 1.25, animations: {
            let maxWidth = self.graphView.bounds.width
            self.barWidth.constant = maxWidth * CGFloat(winAve/(100*1.2))
            self.layoutIfNeeded()
        }) { (flag) in
            if flag {
                self.value.isHidden = false
            }
        }
    }
    
    /** 캐릭터별 기록 */
    func setBattleRecordData(datas: [RecordGraphCharacterData], index: Int, type: RecordGraphBattlePointType) {

        let dataArray = datas.sorted { (item1, item2) -> Bool in
            switch type {
            case .ATTACK:
                if Float(item1.attackPoint ?? 0)/Float(item1.playCount ?? 1) < Float(item2.attackPoint ?? 0)/Float(item2.playCount ?? 1) {
                    return false
                } else {
                    return true
                }
            case .DAMAGE:
                if Float(item1.damagePoint ?? 0)/Float(item1.playCount ?? 1) < Float(item2.damagePoint ?? 0)/Float(item2.playCount ?? 1) {
                    return false
                } else {
                    return true
                }
            case .BATTLE:
                if Float(item1.battlePoint ?? 0)/Float(item1.playCount ?? 1) < Float(item2.battlePoint ?? 0)/Float(item2.playCount ?? 1) {
                    return false
                } else {
                    return true
                }
            case .SIGHT:
                if Float(item1.sightPoint ?? 0)/Float(item1.playCount ?? 1) < Float(item2.sightPoint ?? 0)/Float(item2.playCount ?? 1) {
                    return false
                } else {
                    return true
                }
            }

        }

        characterImage.layer.cornerRadius = characterImage.frame.height/2
        characterImage.layer.borderWidth = 1.5
        characterImage.layer.borderColor = getColor(hexRGB: MAIN_COLOR)?.cgColor
        characterImage.clipsToBounds = true
        if let url = URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + (dataArray[index].characterId ?? ""))) {
            characterImage.kf.setImage(with: url, placeholder: UIImage(named: "img_random"))
        }

        characterName.text = dataArray[index].characterName ?? ""

        var valuePoint: Float = 0
        var maxValuePoint: Float = 1
        switch type {
        case .ATTACK:
            valuePoint = Float(dataArray[index].attackPoint ?? 0) / Float(dataArray[index].playCount ?? 1)
            if dataArray.count > 0 {
                maxValuePoint = Float(dataArray[0].attackPoint ?? 0) / Float(dataArray[0].playCount ?? 1)
            }
            value.text = parsePoint(point: Int(valuePoint))
            break
        case .DAMAGE:
            valuePoint = Float(dataArray[index].damagePoint ?? 0) / Float(dataArray[index].playCount ?? 1)
            if dataArray.count > 0 {
                maxValuePoint = Float(dataArray[0].damagePoint ?? 0) / Float(dataArray[0].playCount ?? 1)
            }
            value.text = parsePoint(point: Int(valuePoint))
            break
        case .BATTLE:
            valuePoint = Float(dataArray[index].battlePoint ?? 0) / Float(dataArray[index].playCount ?? 1)
            if dataArray.count > 0 {
                maxValuePoint = Float(dataArray[0].battlePoint ?? 0) / Float(dataArray[0].playCount ?? 1)
            }
            value.text = String(Int(valuePoint))
            break
        case .SIGHT:
            valuePoint = Float(dataArray[index].sightPoint ?? 0) / Float(dataArray[index].playCount ?? 1)
            if dataArray.count > 0 {
                maxValuePoint = Float(dataArray[0].sightPoint ?? 0) / Float(dataArray[0].playCount ?? 1)
            }
            value.text = String(Int(valuePoint))
            break
        }
        value.isHidden = true
        barWidth.constant = 0
        
        self.layoutIfNeeded()
        barWidth.constant = 0
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
    
    /** 캐릭터별 kda */
    func setKdaData(datas: [RecordGraphCharacterData], index: Int) {
        characterImage.layer.cornerRadius = characterImage.frame.height/2
        characterImage.layer.borderWidth = 1.5
        characterImage.layer.borderColor = getColor(hexRGB: MAIN_COLOR)?.cgColor
        characterImage.clipsToBounds = true
        if let url = URL(string: (API_TYPE.CHARACTER_IMAGE.rawValue + (datas[index].characterId ?? ""))) {
            characterImage.kf.setImage(with: url, placeholder: UIImage(named: "img_random"))
        }

        characterName.text = datas[index].characterName ?? ""

        let kill = round(Float(datas[index].killCount ?? 0) / Float(datas[index].playCount ?? 1))
        let death = round(Float(datas[index].deathCount ?? 0) / Float(datas[index].playCount ?? 1))
        let assist = round(Float(datas[index].assistCount ?? 0) / Float(datas[index].playCount ?? 1))
        var kda: Float = 0
        if death == 0 {
            kda = ((Float(kill) + Float(assist)) / Float(1)) * 1.2
        }
        else {
            kda = (Float(kill) + Float(assist)) / Float(death)
        }
        value.text = "\(String(format: "%.1f", kda))"
        value.isHidden = true
        barWidth.constant = 0

        var maxValue: Float = 1
        if datas.count > 0 {
            let killValue = round(Float(datas[0].killCount ?? 0) / Float(datas[0].playCount ?? 1))
            let deathValue = round(Float(datas[0].deathCount ?? 0) / Float(datas[0].playCount ?? 1))
            let assistValue = round(Float(datas[0].assistCount ?? 0) / Float(datas[0].playCount ?? 1))
            if death == 0 {
                maxValue = ((Float(killValue) + Float(assistValue)) / Float(1)) * 1.2
            }
            else {
                maxValue = (Float(killValue) + Float(assistValue)) / Float(deathValue)
            }
        }
        
        self.layoutIfNeeded()
        barWidth.constant = 0
        UIView.animate(withDuration: 1.25, animations: {
            let maxWidth = self.graphView.bounds.width
            self.barWidth.constant = maxWidth * CGFloat(kda/(maxValue==0 ? 1 : maxValue*1.2))
            self.layoutIfNeeded()
        }) { (flag) in
            if flag {
                self.value.isHidden = false
            }
        }
    }
}
