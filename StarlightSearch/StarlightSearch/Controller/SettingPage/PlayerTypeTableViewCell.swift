//
//  PlayerTypeTableViewCell.swift
//  StarlightSearch
//
//  Created by CUDO on 13/06/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

/** Cell에서 DownloadListView를 호출하는 Delegate */
protocol CellToSettingViewDelegate: class {
    func closeOtherTap(nowType: PLAYER_TYPE)
    func setScrollEnable(isEnable: Bool, nowType: PLAYER_TYPE)
    func reloadTableView(nowType: PLAYER_TYPE)
    func didEdit(isStart: Bool, nowType: PLAYER_TYPE, nickname: String)
    func deletePlayerType(type: PLAYER_TYPE, nickname: String)
}

class PlayerTypeTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentUpdateButton: UIButton!
    @IBOutlet weak var commentDeleteButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    var delegate: CellToSettingViewDelegate?
    var cellType: PLAYER_TYPE = .LIKE

    
    // MARK:- Basic
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    // MARK:- View
    /** 셀 표시 */
    func setData(data: String, type: PLAYER_TYPE) {
        commentTextField.delegate = self
        
        let array = data.components(separatedBy: "#")
        if array.count > 1 {
            nickNameLabel.text = array[0]
            commentLabel.text = array[1]
        }
        
        cellType = type
    }
    
    /** 셀 편집여부에 따른 버튼 활성화 정리 */
    func setCondition(nowEditingType: PLAYER_TYPE, nowEditingNickname: String) {
        if nowEditingNickname == "-" {
            commentUpdateButton.isEnabled = true
            commentDeleteButton.isEnabled = true
        }
        else {
            if cellType == nowEditingType {
                if nowEditingNickname == nickNameLabel.text {
                    commentUpdateButton.isEnabled = true
                }
                else {
                    commentUpdateButton.isEnabled = false
                }
                commentDeleteButton.isEnabled = false
            }
            else {
                commentUpdateButton.isEnabled = false
                commentDeleteButton.isEnabled = false
            }
        }
    }
    
    
    // MARK:- TextField
    /** 키보드 숨기기 */
    @objc func hideKeyboard() {
        commentTextField.resignFirstResponder()
    }
    
    /** 수정버튼 감지 */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            onClickUpdateButton("")
            return false
        }
        return true
    }
    
    
    // MARK:- 클릭 이벤트
    /** 수정버튼 클릭 이벤트 */
    @IBAction func onClickUpdateButton(_ sender: Any) {
        if commentUpdateButton.tag == 0 {
            // 입력 시작
            commentUpdateButton.tag = 1
            commentUpdateButton.setImage(UIImage(named: "btn_edit_complete"), for: .normal)
            commentLabel.isHidden = true
            commentTextField.isHidden = false
            commentTextField.text = commentLabel.text
            
            delegate?.closeOtherTap(nowType: cellType)
            delegate?.didEdit(isStart: true, nowType: cellType, nickname: nickNameLabel.text ?? "")
            delegate?.setScrollEnable(isEnable: false, nowType: cellType)
            
            commentTextField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.01)
        }
        else if commentUpdateButton.tag == 1{
            // 입력 끝
            commentUpdateButton.tag = 0
            commentUpdateButton.setImage(UIImage(named: "btn_edit_start"), for: .normal)
            commentLabel.isHidden = false
            commentTextField.isHidden = true
            hideKeyboard()
            
            updatePlayerType(type: cellType, playerNickname: nickNameLabel.text ?? "", comment: commentTextField.text ?? "-")
            delegate?.reloadTableView(nowType: cellType)
            
            delegate?.didEdit(isStart: false, nowType: cellType, nickname: nickNameLabel.text ?? "")
            delegate?.setScrollEnable(isEnable: true, nowType: cellType)
        }
    }
    
    /** 삭제버튼 클릭 이벤트 */
    @IBAction func onClickDeleteButton(_ sender: Any) {
        delegate?.deletePlayerType(type: cellType, nickname: nickNameLabel.text ?? "")
    }
}
