//
//  HYURLResponse.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/2.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import UIKit
/** 作为接收Api 返回数据的直接接受者，只考虑是否接收到服务器返回的数据，不考虑数据是否为空（可用或不可用）的情况，
    该逻辑由ApiBaseManager进行判断*/
public enum HYURLResponseStatus:String {
    
    /** 1、只考虑数据成功返回（不做具体数据是否正确判断）
        2、请求超时
        3、网络错误问题 （除了请求超时外，其他的状态全部当做网络错误进行处理）
        4、被访问的URL不被支持 
     */
    case HYURLResponseStatus_SUCCESS,
         HYURLResponseStatus_RequestTimeOut,
         HYURLResponseStatus_NetNotReachable,
         HYURLResponseStatus_URLErrorUnsupportedURL
    
}

class HYURLResponse: NSObject {

    /** 数据返回状态-通过error信息判断默认 为Success*/
    var status:HYURLResponseStatus?
    /** 数据内容 -（string）中间格式 -》content 或者是自定义的一些返回字符串*/
    var contentString:String?
    /** 数据内容 - 通用 JSON 需要自己转化 */
    var content:Any?
    /** 相应数据*/
    var responseData:Data?
    /** 请求ID*/
    var requestId:NSNumber?
    /** 错误*/
    var error:NSError?
    /** 是否是缓存*/
    var isCache:Bool?
    
    override init() {
        super.init()
    }
    /** 请求数据成功*/
    func initWith(responseString:String, requestId:NSNumber, responseData:Data, status:HYURLResponseStatus) -> HYURLResponse {
        
        self.contentString = responseString
        if !responseData.isEmpty {
            self.content = try? JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
        }
        self.requestId = requestId
        self.isCache = false
        self.error = nil
        self.status  = status
        self.responseData = responseData
        return self
    }
    /** 请求数据错误*/
    func initWith(responseString:String?, requestId:NSNumber, responseData:Data?, error:NSError) -> HYURLResponse {
        
        self.contentString = ""
        self.status = self.statusOfResponseError(error: error)
        self.requestId = requestId
        self.responseData = responseData
        self.isCache = false
        self.error = error
        if !(responseData?.isEmpty)! {
            self.content = try? JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions.mutableContainers)

        }else {
            self.content = nil
        }
        return self
    }
    /** 缓存得到的数据直接初始化*/
    func initWithData(data:Data) -> HYURLResponse{
        self.contentString = ""
        self.status = self.statusOfResponseError(error: nil)
        self.requestId = 0
        self.responseData = data
        self.isCache = true
        self.content = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
    
        return self
    }
}

/**
     Private methods
 */
extension HYURLResponse {
    
    /** 网络请求的错误除了超时和Url错误以外，全部都当做网络错误处理*/
    func statusOfResponseError(error:NSError?) -> HYURLResponseStatus {
      
        if error != nil {
            var status = HYURLResponseStatus.HYURLResponseStatus_NetNotReachable
            if error?.code == NSURLErrorTimedOut {
                status = HYURLResponseStatus.HYURLResponseStatus_RequestTimeOut
            }
            if error?.code == NSURLErrorUnsupportedURL {
                status = HYURLResponseStatus.HYURLResponseStatus_URLErrorUnsupportedURL
            }
            print("错误 = \(error?.code)")
            return status
        }else {
            return HYURLResponseStatus.HYURLResponseStatus_SUCCESS
        }
    }
}

