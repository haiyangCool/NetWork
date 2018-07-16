//
//  HYNetWorkConfiguration.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/8.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
    网络请求的基础配置
    BaseUrl             根路径
    RequestTimeout      请求超时时间
    CacheTimeout        缓存超时时间 （NSCache）
    CacheLimit          缓存数量 （NSCache）
    NetworkReachable    网络是否可达
 
 */
import UIKit
import Alamofire
final class HYNetWorkConfiguration: NSObject {

    static let shared = HYNetWorkConfiguration()
    override init() {
        super.init()
    }
}
/** public methods*/
extension HYNetWorkConfiguration {
    /** app Base api*/
    func apiBaseUrl() -> String {
        return "http://api.bc.pthv.gitv.tv/api/"
    }
    /** 网络请求超时时间*/
    func apiRequestTimeOutSecond() -> TimeInterval {
        return 60
    }
    /** 缓存保存时间-超时时间 2 分钟*/
    func cacheDataTimeOutSecond() -> TimeInterval {
        return 120
    }
    /** 缓存数量*/
    func cacheDataCountLimits() -> Int {
        return 10
    }
    /** 网络可达判断*/
    func isReachable() -> Bool {
        
        if NetworkReachabilityManager.init()?.networkReachabilityStatus == .unknown {
            return true
        }else {
            return (NetworkReachabilityManager.init()?.isReachable)!
        }
    }
}
