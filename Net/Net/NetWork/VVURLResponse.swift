//
//  VVURLResponse.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/1.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation

/// Response , Only  decode response from Service,  Do not deal error
/// The correct of response , be deal at APIManager
public enum VVURLResponseState {
    
    case success
    case requestTimeOut    // time out
    case requestCancel     // request be canceled
    case netException      // others exception be as net error
}

struct VVURLResponse {

    var state:VVURLResponseState?
    var err:Error?
    var isCache:Bool?
    var url:String?
    var requestType:String?
    var params:Dictionary<String,Any>?
    
    var responseStr:String?
    var responseContent:Dictionary<String,Any>?
    var responseData:Data?
    var logStr:String?
    
    
    init() {
        print("vvResponse")
    }
    
    init(with responsesString:String,urlRequest request:URLRequest,error: Error?) {
         print("vvResponse init String")
        responseStr = responsesString
        err = error
        isCache = false

        if let urlAddress:URL = request.url {
            url = urlAddress.absoluteString
        }
        if let type:String = request.httpMethod {
            requestType = type
        }
    
        if let body:Data = request.httpBody {
            params =  try? JSONSerialization.jsonObject(with: body, options: .allowFragments) as? Dictionary<String, Any>
        }
        
        if let data = responseStr?.data(using: .utf8) {
            responseData = data
            responseContent =  try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any>
        }
        
        state = responseState(error: err)
        
        logStr = generatorLogStr()
       
    }
    
    init(with data:Data?) {
         print("vvResponse init Data")
        if data != nil && !data!.isEmpty {
            state = .success
            err = nil
            isCache = true
            url = nil
            params = nil
            requestType = nil
            responseData = data
            responseStr = String.init(data: data!, encoding: .utf8)
            responseContent = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Dictionary<String, Any>
        }
        logStr = generatorLogStr()
    }
    
}

extension VVURLResponse {
    
    /// Error status
    /// - Parameter error: error
    fileprivate func responseState(error: Error?) -> VVURLResponseState {
        if error == nil {
            return .success
        }
        if let urlError:URLError = error as? URLError {
            if urlError.code == URLError.timedOut {
                return .requestTimeOut
            }
            if urlError.code == URLError.cancelled {
                return .requestCancel
            }
        }
        return .netException
    }
    
    fileprivate func generatorLogStr() -> String {
        
        var log = "Response:\n"
        
        log += "\t\t\t    state: \(String(describing: state))\n"
        log += "\t\t\t      url: \(String(describing: url))\n"
        log += "\t\t\t    param: \(String(describing: params))\n"
        log += "\t\t\t     type: \(String(describing: requestType))\n"
        log += "\t\t\t  isCache: \(String(describing: isCache))\n"
        log += "\t\t\t response: \(responseStr ?? "noData")"
        
        return log
    
    }
}
