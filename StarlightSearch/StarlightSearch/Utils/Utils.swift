//
//  Utils.swift
//  StarlightSearch
//
//  Created by CUDO on 30/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

class Utils: NSObject {

}

// MARK:- 업데이트 체크
public func needkUpdate(newVersion: String) -> Bool {
    if let dictionary = Bundle.main.infoDictionary {
        if let nowVersion = dictionary["CFBundleShortVersionString"] as? String {
            if nowVersion.compare(newVersion).rawValue == -1 {
                return true
            }
        }
    }
    return false
}

// MARK:- 그림그리기
public func getColor(hexRGB: String?, alpha : CGFloat = 1.0) -> UIColor? {
    
    guard let rgb = hexRGB, let val = Int(rgb.replacingOccurrences(of: "#", with: ""), radix: 16) else {
        return nil
    }
    
    return UIColor.init(red: CGFloat((val >> 16) & 0xff) / 255.0, green: CGFloat((val >> 8) & 0xff) / 255.0, blue: CGFloat((val >> 0) & 0xff) / 255.0, alpha: alpha)
}

// MARK:- 날짜
/** 오늘 날짜 */
public func getTodayDate(dateFormat : String) -> String
{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    
    if dateFormat == "yyyyMMddTHHmm" {
        dateFormatter.dateFormat = "yyyyMMdd"
        let yyyyMMdd = dateFormatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.calendar = Calendar(identifier: .gregorian)
        timeFormatter.dateFormat = "HHmm"
        let HHmm = timeFormatter.string(from: date)
        
        let timeString = yyyyMMdd + "T" + HHmm
        
        return timeString
    }
    else {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}

/** 파라미터로 받은 날짜를 한국식으로 계산 */
public func getKoreanDate(date: Date, dateFormat : String) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    
    if dateFormat == "yyyyMMddTHHmm" {
        dateFormatter.dateFormat = "yyyyMMdd"
        let yyyyMMdd = dateFormatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.calendar = Calendar(identifier: .gregorian)
        timeFormatter.dateFormat = "HHmm"
        let HHmm = timeFormatter.string(from: date)
        
        let timeString = yyyyMMdd + "T" + HHmm
        
        return timeString
    }
    else {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}

/** 90일 전의 날짜 */
public func getBefore90DaysDate(dateFormat : String) -> String?
{
    let date = Date()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    
    let dateCompnents = DateComponents(day: -90)
    if let calcedDate = calendar.date(byAdding: dateCompnents, to: date)
    {
        if dateFormat == "yyyyMMddTHHmm" {
            dateFormatter.dateFormat = "yyyyMMdd"
            let yyyyMMdd = dateFormatter.string(from: calcedDate)
            
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "ko_KR")
            timeFormatter.calendar = Calendar(identifier: .gregorian)
            timeFormatter.dateFormat = "HHmm"
            let HHmm = timeFormatter.string(from: calcedDate)
            
            return yyyyMMdd + "T" + HHmm
        }
        else {
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.string(from: calcedDate)
        }
    }
    return nil
}

func getNowDate(completionHandler: @escaping (Date) -> Void){
    
    if let url = URL(string: "http://www.google.com") {
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if let contentType = httpResponse.allHeaderFields["Date"] as? String {
                    
                    let dFormatter = DateFormatter()
                    dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                    if let serverTime = dFormatter.date(from: contentType) {
                        completionHandler(serverTime)
                    }
                }
            }
        })
        
        task.resume()
    }
}

// MARK:- 통계
/** 통계 보내기 */
public func sendAnalytics(type: ANALYTICS_TYPE, event: String, value: String) {
    switch type {
    case .API_REQUEST, .API_RESPONSE, .USER_COMMENT:
        var param = ["event": event, "uuid": UserInformation.shared.getUUID()]
        let valueStrings = value.split(length: 100)
        for i in 0 ..< valueStrings.count {
            let key = "value\(String(i))"
            param[key] = valueStrings[i]
        }
        Analytics.logEvent(type.rawValue, parameters: param)
        break
    default:
        Analytics.logEvent(type.rawValue, parameters: [
            "event": event,
            "value": value,
            "uuid": UserInformation.shared.getUUID()
            ])
        break
    }
    
}


// MARK:- 드롭박스 통신
/** 드롭박스 서버 텍스트 파일 읽어오기 */
public func requestDropBoxTextFile(type: DROPBOX_FILE, completion: @escaping (String)->Void) {
    let urlString = type.rawValue
    
    let alamofire = Alamofire.SessionManager.default
    alamofire.session.configuration.timeoutIntervalForRequest = 10
    alamofire.request(urlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
        #if DEBUG
        debugPrint(response)
        #endif
        
        if response.response?.statusCode == 200 {
            if response.data != nil {
                if let textFile = String(data: response.data!, encoding: .utf8) {
                    SSLog("[드롭박스] 파일 읽어오기 성공 : \(textFile)")
                    return completion(textFile)
                }
            }
            else {
                SSLog("[드롭박스] 파일 읽어오기 실패 : \(type)")
            }
        }
        else {
            SSLog("[드롭박스] 파일 읽어오기 실패 : \(type)")
        }
    }
}


// MARK:- Preference 읽기/쓰기
/** 데이터 쓰기 */
public func setObjectData(val : Any, key : String)
{
    UserDefaults.standard.set(val, forKey: key)
}
public func setBoolData(val : Bool, key : String)
{
    UserDefaults.standard.set(val, forKey: key)
}
public func setStringData(val : String, key : String)
{
    UserDefaults.standard.set(val, forKey: key)
}
public func setIntData(val : Int, key : String)
{
    UserDefaults.standard.set(val, forKey: key)
}
public func setFloatData(val : CGFloat, key : String)
{
    UserDefaults.standard.set(val, forKey: key)
}

/** 데이터 읽기 */
public func getObjectData(key : String) -> Any?
{
    return UserDefaults.standard.object(forKey: key)
}
public func getBoolData(key : String) -> Bool?
{
    return UserDefaults.standard.bool(forKey: key)
}
public func getStringData(key : String) -> String?
{
    return UserDefaults.standard.string(forKey:key)
}
public func getIntData(key : String) -> Int
{
    return UserDefaults.standard.integer(forKey: key)
}
public func getFloatData(key : String) -> CGFloat
{
    return CGFloat(UserDefaults.standard.float(forKey: key))
}


// MARK:- 최근 검색 닉네임
/** 최근검색 닉네임 추가 */
public func addRecentSearchData(nickname: String) {
    var nicknameString = ""
    if let dataString = getStringData(key: PREF_KEY.RECENT_SEARCH.rawValue){
        nicknameString = dataString
    }
    
    var stringArray = nicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    if stringArray.contains(nickname) {
        return
    }
    
    if stringArray.count > (RECENT_SEARCH_COUNT-1) {
        stringArray.remove(at: 0)
    }
    stringArray.append(nickname)
    
    var newString = ""
    for string in stringArray {
        if string != "" {
            newString = newString + "|"
        }
        newString = newString + string
    }
    setStringData(val: newString, key: PREF_KEY.RECENT_SEARCH.rawValue)
}


// MARK:- 북마크
/** 북마크 목록 얻어옴 */
public func getBookmark() -> [[String]] {
    var bookmarkString = ""
    if let dataString = getStringData(key: PREF_KEY.BOOKMARK.rawValue) {
        bookmarkString = dataString
    }
    
    var stringArray = bookmarkString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    var returnValue = [[String]]()
    for string in stringArray {
        let nickAndGrade = string.components(separatedBy: "#")
        if nickAndGrade.count > 1 {
            returnValue.append(nickAndGrade)
        }
    }
    
    return returnValue
}

/** 북마크 추가 */
public func addBookmark(playerNickname: String, grade: String) -> Bool {
    var playerNicknameString = ""
    if let dataString = getStringData(key: PREF_KEY.BOOKMARK.rawValue){
        playerNicknameString = dataString
    }
    
    var stringArray = playerNicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    let value = playerNickname + "#" + grade
    if stringArray.contains(value) {
        return true
    }
    
    if stringArray.count > (BOOKMARK_COUNT-1) {
        return false
    }
    else {
        stringArray.append(value)
        
        var newString = ""
        for string in stringArray {
            if newString != "" {
                newString = newString + "|"
            }
            newString = newString + string
        }
        setStringData(val: newString, key: PREF_KEY.BOOKMARK.rawValue)
        return true
    }
}

/** 북마크 제거 */
public func removeBookmark(playerNickname: String) {
    if playerNickname == "" {
        return
    }
    
    var playerNicknameString = ""
    if let dataString = getStringData(key: PREF_KEY.BOOKMARK.rawValue){
        playerNicknameString = dataString
    }
    
    var stringArray = playerNicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    for string in stringArray {
        if string.hasPrefix(playerNickname + "#") {
            stringArray.remove(at: stringArray.firstIndex(of: string)!)
        }
    }
    
    if stringArray.count > 0 {
        var newString = ""
        for string in stringArray {
            if newString != "" {
                newString = newString + "|"
            }
            newString = newString + string
        }
        setStringData(val: newString, key: PREF_KEY.BOOKMARK.rawValue)
    }
    else {
        setStringData(val: "", key: PREF_KEY.BOOKMARK.rawValue)
    }
}

/** 북마크에 해당 플레이어가 추가되어있는지 조회 */
public func containsBookmark(playerNickname: String) -> Bool {
    if playerNickname == "" {
        return false
    }
    
    if let dataString = getStringData(key: PREF_KEY.BOOKMARK.rawValue){
        var stringArray = dataString.components(separatedBy: "|")
        if stringArray.contains("") {
            stringArray.remove(at: stringArray.firstIndex(of: "")!)
        }
        for string in stringArray {
            if string.hasPrefix(playerNickname + "#") {
                return true
            }
        }
    }
    return false
}

/** 북마크 급수 업데이트 */
public func updateBookmark(playerNickname: String, grade: String) {
    var playerNicknameString = ""
    if let dataString = getStringData(key: PREF_KEY.BOOKMARK.rawValue){
        playerNicknameString = dataString
    }
    
    var stringArray = playerNicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    for string in stringArray {
        if string.hasPrefix(playerNickname + "#") {
            if let index = stringArray.firstIndex(of: string) {
                stringArray[index] = playerNickname + "#" + grade
                
                var newString = ""
                for string in stringArray {
                    if newString != "" {
                        newString = newString + "|"
                    }
                    newString = newString + string
                }
                setStringData(val: newString, key: PREF_KEY.BOOKMARK.rawValue)
                
                break
            }
        }
    }
}



// MARK:- 선호플레이어 / 블랙리스트
public func getPlayerType(type: PLAYER_TYPE) -> [String] {
    var playerString = ""
    switch type {
    case .LIKE:
        playerString = getStringData(key: PREF_KEY.LIKE_PLAYER.rawValue) ?? ""
        break
    case .HATE:
        playerString = getStringData(key: PREF_KEY.HATE_PLAYER.rawValue) ?? ""
        break
    }
    
    var stringArray = playerString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    return stringArray
}

/** 선호,블랙 플레이어 추가 */
public func addPlayerType(type: PLAYER_TYPE, playerNickname: String, comment: String) {
    var playerNicknameString = ""
    var key = ""
    switch type {
    case .LIKE:
        key = PREF_KEY.LIKE_PLAYER.rawValue
        break
    case .HATE:
        key = PREF_KEY.HATE_PLAYER.rawValue
        break
    }
    if let dataString = getStringData(key: key){
        playerNicknameString = dataString
    }
    
    var stringArray = playerNicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    stringArray.append(playerNickname + "#" + comment)
    
    var newString = ""
    for i in 1 ... stringArray.count {
        if i != 1 {
            newString = newString + "|"
        }
        newString = newString + stringArray[i-1]
    }
    setStringData(val: newString, key: key)
}

/** 선호,블랙 플레이어 코멘트 추가 */
public func updatePlayerType(type: PLAYER_TYPE, playerNickname: String, comment: String) {
    var playerNicknameString = ""
    var key = ""
    switch type {
    case .LIKE:
        key = PREF_KEY.LIKE_PLAYER.rawValue
        break
    case .HATE:
        key = PREF_KEY.HATE_PLAYER.rawValue
        break
    }
    if let dataString = getStringData(key: key){
        playerNicknameString = dataString
    }
    
    var stringArray = playerNicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    
    for string in stringArray {
        if string.hasPrefix(playerNickname + "#") {
            let newData = playerNickname + "#" + comment
            if let index = stringArray.firstIndex(of: string) {
                stringArray[index] = newData
            }
        }
    }
    
    var newString = ""
    for i in 1 ... stringArray.count {
        if i != 1 {
            newString = newString + "|"
        }
        newString = newString + stringArray[i-1]
    }
    setStringData(val: newString, key: key)
}

/** 선호,블랙 플레이어 제거 */
public func removePlayerType(type: PLAYER_TYPE, playerNickname: String) {
    if playerNickname == "" {
        return
    }
    
    var playerNicknameString = ""
    var key = ""
    switch type {
    case .LIKE:
        key = PREF_KEY.LIKE_PLAYER.rawValue
        break
    case .HATE:
        key = PREF_KEY.HATE_PLAYER.rawValue
        break
    }
    if let dataString = getStringData(key: key){
        playerNicknameString = dataString
    }
    
    var stringArray = playerNicknameString.components(separatedBy: "|")
    if stringArray.contains("") {
        stringArray.remove(at: stringArray.firstIndex(of: "")!)
    }
    for string in stringArray {
        if string.hasPrefix(playerNickname + "#") {
            if let index = stringArray.firstIndex(of: string) {
                stringArray.remove(at: index)
            }
        }
    }
    
    if stringArray.count > 0 {
        var newString = ""
        for i in 1 ... stringArray.count {
            if i != 1 {
                newString = newString + "|"
            }
            newString = newString + stringArray[i-1]
        }
        setStringData(val: newString, key: key)
    }
    else {
        setStringData(val: "", key: key)
    }
}

/** 선호,블랙 플레이어에 추가되어있는지 조회 */
public func containsPlayerType(type: PLAYER_TYPE, playerNickname: String) -> Bool {
    if playerNickname == "" {
        return false
    }
    
    var key = ""
    switch type {
    case .LIKE:
        key = PREF_KEY.LIKE_PLAYER.rawValue
        break
    case .HATE:
        key = PREF_KEY.HATE_PLAYER.rawValue
        break
    }
    if let dataString = getStringData(key: key){
        let playserIdString = dataString
        
        var stringArray = playserIdString.components(separatedBy: "|")
        if stringArray.contains("") {
            stringArray.remove(at: stringArray.firstIndex(of: "")!)
        }
        for string in stringArray {
            if string.hasPrefix(playerNickname + "#") {
                return true
            }
        }
    }
    return false
}


// MARK:- 경기결과
/** 모스트 캐릭터 추림 */
public func getMostCharacter(data: [MatchesData]) -> MostCharacterData? {
    var playedCharacters: [MostCharacterData] = [MostCharacterData].init()
    
    for i in 0 ..< data.count {
        for j in 0 ..< (data[i].matches?.rows?.count ?? 0) {
            if let matcheData = data[i].matches?.rows?[j].playInfo {
                
                let isContain = playedCharacters.contains(where: { (containsCharacterData) -> Bool in
                    return containsCharacterData.characterId == matcheData.characterId
                })
                if isContain {
                    let index = playedCharacters.firstIndex { (containsCharacterData) -> Bool in
                        return containsCharacterData.characterId == matcheData.characterId
                    }
                    
                    if (index ?? playedCharacters.count) < playedCharacters.count {
                        playedCharacters[index!].winCount = (playedCharacters[index!].winCount ?? 0) + (matcheData.result == "win" ? 1 : 0)
                        playedCharacters[index!].loseCount = (playedCharacters[index!].loseCount ?? 0) + (matcheData.result != "win" ? 1 : 0)
                        playedCharacters[index!].killCount = (playedCharacters[index!].killCount ?? 0) + (matcheData.killCount ?? 0)
                        playedCharacters[index!].deathCount = (playedCharacters[index!].deathCount ?? 0) + (matcheData.deathCount ?? 0)
                        playedCharacters[index!].assistCount = (playedCharacters[index!].assistCount ?? 0) + (matcheData.assistCount ?? 0)
                        playedCharacters[index!].attackPoint = (playedCharacters[index!].attackPoint ?? 0) + (matcheData.attackPoint ?? 0)
                        playedCharacters[index!].damagePoint = (playedCharacters[index!].damagePoint ?? 0) + (matcheData.damagePoint ?? 0)
                        playedCharacters[index!].playCount = (playedCharacters[index!].playCount ?? 0) + 1
                    }
                }
                else {
                    let newCharacterData = MostCharacterData.init(characterId: matcheData.characterId, characterName: matcheData.characterName, winCount: matcheData.result == "win" ? 1 : 0, loseCount: matcheData.result != "win" ? 1 : 0, killCount: matcheData.killCount, deathCount: matcheData.deathCount, assistCount: matcheData.assistCount, attackPoint: matcheData.attackPoint, damagePoint: matcheData.damagePoint, playCount: 1)
                    playedCharacters.append(newCharacterData)
                }
            }
        }
    }
    
    playedCharacters.sort { (item1, item2) -> Bool in
        if (item1.playCount ?? 0) < (item2.playCount ?? 0) {
            return false
        }
        else {
            return true
        }
    }
    
    if playedCharacters.count > 0 {
        return playedCharacters[0]
    }
    else {
        return nil
    }
}

/** 전적내역 그래프용 캐릭터 데이터 파싱 */
public func getRecordGraphCharacter(datas: [MatchesData]) -> [RecordGraphCharacterData] {
    var playedCharacters: [RecordGraphCharacterData] = [RecordGraphCharacterData].init()
    
    for data in datas {
        for match in data.matches?.rows ?? [] {
            if let matchData = match.playInfo {
                
                let isContain = playedCharacters.contains(where: { (containsCharacterData) -> Bool in
                    return containsCharacterData.characterId == matchData.characterId
                })
                if isContain {
                    // 목록에 이미 있는 캐릭터면 데이터 더해줌
                    let index = playedCharacters.firstIndex { (containsCharacterData) -> Bool in
                        return containsCharacterData.characterId == matchData.characterId
                    }
                    
                    if (index ?? playedCharacters.count) < playedCharacters.count {
                        playedCharacters[index!].winCount = (playedCharacters[index!].winCount ?? 0) + (matchData.result == "win" ? 1 : 0)
                        playedCharacters[index!].loseCount = (playedCharacters[index!].loseCount ?? 0) + (matchData.result != "win" ? 1 : 0)
                        playedCharacters[index!].killCount = (playedCharacters[index!].killCount ?? 0) + (matchData.killCount ?? 0)
                        playedCharacters[index!].deathCount = (playedCharacters[index!].deathCount ?? 0) + (matchData.deathCount ?? 0)
                        playedCharacters[index!].assistCount = (playedCharacters[index!].assistCount ?? 0) + (matchData.assistCount ?? 0)
                        playedCharacters[index!].attackPoint = (playedCharacters[index!].attackPoint ?? 0) + (matchData.attackPoint ?? 0)
                        playedCharacters[index!].damagePoint = (playedCharacters[index!].damagePoint ?? 0) + (matchData.damagePoint ?? 0)
                        playedCharacters[index!].battlePoint = (playedCharacters[index!].battlePoint ?? 0) + (matchData.battlePoint ?? 0)
                        playedCharacters[index!].sightPoint = (playedCharacters[index!].sightPoint ?? 0) + (matchData.sightPoint ?? 0)
                        playedCharacters[index!].playCount = (playedCharacters[index!].playCount ?? 0) + 1
                    }
                }
                else {
                    // 목록에 없는 캐릭터면 새로 추가
                    let newCharacterData = RecordGraphCharacterData.init(characterId: matchData.characterId, characterName: matchData.characterName, winCount: matchData.result == "win" ? 1 : 0, loseCount: matchData.result != "win" ? 1 : 0, killCount: matchData.killCount, deathCount: matchData.deathCount, assistCount: matchData.assistCount, attackPoint: matchData.attackPoint, damagePoint: matchData.damagePoint, battlePoint: matchData.battlePoint, sightPoint: matchData.sightPoint, playCount: 1)
                    playedCharacters.append(newCharacterData)
                }
            }
        }
    }
    
    playedCharacters.sort { (item1, item2) -> Bool in
        if (item1.playCount ?? 0) < (item2.playCount ?? 0) {
            return false
        }
        else {
            return true
        }
    }
    
    return playedCharacters
}

// MARK:- 단말체크
public func getModelName() -> String {
    //https://support.hockeyapp.net/kb/client-integration-ios-mac-os-x-tvos/ios-device-types
    //https://www.theiphonewiki.com/wiki/Models
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let systemName = machineMirror.children.reduce("") { systemName, element in
        guard let value = element.value as? Int8, value != 0 else { return systemName }
        return systemName + String(UnicodeScalar(UInt8(value)))
    }
    var modelName = "iPhone"
    
    switch systemName {
    //iPhone
    case "iPhone1,1": modelName = "iPhone"; break
    case "iPhone1,2": modelName = "iPhone3G"; break
    case "iPhone2,1": modelName = "iPhone3GS"; break
    case "iPhone3,1": modelName = "iPhone4"; break // (GSM)
    case "iPhone3,2": modelName = "iPhone4"; break
    case "iPhone3,3": modelName = "iPhone4"; break // (CDMA)
    case "iPhone4,1": modelName = "iPhone4S"; break
    case "iPhone5,1": modelName = "iPhone5"; break // (A1428)
    case "iPhone5,2": modelName = "iPhone5"; break // (A1429)
    case "iPhone5,3": modelName = "iPhone5c"; break // (A1456/A1532)
    case "iPhone5,4": modelName = "iPhone5c"; break // (A1507/A1516/A1529)
    case "iPhone6,1": modelName = "iPhone5s"; break // (A1433/A1453)
    case "iPhone6,2": modelName = "iPhone5s"; break // (A1457/A1518/A1530)
    case "iPhone7,1": modelName = "iPhone6Plus"; break
    case "iPhone7,2": modelName = "iPhone6"; break
    case "iPhone8,1": modelName = "iPhone6s"; break
    case "iPhone8,2": modelName = "iPhone6sPlus"; break
    case "iPhone8,4": modelName = "iPhoneSE"; break
    case "iPhone9,1": modelName = "iPhone7"; break // (A1660/A1779/A1780)
    case "iPhone9,2": modelName = "iPhone7Plus"; break // (A1661/A1785/A1786)
    case "iPhone9,3": modelName = "iPhone7"; break // (A1778)
    case "iPhone9,4": modelName = "iPhone7Plus"; break // (A1784)
        
    case "iPhone10,1": modelName = "iPhone8"; break // (A1863/A1906/A1907)
    case "iPhone10,2": modelName = "iPhone8Plus"; break // (A1864/A1898/A1899)
    case "iPhone10,3": modelName = "iPhoneX"; break // (A1865/A1902)
    case "iPhone10,4": modelName = "iPhone8"; break // (A1905)
    case "iPhone10,5": modelName = "iPhone8Plus"; break // (A1897)
    case "iPhone10,6": modelName = "iPhoneX"; break // (A1901)
        
    case "iPhone11,2": modelName = "iPhoneXS"; break // (A1920/A2097/A2098/A2100)
    case "iPhone11,4": modelName = "iPhoneXSMax"; break // (A2104)
    case "iPhone11,6": modelName = "iPhoneXSMax"; break // (A1921/A2101/A2102)
    case "iPhone11,8": modelName = "iPhoneXR"; break // (A1984/A2105/A2106/A2108)
        
    //iPad
    case "iPad1,1": modelName = "iPad"; break
    case "iPad2,1": modelName = "iPad2"; break // (Wi-Fi)
    case "iPad2,2": modelName = "iPad2"; break // (GSM)
    case "iPad2,3": modelName = "iPad2"; break // (CDMA)
    case "iPad2,4": modelName = "iPad2"; break // (Wi-Fi, revised)
    case "iPad2,5": modelName = "iPadMini"; break // (Wi-Fi)
    case "iPad2,6": modelName = "iPadMini"; break // (A1454)
    case "iPad2,7": modelName = "iPadMini"; break // (A1455)
    case "iPad3,1": modelName = "iPad3"; break // (3rd gen, Wi-Fi)
    case "iPad3,2": modelName = "iPad3"; break // (3rd gen, Wi-Fi+LTE Verizon)
    case "iPad3,3": modelName = "iPad3"; break // (3rd gen, Wi-Fi+LTE AT&T)
    case "iPad3,4": modelName = "iPad4"; break // (4th gen, Wi-Fi)
    case "iPad3,5": modelName = "iPad4"; break // (4th gen, A1459)
    case "iPad3,6": modelName = "iPad4"; break // (4th gen, A1460)
    case "iPad4,1": modelName = "iPadAir"; break // (Wi-Fi)
    case "iPad4,2": modelName = "iPadAir"; break // (Wi-Fi+LTE)
    case "iPad4,3": modelName = "iPadAir"; break // (Rev)
    case "iPad4,4": modelName = "iPadMini2"; break // (Wi-Fi)
    case "iPad4,5": modelName = "iPadMini2"; break // (Wi-Fi+LTE)
    case "iPad4,6": modelName = "iPadMini2"; break // (Rev)
    case "iPad4,7": modelName = "iPadMini3"; break // (Wi-Fi)
    case "iPad4,8": modelName = "iPadMini3"; break // (A1600)
    case "iPad4,9": modelName = "iPadMini3"; break // (A1601)
    case "iPad5,1": modelName = "iPadMini4"; break // (Wi-Fi)
    case "iPad5,2": modelName = "iPadMini4"; break // (Wi-Fi+LTE)
    case "iPad5,3": modelName = "iPadAir2"; break // (Wi-Fi)
    case "iPad5,4": modelName = "iPadAir2"; break // (Wi-Fi+LTE)
    case "iPad6,3": modelName = "iPadPro"; break // (9.7 inch) (Wi-Fi)
    case "iPad6,4": modelName = "iPadPro"; break // (9.7 inch) (Wi-Fi+LTE)
    case "iPad6,7": modelName = "iPadPro"; break // (12.9 inch, Wi-Fi)
    case "iPad6,8": modelName = "iPadPro"; break // (12.9 inch, Wi-Fi+LTE)
    case "iPad6,11": modelName = "iPad5"; break // (5th gen, A1822)
    case "iPad6,12": modelName = "iPad5"; break // (5th gen, A1823)
        
    //iPod
    case "iPod1,1": modelName = "iPodTouch"; break
    case "iPod2,1": modelName = "iPodTouch"; break // (2nd gen)
    case "iPod3,1": modelName = "iPodTouch"; break // (3rd gen)
    case "iPod4,1": modelName = "iPodTouch"; break // (4th gen)
    case "iPod5,1": modelName = "iPodTouch"; break // (5th gen)
    //    case "iPod6,1": modelName = "iPodTouch"; break // (5th gen)
    case "iPod7,1": modelName = "iPodTouch"; break // (6th gen)
    default: break
    }
    
    return modelName
}

// MARK:- ETC
/** 수치를 0.0k로 변환 */
public func parsePoint(point: Int) -> String {
    if point < 1000 {
        return String(point)
    }
    else {
        return String(format: "%.1fk", Float(point)/1000)
    }
}

/** Json은 String으로 변환 */
public func jsonToString(json: Data) -> String? {
    do {
        let object = try JSONSerialization.jsonObject(with: json, options: [])
        let data =  try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
        let convertedString = String(data: data, encoding: String.Encoding.utf8) // the data will be converted to the string
        return convertedString
        
    } catch let error {
        SSLog("JSON -> String 파싱 에러 : \(error)")
        return nil
    }
}
