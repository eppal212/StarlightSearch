//
//  BaseRequestor.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import Foundation

/** 기본 Request 데이터 객체 */
class BaseRequestor: NSObject {
    private var apiType: API_TYPE
    private var params: [String: Any]?
    private var paramsStr: String?
    
    init(apiType: API_TYPE) {
        self.apiType = apiType
    }
    
    func getServerUrl() -> String {
        return ""
    }
    
    func getApiType() -> API_TYPE {
        return self.apiType
    }
    
    func getApiTypeValue() -> String {
        return self.apiType.rawValue
    }
    
    func getHeaders() -> [String: String] {
        let headers: [String: String] = [
            "": ""
        ]
        
        return headers
    }
    
    public func setParams(params: [String: Any]) {
        self.params = params
        self.paramsStr = nil
    }
    
    public func setParams(params: String) {
        self.paramsStr = params
        self.params = nil
    }
    
    func getMethod() -> NetworkManager.HTTP_METHOD {
        return NetworkManager.HTTP_METHOD.GET
    }
    
    func getParamString() -> String {
        if let params = params {
            return getMapToParamStr(map: params)
        } else if let params = paramsStr {
            return params
        } else {
            return ""
        }
    }
    
    func getParams() -> [String: Any]? {
        return params
    }
    
    func getMapToParamStr(map: [String: Any]) -> String {
        var paramStr = ""
        map.forEach { (key: String, value: Any) in
            print("foreach : \(key) || \(value)")
            if(paramStr.count > 0) { paramStr += "&" }
            paramStr += "\(key)=\(value)"
        }
        return paramStr
    }
}
