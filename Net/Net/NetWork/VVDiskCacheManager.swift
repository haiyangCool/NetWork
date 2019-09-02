//
//  VVDiskCacheMemory.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/6.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
let VVDiskCachePreFix = "VVDiskCachePreFix"

let VVDiskCacheData = "VVDiskCacheData"
let VVDiskCacheTime = "VVDiskCacheTime"
let VVDiskCacheUpDateTime = "VVDiskCacheUpDateTime"

struct VVDiskCacheManager: VVCacheProtocol{
    
    init() {}
    
    func saveData(_ response: VVURLResponse, cacheTime time: TimeInterval, cacheKey key: String) {
        
        let cacheKey = VVDiskCachePreFix + key
        
        // if code run there , response can not be nil
        let data = try? JSONSerialization.data(withJSONObject:
            [
            VVDiskCacheData:response.responseContent!,
            VVDiskCacheTime:NSNumber.init(value: time),
            VVDiskCacheUpDateTime:Date.init().timeIntervalSince1970
            ],
                                               options: .prettyPrinted)
        
        let userDefault = UserDefaults.standard
        userDefault.setValue(data, forKey: cacheKey)
        userDefault.synchronize()
    }
    
    func fetchData(_ key: String) -> VVURLResponse? {
        var response:VVURLResponse? = nil
        let cacheKey = VVDiskCachePreFix + key

        
        let userDefault = UserDefaults.standard
        if let cacheData:Data = userDefault.value(forKey: cacheKey) as? Data, let dataInfo:[String : Any] = try? JSONSerialization.jsonObject(with: cacheData, options: .mutableContainers) as? [String : Any] {
            
            let data = try? JSONSerialization.data(withJSONObject: dataInfo[VVDiskCacheData]!, options: .prettyPrinted)
            
            
            if let updateTimeinterval:TimeInterval = dataInfo[VVDiskCacheUpDateTime] as? TimeInterval,let cacheTime:TimeInterval = dataInfo[VVDiskCacheTime] as? TimeInterval {
                let upDate = Date.init(timeIntervalSince1970: updateTimeinterval)
                let outTime = Date().timeIntervalSince(upDate)
                if outTime < cacheTime {
                    response = VVURLResponse.init(with: data)
                }else {
                    cleanDataWith(key)
                }
                
            }
        }
        
        return response
        
    }
    
    func cleanAllData() {
        let userDefault = UserDefaults.standard
        let allCacheKeyList = userDefault.dictionaryRepresentation()
        
        let keys = allCacheKeyList.keys.filter { $0.contains(VVDiskCachePreFix)
        }
        for key in keys {
            userDefault.removeObject(forKey: key)
        }
        userDefault.synchronize()
        
    }
    
    func cleanDataWith(_ key: String) {
        let cacheKey = VVDiskCachePreFix + key
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: cacheKey)
        userDefault.synchronize()

    }

}
