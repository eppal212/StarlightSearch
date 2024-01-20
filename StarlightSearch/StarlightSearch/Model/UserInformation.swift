//
//  UserInformation.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class UserInformation: NSObject {
    
    static let shared = UserInformation()
    
    var imageUrlDict: [String:String] = [String:String]()
    var responseDate: Date? = nil
    
    /** UUID 반환 */
    func getUUID() -> String {
        let UUID_KEY = "UUID"
        
        var uuid = getStringData(key: UUID_KEY) ?? ""
        
        if uuid == "" {
            uuid = UUID().uuidString
            setStringData(val: uuid, key: UUID_KEY)
        }
        
        return uuid
    }
}
