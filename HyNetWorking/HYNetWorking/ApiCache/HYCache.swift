//
//  HYCache.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/5.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
     缓存 - NSCache app重启时自动清理所有缓存数据
     业务相关性不强的数据，使用了UserDefault进行持久化 - 已实现
     强业务相关的数据 使用FMDB进行数据库存储 - 需根据需求自行实现 （并不是所有的APP都会用到数据库存储）
     1、requestIdentifier 请求方式 GET、POST
     2、methodName api名字
     3、params 参数
     通过 1、2、3 生成缓存的Key
 */
import UIKit

final class HYCache: NSObject {
    
    static let shared = HYCache()
    private override init() {
        
    }
    lazy var cache: NSCache = { () -> NSCache<AnyObject, AnyObject> in
        
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = HYNetWorkConfiguration.shared.cacheDataCountLimits()
        return cache
    }()
}
/** 缓存存取清理*/
extension HYCache {
    
    /** 清理所有缓存*/
    func cleanCache() {
        self.cache.removeAllObjects()
    }
    
    /** 查询缓存数据*/
    func fetchCacheDataWith(requestIdentifier:String, methodName:String, params:[String:Any]?) -> Data? {
        
        return  self.fetchCacheData(key: self.generatorKeyBy(requestIdentifier: requestIdentifier, methodName: methodName, params: params))
    }
    /** 缓存数据*/
    func saveCacheDataWith(cacheData:Data, requestIdentifier:String, methodName:String, params:[String:Any]?) {
        
        self.saveCacheData(cacheData: cacheData, key: self.generatorKeyBy(requestIdentifier: requestIdentifier, methodName: methodName, params: params))
    }
    
    /** 删除缓存*/
    func deleteCacheDataWith(requestIdentifier:String, methodName:String, params:[String:Any]?) {
     
        self.removeCacheWith(key: self.generatorKeyBy(requestIdentifier: requestIdentifier, methodName: methodName, params: params))
    }
}

/** private methods*/
extension HYCache {
    
    /** 查询缓存*/
    fileprivate func fetchCacheData(key:NSString) -> Data? {
        
        let cacheObj:HYCacheObject? = self.cache.object(forKey: key) as? HYCacheObject
        if cacheObj == nil {
            return nil
        }
        if (cacheObj?.isOutDateOfCache())! || (cacheObj?.isEmptyOfCache())! {
            return nil
        }
        return cacheObj?.content
    }
    
    /** 记录缓存-如果有该缓存则刷新缓存*/
    fileprivate func saveCacheData(cacheData:Data, key:NSString) {
        
        var cacheDataObj:HYCacheObject? = self.cache.object(forKey: key) as? HYCacheObject
        if cacheDataObj == nil {
            cacheDataObj = HYCacheObject.init()
        }
        cacheDataObj?.updateCacheContent(content: cacheData)
        self.cache.setObject(cacheDataObj as AnyObject, forKey: key)
        
    }
    
    /** 清除指定缓存*/
    fileprivate func removeCacheWith(key:NSString ) {
        self.cache.removeObject(forKey: key)
    }
    
    /** 生成cache的Key-*/
    fileprivate func generatorKeyBy(requestIdentifier:String, methodName:String, params:[String:Any]?) -> NSString {
        
        let key = requestIdentifier + methodName
        if params != nil {
            let paramData = try? JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
            let paramsString = String.init(data: paramData!, encoding: String.Encoding.utf8)
            let pKey = key + paramsString!
            return pKey as NSString
        }
        return key as NSString
    }
}
