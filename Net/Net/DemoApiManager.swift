//
//  DemoApiManager.swift
//  NetWork
//
//  Created by 王海洋 on 2018/8/9.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit

class DemoApiManager: VVBaseApiManager {

    override init() {
        super.init()
        delegate = self
        validator = self
        service = DemoService.init()
        
        cachePolicy = .memoryCache
    }
}


extension DemoApiManager: VVAPIManagerDelegate {
    func requestType() -> VVAPIManagerRequestType {
        return .GET
    }
    
    func apiAddress() -> String {
        return "c/top/list.json"
    }
    
    func serviceIdentifier() -> String {
        return "DemoService"
    }
    
    func methodDescribe() -> String {
        return "public/videolist"
    }

}

extension DemoApiManager: VVAPIManagerValidator {
    func validatorParamIsCorrect(_ manager: VVBaseApiManager, params: [String : String?]?) -> VVAPIManagerErrorType {
        return .noError
    }
    
    func validatorResponseIsCorrect(_ manager: VVBaseApiManager, response: Dictionary<String, Any>?) -> VVAPIManagerErrorType {
//        print("validator response = \(response)")
        return .noError
    }
    
    
    
}
