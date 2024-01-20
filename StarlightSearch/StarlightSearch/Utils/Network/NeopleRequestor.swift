//
//  NeopleRequestor.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

/** 네오플API 전용 Request 데이터 객체 */
class NeopleRequestor: BaseRequestor {
    private var _playerId: String?
    private var _matchId: String?
    private var _itemId: String?
    private var _attributeId: String?
    
    public override init(apiType: API_TYPE) {
        super.init(apiType: apiType)
    }
    
    public func setPlayerId(playerId: String) {
        _playerId = playerId
    }
    
    public func setMatchId(matchId: String) {
        _matchId = matchId
    }
    
    public func setItemId(itemId: String) {
        _itemId = itemId
    }
    
    public func setAttributeId(attributeId: String) {
        _attributeId = attributeId
    }
    
    public override func getServerUrl() -> String {
        return NeopleApiServer
    }
    
    override func getMethod() -> NetworkManager.HTTP_METHOD {
        switch getApiType() {
        default:
            return NetworkManager.HTTP_METHOD.GET
        }
    }
    
    override func getApiTypeValue() -> String {
        var path = super.getApiTypeValue()
        
        switch super.getApiType() {
        case .PLAYER_INFO, .MATCHES:
            path = path.replacingOccurrences(of: "<playerId>", with: _playerId ?? "")
            break
        case .MATCHES_DETAIL:
            path = path.replacingOccurrences(of: "<matchId>", with: _matchId ?? "")
            break
        case .ITEM_DATA:
            path = path.replacingOccurrences(of: "<itemId>", with: _itemId ?? "")
            break
        case .ATTRIBUTE_DATA:
            path = path.replacingOccurrences(of: "<attributeId>", with: _attributeId ?? "")
            break
        default: break
        }
        
        return path
    }
}
