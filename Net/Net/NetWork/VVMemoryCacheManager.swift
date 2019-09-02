//
//  VVMemoryCacheManager.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/6.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation

/// Memory Cache Manager
struct VVMemoryCacheManager: VVCacheProtocol {
   

    lazy var cache = NSCache<NSString, AnyObject>()
    init() {}
    
    mutating func fetchData(_ key: String) -> VVURLResponse? {
        
        var response:VVURLResponse? = nil
        if let cacheData:MemoryCacheObject = cache.object(forKey: key as NSString) as? MemoryCacheObject {
            
            if !cacheData.isEmpty() || !cacheData.isOutOfTime() {
                response = VVURLResponse.init(with: cacheData.content)
            }else {
                cleanDataWith(key)
            }
        }
        return response
    }
    
    mutating func saveData(_ response: VVURLResponse, cacheTime time: TimeInterval, cacheKey key: String) {
        
        var cacheObj = MemoryCacheObject.init()
        if let data:Data = response.responseData {
            cacheObj.updateContent(data)
        }
//        let cache = NSCache<NSString, AnyObject>()
        cache.setObject(cacheObj as AnyObject, forKey: key as NSString)
       
        
    }
    
    func cleanAllData() {
        let cache = NSCache<NSString, AnyObject>()
        cache.removeAllObjects()
    }
    
    func cleanDataWith(_ key: String) {
        let cache = NSCache<NSString, AnyObject>()
        cache.removeObject(forKey: key as NSString)
    }
    
}


struct MemoryCacheObject {
    
    var content:Data?
    
    /// Cache time
    var cacheTimeInterval:TimeInterval?
    
    /// Data update time
    fileprivate var upDateTime:Date?
    
    init() {
        
    }
    
    mutating func updateContent(_ content:Data) {
        self.content = content
        self.upDateTime = Date()
    }
    
    func isOutOfTime() -> Bool {
        let time = Date().timeIntervalSince(self.upDateTime!)
        return cacheTimeInterval! > time
    }
    
    func isEmpty() -> Bool {
        return self.content == nil
    }
}
