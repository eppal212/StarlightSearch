//
//  SSLog.swift
//  StarlightSearch
//
//  Created by CUDO on 27/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import Foundation
import os.log

public func SSLog(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line)
{
    SSLog(nil, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}

public func SSLog(_ message: String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line)
{
    if IS_DEBUG == false {
        return
    }
    
    let logPrefix = "SSLog"
    let className = (fileName as NSString).lastPathComponent
    
    if #available(iOS 10.0, *) {
        if message == nil {
            os_log("%@",type:.default ,"[\(logPrefix)] <\(className)> \(functionName)")
        }
        else
        {
            os_log("%@",type:.default ,"[\(logPrefix)] <\(className)> \(functionName) [#\(lineNumber)] \(message ?? "")")
        }
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS : "
        print(formatter.string(from: Date()), terminator: "")
        if message == nil {
            print("[\(logPrefix)] <\(className)> \(functionName)")
        }
        else
        {
            print("[\(logPrefix)] <\(className)> \(functionName) [#\(lineNumber)] \(message ?? "")")
        }
    }
    
}
