//
//  HYApiLogConfiguration.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/5.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/** 日志上报主体
 */
import UIKit

class HYApiLogConfiguration: NSObject {

    /** App Name*/
    var appName:String?
    /** App Version*/
    var appVersion:String?
    /** URLRequest*/
    var request:URLRequest?
    /** HttpMethod*/
    var HttpMethods:String?
    /** api 参数*/
    var apiParams:Any?
    /** 请求结果*/
    var responseString:String?
    var responseValue:Any?
    /** 发起请求的时间*/
    var requestTime:String?
    /** error Info*/
    var errorInfo:String?
    
    override init() {
        super.init()
    }
}
