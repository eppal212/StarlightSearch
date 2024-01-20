//
//  NeopleAPIManager.swift
//  StarlightSearch
//
//  Created by CUDO on 29/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit
import Alamofire

/** 네트워크 Request, Response 처리 */
class NetworkRequestor: NSObject {
    
    public func requestServer<T: Decodable>(nr_requestor: BaseRequestor, nr_responseCompletion: @escaping (T) -> Void, nr_errorCompletion: @escaping (NetworkError) -> Void) {
        
        let requestor = nr_requestor
        
        var url = requestor.getServerUrl()
        url += requestor.getApiTypeValue()
        let method = requestor.getMethod()
        
        let paramStr = requestor.getParamString()
        if paramStr.count > 0 {
            url += "?\(paramStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? paramStr)"
        }
        
        let nm = NetworkManager()
        SSLog("api 호출 url : \(url)")
        sendAnalytics(type: .API_REQUEST, event: "\(nr_requestor.getApiType())", value: url)
        nm.requestHTTP(url, method: method, headers: nil, success: { (response) in
            //success
            var asdfasdf: Date? = nil
            if (UserInformation.shared.responseDate == nil) {
                let keyString = "Date"
                let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
                if let headerValue = keyValues?.filter({ $0.0 == keyString.lowercased() }).first {
                    let dateString = headerValue.1
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                    UserInformation.shared.responseDate = dateFormatter.date(from: dateString)
                }
            }
            sendAnalytics(type: .API_RESPONSE, event: String(response.response?.statusCode ?? 0), value: url)
            self.onResponse(requestor: requestor, response: response, responseCompletion: nr_responseCompletion, errorCompletion: nr_errorCompletion)
        }) { (response) in
            //failure
            var errorString = ""
            if let value = response.result.value as? [String: Any] {
                if let error = value["error"] as? [String: Any] {
                    let errorStatus = (error["status"] as? Int) ?? 0
                    let errorCode = (error["code"] as? String) ?? ""
                    let errorMessage = (error["message"] as? String) ?? ""
                    errorString = String(errorStatus) + "|" + errorCode + "|" + errorMessage
                }
            }
            sendAnalytics(type: .API_RESPONSE, event: String(response.response?.statusCode ?? 0), value: (url + "#" + errorString))
            let errInfo = NetworkError(msg: response.error?.localizedDescription ?? "", statusCode: response.response?.statusCode ?? 0)
            nr_errorCompletion(errInfo)
        }
    }
    
    private func onResponse<T: Decodable>(requestor: BaseRequestor, response: DataResponse<Any>, responseCompletion: @escaping (T) -> Void, errorCompletion: @escaping (NetworkError) -> Void) {
        
        var checkSuccess = false
        
        if requestor is NeopleRequestor {
            if response.response?.statusCode == 200 {
                checkSuccess = true
            }
        }
        
        var errMsg: String = ""
        if checkSuccess == true {
            if let data = response.data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedData = try jsonDecoder.decode(T.self, from: data)
                    responseCompletion(parsedData)
                    return
                } catch {
                    SSLog("error: \(error.localizedDescription)")
                    errMsg = "DecodingError"
                }
            } else {
                errMsg = "response.data not available"
            }
        }
        errorCompletion(NetworkError(msg: errMsg, statusCode: response.response?.statusCode ?? 0))
    }
    
}
