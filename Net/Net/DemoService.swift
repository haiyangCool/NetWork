//
//  DemoService.swift
//  NetWork
//
//  Created by 王海洋 on 2019/8/9.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit

class DemoService: NSObject {

    override init() {
        super.init()
    }
}

/// Service
extension DemoService: VVAPIManagerService {
    
    
    /// 开发
    func apiEnvironment() -> VVAPIManagerEnvironment {
        return .develop
    }
    
    func serviceAddress() -> String {
        
        if apiEnvironment() == .develop {
            return "http://expand.video.iqiyi.com/"
        }
        if apiEnvironment() == .release {
            return "http://expand.video.iqiyi.com/"
        }
        return "http://expand.video.iqiyi.com/"
    }
    
    
    /// 服务不处理返回的错误，继续向业务层传递
    /// - Parameter manager: manager
    /// - Parameter type: error type
    func isHandleApiError(_ manager: VVBaseApiManager, errorType type: VVAPIManagerErrorType) -> Bool {
        if type == .accessTokenTimeout || type == .needLogin{
            // 需要重新登录 发通知
//            NotificationCenter.default.post(<#T##notification: Notification##Notification#>)
            return true
        }
        return false
    }
    
    

}
