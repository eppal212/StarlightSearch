//
//  NetworkManager.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import Alamofire

public struct NetworkError: Error {
    public init(msg: String, statusCode: Int) {
        self.msg = msg
        self.statusCode = statusCode
    }
    public static let WILL_RESET = "WILL_RESET"
    public let msg: String
    public let statusCode: Int
}

/** 실질적으로 Request를 수행하는 클래스 (GET/POST) */
class NetworkManager: NSObject {

    let DEFAULT_TIMEOUT: TimeInterval = 10
    
    enum HTTP_METHOD: String{
        case GET     = "GET"
        case POST    = "POST"
        case PUT     = "PUT"
    }
    
    /** GET 방식 API */
    func requestHTTP(_ url: String, method: HTTP_METHOD? = .GET, headers: [String : String]?, success: @escaping (DataResponse<Any>) -> Void, failure: @escaping (DataResponse<Any>) -> Void) {
        
        let alamofire = Alamofire.SessionManager.default
        alamofire.session.configuration.timeoutIntervalForRequest = DEFAULT_TIMEOUT
        alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            #if DEBUG
            debugPrint(response)
            #endif
            
            if response.response?.statusCode == 200 {
                success(response)
            }
            else {
                failure(response)
            }
        }
    }
    
    /** POST, PUT 방식 API */
    func requestHTTP(_ url: String, method: HTTP_METHOD, headers: [String : String]?, bodys: [String : Any]?, success: @escaping (DataResponse<Any>) -> Void, failure:  @escaping (DataResponse<Any>) -> Void) {
        
        var httpMethod : HTTPMethod = .post
        
        if method == .PUT {
            httpMethod = .put
        }
        
        let alamofire = Alamofire.SessionManager.default
        alamofire.session.configuration.timeoutIntervalForRequest = DEFAULT_TIMEOUT
        alamofire.request(url, method: httpMethod, parameters: bodys, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            #if DEBUG
            debugPrint(response)
            #endif
            
            if response.response?.statusCode == 200 {
                success(response)
            }
            else {
                failure(response)
            }
        }
    }
}
