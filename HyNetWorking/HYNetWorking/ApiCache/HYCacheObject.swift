//
//  HYCacheObject.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/5.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
     缓存体
 */
import UIKit

class HYCacheObject: NSObject {
    /** 缓存内容*/
    var content:Data?
    /** 缓存更新时间*/
    fileprivate var updateContentTime:Date?
    
    override init() {
        super.init()
    }
}
/**
     缓存体数据设置
 */
extension HYCacheObject {
    
    /** 设置缓存体数据*/
    func initCacheContent(content:Data) -> HYCacheObject {
        
        let cacheObject = HYCacheObject.init()
        cacheObject.content = content
        return cacheObject
        
    }
    /** 更新缓存体数据*/
    func updateCacheContent(content:Data?) {
        
        self.content = content
        self.updateContentTime = Date.init()
    }
    
    /** 缓存是否超时*/
    func isOutDateOfCache() -> Bool {
        
        let timeInterval = Date.init().timeIntervalSince(self.updateContentTime!)
        /// 2 分钟 超时时间
        return timeInterval > HYNetWorkConfiguration.shared.cacheDataTimeOutSecond()
    }
    
    /** 缓存是否为空*/
    func isEmptyOfCache() -> Bool {
        return self.content == nil
    }
    
}
