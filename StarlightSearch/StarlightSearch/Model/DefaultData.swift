//
//  DefualtData.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

public let AppBundleID = "com.oberis.StarlightSearch"
public let AppStoreUrl = "https://itunes.apple.com/kr/app/id1470035533?mt=8"

public let NeopleApiKey = "B7nSDmnkfjWIjBe62g2ahqSb7oUMVbwL"
public let NeopleApiServer = "https://api.neople.co.kr"

public let AdMobId = "ca-app-pub-1197409946903481~3877134948"
public let AdMobBannerIdTest = "ca-app-pub-3940256099942544/2934735716"
public let AdMobRecordBannerId = "ca-app-pub-1197409946903481/3226398255"
public let AdMobRecordDetailBannerId = "ca-app-pub-1197409946903481/8876655071"
public let AdMobRecordGraphBannerId = "ca-app-pub-1197409946903481/5191790423"
public let AdMobRecordDetailGraphBannerId = "ca-app-pub-1197409946903481/1646508063"

public let RECENT_SEARCH_COUNT = 4
public let BOOKMARK_COUNT = 6

public let MAIN_COLOR = "#15A695"
public let WHITE_COLOR = "#ffffff"
public let BLACK_COLOR = "#000000"
public let RED_COLOR = "#DD2C00"
public let BLUE_COLOR = "#0091EA"
public let UNIQUE_COLOR = "#FF00FF"
public let RARE_COLOR = "#B36BFF"
public let UNCOMMON_COLOR = "#68D5ED"
public let COMMON_COLOR = "#FFFFFF"

public enum API_TYPE: String {
    case PLAYER         = "/cy/players" // 플레이어 검색
    case PLAYER_INFO    = "/cy/players/<playerId>" // 플레이어 정보 조회
    case MATCHES        = "/cy/players/<playerId>/matches" // 플레이어 매칭기록 조회
    case MATCHES_DETAIL = "/cy/matches/<matchId>" // 플레이어 매칭 상세정보 조회
    case ITEM_DATA      = "/cy/battleitems/<itemId>" // 아이템 상세정보 조회
    case ATTRIBUTE_DATA = "/cy/position-attributes/<attributeId>" // 포지션 특성 상세정보 조회
    case CHARACTER_IMAGE = "https://img-api.neople.co.kr/cy/characters/" // 캐릭터 썸네일
    case ITEM_IMAGE     = "https://img-api.neople.co.kr/cy/items/" // 아이템 이미지
    case ATTRIBUTE_IMAGE = "https://img-api.neople.co.kr/cy/position-attributes/" // 특성 이미지
}

public enum DROPBOX_FILE: String {
    case NOTI           = "https://www.dropbox.com/s/3apvadxpytt1bbi/Noti.txt?dl=0&raw=1" // 공지사항
    case DEV_COMMENT    = "https://www.dropbox.com/s/7c9mm6tl3pnnbff/DevComment.txt?dl=0&raw=1" // 개발자 한 마디
    case IMAGE_URL      = "https://www.dropbox.com/s/swbho7z3yo1ri74/ImageUrlMatching.txt?dl=0&raw=1" // 이미지 Url Match 파일
}

public enum PREF_KEY: String {
    case IS_SECOND_START    = "IS_SECOND_START" // 두번째 이상 시작하는지
    case READED_NOTI_VER    = "READED_NOTI_VER" // 다시보지 않기 한 공지사항 버전
    case RECENT_SEARCH      = "RECENT_SEARCH" // 최근검색 닉네임들 (닉네임|닉네임)
    case BOOKMARK           = "BOOKMARK" // 즐겨찾기 플레이어ID들 (플레이어ID|플레이어ID|플레이어ID)
    case LIKE_PLAYER        = "LIKE_PLAYER" // 선호 플레이어 닉네임들 (닉네임|닉네임)
    case HATE_PLAYER        = "HATE_PLAYER" // 블랙리스트 닉네임들 (닉네임|닉네임)
    case USE_RECENT_SEARCH  = "USE_RECENT_SEARCH" // 최근검색 닉네임 저장 여부
    case USER_COMMENT_TIME  = "USER_COMMENT_TIME" // 사용자 한 마디 보낸 시간
}

public enum PLAYER_TYPE: String {
    case LIKE         = "LIKE" // 선호 플레이어
    case HATE         = "HATE" // 블랙리스트
}

public enum ANALYTICS_TYPE: String {
    case CLICK              = "Click" // 클릭
    case SHOW               = "Show" // 표시
    case ERROR              = "Error" // 에러
    case API_REQUEST        = "Api_Request" // 네오플 API
    case API_RESPONSE       = "Api_Response" // 네오플 API
    case USER_COMMENT       = "UserComment" // 유저 한 마디
}

public enum ANALYTICS_EVENT: String {
    // CLICK
    
    // SHOW
    
    // ERROR
    case ERROR_MATCH_RECORD  = "ERROR_MATCH_RECORD"
    case ERROR_RECORD_DETAIL = "ERROR_RECORD_DETAIL"
    
    // API
    case RESPONSE            = "RESPONSE"
    
    // USER_COMMENT
    case USER_COMMENT        = "USER_COMMENT" // 유저 코멘트
}
