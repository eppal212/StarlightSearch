//
//  NeopleResponseData.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

// 플레이어 검색
struct PlayerData: Codable {
    
    var rows: [row]?
    
    struct row: Codable {
        var playerId : String?
        var nickname : String?
        var grade : Int?
    }
}

// 플레이어 정보 조회
struct PlayerInfoData: Codable {
    
    var playerId : String?
    var nickname : String?
    var grade : Int?
    var clanName : String?
    var ratingPoint : Int?
    var maxRatingPoint : Int?
    var tierName : String?
    var records: [record]?
    
    struct record: Codable {
        var gameTypeId : String?
        var winCount : Int?
        var loseCount : Int?
        var stopCount : Int?
    }
}

// 매칭기록 조회
public struct MatchesData: Codable {
    
    var playerId : String?
    var nickname : String?
    var grade : Int?
    var clanName : String?
    var ratingPoint : Int?
    var maxRatingPoint : Int?
    var tierName : String?
    var records: [record]?
    var matches: match?
    
    struct record: Codable {
        var gameTypeId : String?
        var winCount : Int?
        var loseCount : Int?
        var stopCount : Int?
    }
    
    struct match: Codable {
        var date : date?
        var gameTypeId : String?
        var next : String?
        var rows : [row]?
    }
    
    struct date: Codable {
        var start : String?
        var end : String?
    }

    struct row: Codable {
        var date : String?
        var matchId : String?
        var playInfo : playInfo?
    }

    struct playInfo: Codable {
        var result : String?
        var random : Bool?
        var partyUserCount : Int?
        var characterId : String?
        var characterName : String?
        var level : Int?
        var killCount : Int?
        var deathCount : Int?
        var assistCount : Int?
        var attackPoint : Int?
        var damagePoint : Int?
        var battlePoint : Int?
        var sightPoint : Int?
        var playTime : Int?
    }
}

// 매칭 상세정보 조회
struct MatchesDetailData: Codable {
    
    var date : String?
    var gameTypeId : String?
    var teams : [team]?
    var players : [player]?
    
    struct team: Codable {
        var result : String?
        var players : [String]?
    }
    
    struct player: Codable {
        var playerId : String?
        var nickname : String?
        var playInfo : playInfo?
        var position : position?
        var items : [item]?
    }
    
    struct playInfo: Codable {
        var random : Bool?
        var partyUserCount : Int?
        var characterId : String?
        var characterName : String?
        var level : Int?
        var killCount : Int?
        var deathCount : Int?
        var assistCount : Int?
        var attackPoint : Int?
        var damagePoint : Int?
        var battlePoint : Int?
        var sightPoint : Int?
        var playTime : Int?
    }
    
    struct position: Codable {
        var name : String?
        var explain : String?
        var attribute : [attribute]?
    }
    
    struct attribute: Codable {
        var level : Int?
        var id : String?
        var name : String?
    }
    
    struct item: Codable {
        var itemId : String?
        var itemName : String?
        var slotCode : String?
        var slotName : String?
        var rarityCode : String?
        var rarityName : String?
        var equipSlotCode : String?
        var equipSlotName : String?
    }
}

// 아이템 상세 정보
struct ItemData: Codable {
    var itemId : String?
    var itemName : String?
    var characterId : String?
    var characterName : String?
    var rarityCode : String?
    var rarityName : String?
    var slotCode : String?
    var slotName : String?
    var seasonCode : String?
    var seasonName : String?
    var explain : String?
    var explainDetail : String?
}

// 특성 상세 정보
struct AttributeData: Codable {
    var attributeId : String?
    var attributeName : String?
    var explain : String?
    var positionName : String?
}
