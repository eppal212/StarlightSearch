//
//  NeopleApiManager.swift
//  StarlightSearch
//
//  Created by CUDO on 30/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class NeopleApiManager: NSObject {
    
    static let shared = NeopleApiManager()

    // MARK:- 사이퍼즈
    /** 플레이어 검색 */
    func requestPlayer<T: Decodable>(nickname: String, responseCompletion: @escaping (T) -> Void, errorCompletion: @escaping (NetworkError) -> Void) {
        // 플레이어 검색 서버통신
        let playerReqestor = NeopleRequestor(apiType: .PLAYER)
        let playerParams = [
            "nickname": nickname,
            "apikey": NeopleApiKey
        ]
        playerReqestor.setParams(params: playerParams)
        
        let nRequestor = NetworkRequestor()
        nRequestor.requestServer(nr_requestor: playerReqestor, nr_responseCompletion: responseCompletion, nr_errorCompletion: errorCompletion)
    }
    
    /** 플레이어 정보 조회 */
    func requestPlayerInfo<T: Decodable>(playerId: String, responseCompletion: @escaping (T) -> Void, errorCompletion: @escaping (NetworkError) -> Void) {
        // 플레이어 검색 서버통신
        let playerInfoReqestor = NeopleRequestor(apiType: .PLAYER_INFO)
        let playerInfoParams = [
            "apikey": NeopleApiKey
        ]
        playerInfoReqestor.setParams(params: playerInfoParams)
        playerInfoReqestor.setPlayerId(playerId: playerId)
        
        let nRequestor = NetworkRequestor()
        nRequestor.requestServer(nr_requestor: playerInfoReqestor, nr_responseCompletion: responseCompletion, nr_errorCompletion: errorCompletion)
    }
    
    /** 플레이어 매칭기록 조회 */
    func requestMatches<T: Decodable>(playerId: String,
                                      gameTypeId: String,
                                      responseCompletion: @escaping (T) -> Void,
                                      errorCompletion: @escaping (NetworkError) -> Void) {
        // 플레이어 매칭기록 서버통신
        let playerInfoReqestor = NeopleRequestor(apiType: .MATCHES)
        
        // 전적조회 기준이 되는 시간이 문제가 되어, 서버에서 받은 response 시간값을 참조하여 수정
        var endDate = getTodayDate(dateFormat: "yyyyMMddTHHmm")
        if let responseDate = UserInformation.shared.responseDate {
            endDate = getKoreanDate(date: responseDate, dateFormat: "yyyyMMddTHHmm")
        }
        
        let playerInfoParams = [
            "gameTypeId": gameTypeId,
            "startDate": getBefore90DaysDate(dateFormat: "yyyyMMddTHHmm") ?? "",
            "endDate": endDate,
            "limit": 100,
            "apikey": NeopleApiKey
            ] as [String : Any]
        playerInfoReqestor.setParams(params: playerInfoParams)
        playerInfoReqestor.setPlayerId(playerId: playerId)
        
        let nRequestor = NetworkRequestor()
        nRequestor.requestServer(nr_requestor: playerInfoReqestor, nr_responseCompletion: responseCompletion, nr_errorCompletion: errorCompletion)
    }
    
    /** 플레이어 매칭 상세정보 조회 */
    func requestMatchesDetail<T: Decodable>(matchId: String, responseCompletion: @escaping (T) -> Void, errorCompletion: @escaping (NetworkError) -> Void) {
        // 플레이어 매칭 상세정보 서버통신
        let playerInfoReqestor = NeopleRequestor(apiType: .MATCHES_DETAIL)
        
        let playerInfoParams = [
            "apikey": NeopleApiKey
            ]
        playerInfoReqestor.setParams(params: playerInfoParams)
        playerInfoReqestor.setMatchId(matchId: matchId)
        
        let nRequestor = NetworkRequestor()
        nRequestor.requestServer(nr_requestor: playerInfoReqestor, nr_responseCompletion: responseCompletion, nr_errorCompletion: errorCompletion)
    }
    
    /** 아이템 상세정보 조회 */
    func requestItemData<T: Decodable>(itemId: String, responseCompletion: @escaping (T) -> Void, errorCompletion: @escaping (NetworkError) -> Void) {
        // 플레이어 매칭 상세정보 서버통신
        let playerInfoReqestor = NeopleRequestor(apiType: .ITEM_DATA)
        
        let playerInfoParams = [
            "apikey": NeopleApiKey
        ]
        playerInfoReqestor.setParams(params: playerInfoParams)
        playerInfoReqestor.setItemId(itemId: itemId)
        
        let nRequestor = NetworkRequestor()
        nRequestor.requestServer(nr_requestor: playerInfoReqestor, nr_responseCompletion: responseCompletion, nr_errorCompletion: errorCompletion)
    }
    
    /** 포지션 특성 상세정보 조회 */
    func requestAttributeData<T: Decodable>(attributeId: String, responseCompletion: @escaping (T) -> Void, errorCompletion: @escaping (NetworkError) -> Void) {
        // 플레이어 매칭 상세정보 서버통신
        let playerInfoReqestor = NeopleRequestor(apiType: .ATTRIBUTE_DATA)
        
        let playerInfoParams = [
            "apikey": NeopleApiKey
        ]
        playerInfoReqestor.setParams(params: playerInfoParams)
        playerInfoReqestor.setAttributeId(attributeId: attributeId)
        
        let nRequestor = NetworkRequestor()
        nRequestor.requestServer(nr_requestor: playerInfoReqestor, nr_responseCompletion: responseCompletion, nr_errorCompletion: errorCompletion)
    }
}
