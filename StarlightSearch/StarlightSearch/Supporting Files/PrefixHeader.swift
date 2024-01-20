//
//  PrefixHeader.swift
//  StarlightSearch
//
//  Created by CUDO on 27/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

public let IS_DEBUG = false // 배포할때 false로
public let HIDE_ADVIEW = false // 배포할때 false로

extension String {
    func split(length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
}
