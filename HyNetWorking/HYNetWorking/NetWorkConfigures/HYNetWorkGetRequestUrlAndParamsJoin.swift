//
//  HYNetWorkGetRequestUrlAndParamsJoin.swift
//  HyNetWorking
//
//  Created by hyw on 2018/1/9.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
     Get 请求需要拼接URL和参数
     url + ?key1=xx&key2=xx
 */
import UIKit

final class HYNetWorkGetRequestUrlAndParamsJoin: NSObject {

    static let shared = HYNetWorkGetRequestUrlAndParamsJoin()
    override init() {
        super.init()
    }
}

extension HYNetWorkGetRequestUrlAndParamsJoin {
    
    func joinUrlAndParams(url:String, params:[String:Any]?) -> String {
        
        if params == nil || (params?.isEmpty)! { return url }
        var paramStr = ""
        for (key,value) in params! {
            paramStr.append("\(key)=\(value)&")
        }
        paramStr.removeLast()
        return url + "?\(paramStr)"
    }
}
