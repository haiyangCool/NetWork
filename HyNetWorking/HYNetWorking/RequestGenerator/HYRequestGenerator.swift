//
//  HYRequestGenerator.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/3.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import UIKit
import Alamofire

/** 请求生成器*/
final class HYRequestGenerator: NSObject {

    static let shared = HYRequestGenerator()
    private override init() {
        
    }
}

/**
     Public methods
 */
extension HYRequestGenerator {
    
    /** 生成GET 请求*/
    func generatorGETRequest(withParams:[String:Any]?, methodName:String) -> URLRequest {
        
        let request = self.generatorRequest(withParams: withParams, methodName: methodName, requestMethod: "GET")
        return request
    }
    
    /** 生成POST 请求*/
    func generatorPOSTRequest(withParams:[String:Any]?, methodName:String) -> URLRequest {
        
        let request = self.generatorRequest(withParams: withParams, methodName: methodName, requestMethod: "POST")
        return request
    }
}

/**
     Private methods
     通过该方法生成相应的请求体 URLRequest
     /** Post 请求参数放到 httpBody中
         get 请求的参数拼接 则拿到 各自的manager 中进行拼接
         
     */
 */
extension HYRequestGenerator {
    
    fileprivate func generatorRequest(withParams:[String:Any]?, methodName:String, requestMethod:String) -> URLRequest {
        
        var url = URL.init(string: methodName)
        if requestMethod == "GET" {
            let getJoin = HYNetWorkGetRequestUrlAndParamsJoin.shared
            let joinUrl = getJoin.joinUrlAndParams(url: methodName, params: withParams)
            url = URL.init(string: joinUrl)
        }
        var urlRequest:URLRequest = NSMutableURLRequest.init(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: HYNetWorkConfiguration.shared.apiRequestTimeOutSecond()) as URLRequest
        urlRequest.httpMethod = requestMethod
        if requestMethod == "POST" {
            if withParams != nil {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: withParams!, options: JSONSerialization.WritingOptions.prettyPrinted)
            }
        }
        print("发起数据请求的完整-url= \(urlRequest)")
        return urlRequest

    }
}
