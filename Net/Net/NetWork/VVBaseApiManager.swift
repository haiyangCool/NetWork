//
//  VVBaseApiManager.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/1.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
// success closure
typealias SuccessClosure = (_ response:VVURLResponse?) -> Void
// faild closure
typealias FaildClosure = (_ errorType:VVAPIManagerErrorType,_ response:VVURLResponse?) ->Void
class VVBaseApiManager: NSObject {
    
    // the child must be implement this protocol, if not, your will get crash
    weak open var delegate:VVAPIManagerDelegate?
    
    // Service
    open var service:VVAPIManagerService?
    
    // Param
    weak open var paramSource:VVAPIManagerParamDataSource?
    
    // Validator
    weak open var validator:VVAPIManagerValidator?
    
    // Interceptor
    weak open var interceptor:VVAPIManagerInterceptor?
    
    // Data callBace Delegate
    weak open var dataCallBackDelegate:VVAPIManagerDataCallBackDelegate?
    
    
    // request timeout default 15 seconds
    open var timeoutInterval: TimeInterval = 15
    // cache time default is 1 min
    open var memoryCacheTime: TimeInterval = 1*60
    open var diskCacheTime: TimeInterval = 1*60
    
    
    // Load
    // if isLoading is true, apiManager will return,not perform new Api call
    open var isLoading:Bool = false
    // if isIgnoreCache is true, apiManager perform new call even cache is not empty
     open var isIgnoreCache:Bool = false
    // cache poliocy , default do not cache
    open var cachePolicy:VVAPIManagerCachePolicy = .none
    
    // Response
    open var urlResponse: VVURLResponse? = nil
    open var errorType: VVAPIManagerErrorType = .default
    open var errorMessage: String = VVAPIManagerErrorType.default.rawValue
    
    // cache Manager
    lazy var cacheManager = VVCacheManager.shared
    
    // requestId list
    fileprivate var requestIdList:[Int] = []
    
    // closure
    fileprivate var successClosure: SuccessClosure?
    fileprivate var faildClosure: FaildClosure?
    override init() {
        
        delegate = nil
        service = nil
        validator = nil
        paramSource = nil
        interceptor = nil
        dataCallBackDelegate = nil
    }

}

/**Public methods*/
extension VVBaseApiManager {
    
    /// load Data
    open func loadData() -> Int {
                var params:[String:String?]? = nil
        if paramSource != nil {
            params = paramSource!.paramsForApiManager(self)
        }
        return loadDataWith(params)
        
    }
    
    /// load Data with closure
    open func loadDataWith(_ params:[String:String?]?,successCallBack success: @escaping  SuccessClosure, faildCallBack faild: @escaping FaildClosure) -> Int{
        successClosure = success
        faildClosure = faild
        return loadDataWith(params)
    }
    
    
    /// fetch data(or view) with reformer
    /// - Parameter reformer: reformer as a protocol
    open func fetchDataWith(_ reformer:VVAPIManagerDataReformer?) -> Any{
        if reformer != nil {
            let data = reformer?.reformerData(self, data: urlResponse?.responseContent)
            return data as Any
        }else {
            return urlResponse?.responseContent as Any
        }
    }
    
    /// get faild type if perform api error
    open func faildType() -> VVAPIManagerErrorType {
        return errorType
    }
    
    /// cancel request by request id
    open func cancelRequestWith(_ requestId:Int) {
        if requestIdList.contains(requestId) {
            VVNetApiProxy.shared.cancelRequestBy(requestId)
            requestIdList.removeAll{ $0 == requestId }
        }
    }
    
    /// cancel all request
    open func cancelAllRequest() {
        
        VVNetApiProxy.shared.cancelAllRequest()
        requestIdList.removeAll()
    
    }
}

/** Load Private methods*/
extension VVBaseApiManager {
    
    private func validatorServiceAndChild() {
    
        assert(delegate != nil && service != nil, "子类(继承自VVBaseApiManager)必须实现Delegate协议并且需要设置服务提供方（Service协议）")
    }
    
    fileprivate func loadDataWith(_ params:[String:String?]?) -> Int {
       
        // 要使用该API ,必须实现子类规定的协议，并且提供一个Service(协议)
        validatorServiceAndChild()

        var requestId = 0
        if isLoading {
            return requestId
        }
        let finalParams = delegate?.reformerParams(params)
        if shouldPerformApiWithParams(self, params: finalParams) {
            // access interceptor
            
            // param validator
            let errorType = validator?.validatorParamIsCorrect(self, params: finalParams)
            if errorType == nil || errorType == .some(.noError) {
                // ...
                var vResponse:VVURLResponse?
                // if ignore cache
                if !isIgnoreCache {
                    if cachePolicy == .memoryCache {
                        vResponse = fetchCache(.memory)
                    }
                    if cachePolicy == .diskCache {
                        vResponse = fetchCache(.disk)
                    }
                }
                // if cache not empty, direct return cache data
                if vResponse != nil {
                    successCallApiWithResponse(vResponse!)
                    return requestId
                }
                
                // cache is empty , call api ...
                if isReachability() {
                    isLoading = true
                    // get request and call api
                    let request = service!.generatorRequestWith(self.delegate!.apiAddress(), apiParams: self.paramSource?.paramsForApiManager(self),timeoutInterval: timeoutInterval, reuqestType: self.delegate!.requestType())
                    
                    requestId = VVNetApiProxy.shared.callApiWith(request, success: { (successResponse) in
                        self.successCallApiWithResponse(successResponse)
                    }) { (faildResponse) in
                        self.faildCallApiWithResponse(faildResponse, errorType: .default)
                    }
                    
                    requestIdList.append(requestId)
                    afterPerformApiWithParams(self, params: finalParams)
                    return requestId
                    
                }else {
                    faildCallApiWithResponse(nil, errorType: .netCanNotReach)
                    return requestId
                }
                
            }else {
                // faild
                faildCallApiWithResponse(nil, errorType: .paramNotCorrect)
                return requestId
            }
    
        }
        return requestId
    
    }
    
    
    /// net is reachability
    private func isReachability() -> Bool {
        let reachability = true
        return reachability
    }
}

/** Success or Faild*/
extension VVBaseApiManager {
    
    private func successCallApiWithResponse(_ response:VVURLResponse) {
        
        isLoading = false
        urlResponse = response
        
        let errType = validator?.validatorResponseIsCorrect(self, response: urlResponse?.responseContent)
        if errType == nil || errType == .some(.noError) {
            
            if cachePolicy == .memoryCache && response.isCache == false {
                cacheManager.saveData(response, serviceIdentifier: delegate!.serviceIdentifier(), apiName: delegate!.apiAddress(), parameter: paramSource?.paramsForApiManager(self), cacheTime: memoryCacheTime, cacheType: .memory)
            }
            
            if cachePolicy == .diskCache && response.isCache == false {
                cacheManager.saveData(response, serviceIdentifier: delegate!.serviceIdentifier(), apiName: delegate!.apiAddress(), parameter: paramSource?.paramsForApiManager(self), cacheTime: diskCacheTime, cacheType: .disk)
            }
            
            
            if beforePerformSuccessWithResponse(self, response: urlResponse) == .noError {
                DispatchQueue.main.async {
                    self.dataCallBackDelegate?.managerCallApiSuccess(self)
                    if self.successClosure != nil {
                        self.successClosure!(response)
                    }
                }
            }
            
            afterPerformFaildWithResponse(self, response: urlResponse)
            
        }else {
            faildCallApiWithResponse(response, errorType: .resultNotCorrect)
        }
        
        
    }
    
    private func faildCallApiWithResponse(_ response:VVURLResponse?,errorType type:VVAPIManagerErrorType) {
        
        isLoading = false
        urlResponse = response
        self.errorType = type
        if response?.state == .some(.netException) {
            self.errorType = .netException
        }
        if response?.state == .some(.requestCancel) {
            self.errorType = .requestCancel
        }
        if response?.state == .some(.requestTimeOut) {
            self.errorType = .requestTimeout
        }
        errorMessage = errorType.rawValue
        if service!.isHandleApiError(self, errorType: type) {
            return
        }
        
        if interceptor != nil && interceptor!.beforePerformFaildWithResponse(self, response: urlResponse) == .noError{
            return
        }
        
        DispatchQueue.main.async {
            self.dataCallBackDelegate?.managerCallApiFaild(self)
            if self.faildClosure != nil {
                self.faildClosure!(self.errorType,response!)
            }
        }
        
        afterPerformFaildWithResponse(self, response: urlResponse)
    }
}

/** Cache manager*/
extension VVBaseApiManager {
    
    /// fetch Memory cache and return (if memory cache is not empty, not timeout  )
    private func fetchCache(_ cacheType:VVCacheType) -> VVURLResponse? {
        
        return cacheManager.fetchData(serviceIdentifier: self.delegate!.serviceIdentifier(), apiName: self.delegate!.apiAddress(), parameter: self.paramSource?.paramsForApiManager(self), cacheTime: memoryCacheTime, cacheType: cacheType)
    }

    
}
/** AOP
 Decorate pattern
 */
extension VVBaseApiManager {
    
    private func shouldPerformApiWithParams(_ manager: VVBaseApiManager, params: [String : String?]?) -> Bool {
        
        if interceptor != nil {
            return interceptor!.shouldPerformApiWithParams(manager, params: params)
        }
        
        return true
    }
    
    private func afterPerformApiWithParams(_ manager: VVBaseApiManager, params: [String : String?]?) {
        
        if interceptor != nil  {
            interceptor!.afterPerformApiWithParams(manager, params: params)
        }
    }
    
    private func beforePerformSuccessWithResponse(_ manager: VVBaseApiManager, response: VVURLResponse?) -> VVAPIManagerErrorType {
        
        if interceptor != nil {
            return interceptor!.beforePerformSuccessWithResponse(manager, response: response)
        }
        return .noError
    }
    
    private func afterPerformSuccessWithResponse(_ manager: VVBaseApiManager, response: VVURLResponse?) {
        
        if interceptor != nil {
            interceptor?.afterPerformSuccessWithResponse(manager, response: response)
        }
    }
    
    private func beforePerformFaildWithResponse(_ manager: VVBaseApiManager, response: VVURLResponse?) -> VVAPIManagerErrorType {
        if interceptor != nil {
            return interceptor!.beforePerformFaildWithResponse(self, response: response)
        }
        return .noError
    }
    
    private func afterPerformFaildWithResponse(_ manager: VVBaseApiManager, response: VVURLResponse?) {
        if interceptor != nil {
            interceptor?.afterPerformFaildWithResponse(manager, response: response)
        }
    }
    
    private func didReceiveResponse(_ manager: VVBaseApiManager, response: VVURLResponse?) {
        if interceptor != nil {
            interceptor?.didReceiveResponse(manager, response: response)
        }
    }
}
