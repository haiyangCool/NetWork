//
//  HYApiLoger.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/5.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
    api 请求日志ß
    收集api请求数据的日志
 */
import UIKit

final class HYApiLoger: NSObject {

    static let shared = HYApiLoger()
    override init() {
        
    }
    
    /** 上报错误的请求日志*/
    func logInfoWithRequest(request:URLRequest?, httpMethod:String?, httpBody:Data?, responseString:String?, responseValue:Any?, error:NSError)  {
        
        let logDetail = HYApiLogConfiguration.init()
        logDetail.appName = ""
        logDetail.appVersion = ""
        logDetail.request = request
        logDetail.HttpMethods = httpMethod
        if httpBody != nil {
            
            logDetail.apiParams = try? JSONSerialization.jsonObject(with: httpBody!, options: JSONSerialization.ReadingOptions.mutableContainers)
        }
        logDetail.responseString = responseString
        logDetail.responseValue = responseValue
        logDetail.requestTime = ""
        logDetail.errorInfo = error.localizedRecoverySuggestion
        
    }
     /** 上报正常操作请求日志- 后台可以通过分析用户经常点击的请求地址类型判断用户喜好*/
    func logInfoWithRequest(request:URLRequest?, httpMethod:String?, httpBody:Data?, responseString:String?, responseValue:Any?)  {
        
        let logDetail = HYApiLogConfiguration.init()
        logDetail.appName = ""
        logDetail.appVersion = ""
        logDetail.request = request
        logDetail.HttpMethods = httpMethod
        if httpBody != nil {
            logDetail.apiParams = try? JSONSerialization.jsonObject(with: httpBody!, options: JSONSerialization.ReadingOptions.mutableContainers)
        }
        logDetail.responseString = responseString
        logDetail.responseValue = responseValue
        logDetail.requestTime = ""
        logDetail.errorInfo = nil
        
    }
}
