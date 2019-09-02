//
//  VVNetWorkDefines.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/1.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit


/** Request Type
    GET
    POST
 */
public enum VVAPIManagerRequestType: String {
    case GET
    case POST
}

/** EnvironMent
    Develop
    Release
 */
public enum VVAPIManagerEnvironment: String {
    case develop
    case release
}

/** Cache Strategy
    Memory
    Disk
    None
 */
public enum VVAPIManagerCachePolicy {
    
    case memoryCache
    case diskCache
    case none
}

/** Some Error Type
 */
public enum VVAPIManagerErrorType: String {
    
    case `default` = "No Request"
    case needLogin = "Need Login"
    case accessTokenTimeout = "Token TimeOut"
    case netCanNotReach = "Net Not Reachable"
    case paramNotCorrect = "Parameter Not Correct"
    case resultNotCorrect = "Response Not Correct"
    case requestTimeout = "Request TimeOut"
    case requestCancel = "Request Canceled"
    case netException = "Net Exception"
    case noError = "No Error"
}

/********Net Work Protocol*****/

/** Child must implement this Protocol
    Note:  Child APIManager  Do not  need override any method of father`s
 */
protocol VVAPIManagerDelegate: NSObjectProtocol {
    
    /// request type
    func requestType() -> VVAPIManagerRequestType
    
    /// api address
    func apiAddress() -> String
    
    /// service id now this identifier just as log
    func serviceIdentifier() -> String 
    
    
}

/** Optional protocol method
 */
extension VVAPIManagerDelegate {
    
    /// params reformer
    /// - Parameter params: origin params
    func reformerParams(_ params:[String:String?]?) -> [String:String?]? {
    
        return params
    }
    
    /// api response cache
    func cachePolicy() -> VVAPIManagerCachePolicy {
        return .none
    }
    
}

/** Service Protocol
 */
protocol VVAPIManagerService: NSObjectProtocol {
    
    /// Environment
    func apiEnvironment() -> VVAPIManagerEnvironment
    
    /// Service Address
    func serviceAddress() -> String
    
    /// Service could handle some error if she can
    /// Note: if service can handle the error, set return true , else return false, the error will not transport to bussiness
    /// - Parameter manager: apiManager
    /// - Parameter type: error type
    func isHandleApiError(_ manager: VVBaseApiManager,errorType type:VVAPIManagerErrorType) -> Bool
    
}

/** Service Extension*/
extension VVAPIManagerService {
    
    /// service:  generator URLRequest with api\params\and Request Ttpe
    /// - Parameter apiName: apiAddress
    /// - Parameter param: param (optional)
    /// - Parameter type: request type
    func generatorRequestWith(_ apiName: String, apiParams param:[String:String?]?,timeoutInterval timeInterval:TimeInterval, reuqestType type: VVAPIManagerRequestType) -> URLRequest {
        
        var request:URLRequest?
        if type == .GET {
            let fullApiAddress = self.serviceAddress() + apiName + paramsGET(param)
            print("GET Url : \(fullApiAddress)")
            request = URLRequest.init(url: URL(string: fullApiAddress)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeInterval)
        }
        if type == .POST {
            request = URLRequest.init(url: URL(string: apiName)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeInterval)
            request?.httpBody = paramsPOST(param)
        }
        request?.httpMethod =  type.rawValue
        
        return request!
    }
    
    func paramsGET(_ params:[String:String?]?) -> String {
        if params == nil || params!.isEmpty { return "" }
        var paramStr:String = "?"
        for (k,v) in params! {
            if v != nil {
                paramStr += "\(k)=\(v!)&"
            }else {
                paramStr += "\(k)=\("&")"
            }
        }
        return String.init(paramStr.dropLast(1))
    }
    
    func paramsPOST(_ params:[String:String?]?) -> Data? {
        if params == nil || params!.isEmpty { return nil }

        let paramData = try? JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
        return paramData
    }
}

/** Parameter Protocol
 Note: to simple params configure, all param`s value is String
 */
protocol VVAPIManagerParamDataSource: NSObjectProtocol {
    
    func paramsForApiManager(_ manager: VVBaseApiManager) -> [String:String?]?
}

/** Validator Protocol
 */
protocol VVAPIManagerValidator: NSObjectProtocol {
    
    /// param validator
    func validatorParamIsCorrect(_ manager: VVBaseApiManager,
                                 params: [String:String?]?) -> VVAPIManagerErrorType
    
    /// response validator
    func validatorResponseIsCorrect(_ manager: VVBaseApiManager,
                                    response: Dictionary<String, Any>?) -> VVAPIManagerErrorType
}

/** Api Data CallBack
 */
protocol VVAPIManagerDataCallBackDelegate: NSObjectProtocol {
    
    /// api Success
    /// - Parameter apiManager: APIManager
    func managerCallApiSuccess(_ manager: VVBaseApiManager)
    
    /// api Faild
    /// - Parameter apiManager: APIManager
    func managerCallApiFaild(_ manager: VVBaseApiManager)
}

/** Data Reformer (Adapter)
 Note: data ---> (Reformer) ---> (Format Data) or (View)
 */
protocol VVAPIManagerDataReformer: NSObjectProtocol {
    
    func reformerData(_ manager:VVBaseApiManager,
                      data:Dictionary<String,Any>?) -> AnyObject
}

/** LoadNextPage
 */
protocol VVAPIManagerLoadNextPage {

    // current Page
    var currentPageNumber:Int {get set}
    // page Size
    var pageSize: Int { get set}
    // is first page
    var isFirstPage:Bool {get set}
    // is last page
    var isLastPage:Bool {get set}
    
    /// load next
    mutating func loadNextPage()
}

/** Interceptor (AOP)
 */
protocol VVAPIManagerInterceptor:NSObjectProtocol {}

extension VVAPIManagerInterceptor {
    
    /// before perform api
    func shouldPerformApiWithParams(_ manager:VVBaseApiManager,params:[String:String?]?) ->Bool {
        return true
    }
    
    /// after perform api
    func afterPerformApiWithParams(_ manager:VVBaseApiManager,params:[String:String?]?) {}
    
    /// before perform success
    func beforePerformSuccessWithResponse(_ manager:VVBaseApiManager,response:VVURLResponse?) -> VVAPIManagerErrorType {
        return .noError
    }
    
    /// after perform success
    func afterPerformSuccessWithResponse(_ manager:VVBaseApiManager,response:VVURLResponse?) {}
    
    
    /// before perform faild
    func beforePerformFaildWithResponse(_ manager:VVBaseApiManager,response:VVURLResponse?) -> VVAPIManagerErrorType {
        return .noError
    }
    
    /// after perform faild
    func afterPerformFaildWithResponse(_ manager:VVBaseApiManager, response:VVURLResponse?) {}
    
    
    /// did receive service response data
    func didReceiveResponse(_ manager:VVBaseApiManager, response:VVURLResponse?) {}
}
