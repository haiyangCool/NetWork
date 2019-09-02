//
//  VVCacheManager.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/1.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation

protocol VVCacheProtocol {
    /// Save data 
    /// - Parameter response: response
    /// - Parameter time: cache Time in memory
    /// - Parameter key: cache Key
    mutating func saveData(_ response:VVURLResponse,
                           cacheTime time:TimeInterval,
                           cacheKey key:String)
    /// Fetch the data if memory cached it
    /// - Parameter key: cache Key
    mutating func fetchData(_ key: String) -> VVURLResponse?
    /// clear all memory data
    mutating func cleanAllData()
    /// clear memory data by key
    /// - Parameter key: cache Key
    mutating func cleanDataWith(_ key:String)
}


/// Cache type
public enum VVCacheType {
    
    case memory
    case disk
}
///Cache Manager
struct VVCacheManager {
    
    
    /// Memory cache Manager
    lazy var memoryCacheManager: VVMemoryCacheManager = {
        let memoryCacheManager = VVMemoryCacheManager()
        return memoryCacheManager
    }()
    
    /// Disk cache Manager
    lazy var diskCacheManager: VVDiskCacheManager = {
        let diskCacheManager = VVDiskCacheManager()
        return diskCacheManager
    }()
    
    static let shared = VVCacheManager()
    private init() {}
    mutating func saveData(_ response:VVURLResponse?,
                  serviceIdentifier identifier:String,
                  apiName name:String,
                  parameter params:[String:String?]?,
                  cacheTime time:TimeInterval,
                  cacheType type:VVCacheType) {
        
        if response == nil {
            return
        }
        let key = self.key(identifier, apiName: name, parameter: params)
        if type == .memory {
        
            memoryCacheManager.saveData(response!, cacheTime: time, cacheKey: key)
        }
        
        if type == .disk {
            diskCacheManager.saveData(response!, cacheTime: time, cacheKey: key)
        }
        
    }
    
    mutating func fetchData(serviceIdentifier identifier:String,
                   apiName name:String,
                   parameter params:[String:String?]?,
                   cacheTime time:TimeInterval,
                   cacheType type:VVCacheType) -> VVURLResponse? {
        
        var response:VVURLResponse? = nil
        
        let key = self.key(identifier, apiName: name, parameter: params)
        if type == .memory {
            response =  memoryCacheManager.fetchData(key)
        }
        if type == .disk {
            response = diskCacheManager.fetchData(key)
        }
        
        return response
    }
    
    mutating func cleanAllCache(_ cacheType:VVCacheType) {
        if cacheType == .memory {
            memoryCacheManager.cleanAllData()
        }
        
        if cacheType == .disk {
            diskCacheManager.cleanAllData()
        }
        
    }
}

/// Private methods

extension VVCacheManager {
    
    private func key(_ serviceIdr:String,apiName name:String,parameter params:[String:String?]?) -> String {
        var key = ""
        key = key + serviceIdr + name
        if params == nil || params!.isEmpty {
            return key
        }
        let allKeys = params!.keys
        let sortKeys = allKeys.sorted()
        
        for k in sortKeys {
            if let v:String = params![k] ?? "" {
                key += "\(k)=\(v)"
            }
        }
        print("My Key = \(key)")
        // your should make a MD5
        return key
    }
}
