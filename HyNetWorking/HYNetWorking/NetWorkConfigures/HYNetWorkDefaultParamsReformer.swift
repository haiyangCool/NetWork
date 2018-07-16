//
//  HYNetWorkDefaultParamsReformer.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/9.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/** 配置默认的一些数据
     暂时没有定义拦截器，先使用该方法拼接app需要的固定参数
     1、参数
     2、……
 */
import UIKit

final class HYNetWorkDefaultParamsReformer: NSObject {
    static let shared = HYNetWorkDefaultParamsReformer()
    override init() {
        super.init()
    }
}
/**
 */
extension HYNetWorkDefaultParamsReformer {
    
    /** 添加默认参数*/
    func reformerParams(_ param:[String:Any]?,isJoinDefaultParams join:Bool) -> [String:Any]? {
        if join == false { return param }
        if param == nil {return param}
        var params = param
        params!["platform"] = "ios"
        params!["version"] = "1.1"
        return params
    }
}
