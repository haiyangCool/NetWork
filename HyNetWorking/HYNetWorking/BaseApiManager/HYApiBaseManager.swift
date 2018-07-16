//
//  HYApiBaseManager.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/2.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/** 网络请求
     1、每一个api 都创建一个apiManager(继承HYApiBaseManager)
        并实现child的Protocol（HYAPIManager）
 */
import UIKit

/**  HYAPIManagerAPiResultCallBackDelegate
     Api 回调  所有的请求结果由 Delegate 返回
     1、请求成功的结果 SUCCESS
     2、请求出错的结果 FAILD
 ******************************************************************************/
protocol HYAPIManagerAPiResultCallBackDelegate {
    /**请求成功回调*/
    func managerCallAPIDidSuccess(manager:HYApiBaseManager)
    /**请求失败回调*/
    func managerCallAPIDidFaild(manager:HYApiBaseManager)
}

/**  HYAPIManagerCallBackDataReformer -
     Api 数据结果的处理组装
 
 ******************************************************************************/
@objc protocol HYAPIManagerCallBackDataReformer {
    
    /** 组装数据*/
    func reformerData(manager:HYApiBaseManager, reformerData:NSDictionary?) -> Any?
    @objc optional
    /** 组装服务器的失败数据*/
    func faildReformer(manager:HYApiBaseManager, reformerData:NSDictionary?) ->Any?
}

/**  HYAPIManagerValidator
     Api 验证器 由子类manager 实现
     1、数据返回后，在Base层仅作SUCCESS与否的判断，不对数据的格式，或空做处理，由childManager实现- 因为不同的公司定义的数据返回格式是不一样的 ,Base 做处理显然不合适
     如果 Api返回的数据格式是一样的，就可以共用同一个验证器
     2、参数验证，非常重要，通过参数来判断请求的合法性，从根源上避免无效的api请求
         example：注册验证邮箱，或其他需要验证参数时
     而且通过返回 参数错误的信息（自定义），容易定位到问题
     所以，每个controller 拥有自己的验证器去做这件事是非常重要的
 ******************************************************************************/
protocol HYAPIManagerValidator {
    
    /** 验证返回的数据是否合法 - 不需验证时，直接返回true*/
    func validatorCallBackDataIsCorrect(manager:HYApiBaseManager, apiData:NSDictionary) -> Bool
    /** 验证请求参数是否合法 - 不需验证时，直接返回true*/
    func validatorApiParameterIsCorrect(manager:HYApiBaseManager, apiParameter:[String:Any]?) -> Bool
}

/**  HYAPIManagerParameterSourceDelegate
     Api 获取请求参数
     通过 代理为每个Api 设置请求参数
 ******************************************************************************/

@objc protocol HYAPIManagerParameterSourceDelegate {
    
    /** 参数设置*/
    func configureParametersForApi(manager:HYApiBaseManager) -> [String:Any]?
    
    /** 上传图片时，需要额外提交图片数据*/
    @objc optional
    func configureUploadImageList(manager:HYApiBaseManager) -> [UIImage]
    /** 下载 - 提供下载地址
     如果不提供-将使用默认的地址 -- /user/
     */
    @objc optional
    func configureDownLoadAddress(manager:HYApiBaseManager) -> String?
}

/**  HYAPIManagerErrorType
     api出现问题时，返回的错误类型
 */
public enum HYAPIManagerErrorType:String {
    /**
         1、默认类型的错误
         2、参数错误
         3、请求超时
         4、有数据返回但是，数据不可用
         5、网络不可用
         6、Url不支持（url错误）
         7、上传图片时，没有设置图片
     */
    case HYAPIManagerErrorType_Default,
         HYAPIManagerErrorType_PatameterError,
         HYAPIManagerErrorType_RequestTimeout,
         HYAPIManagerErrorType_ResponseDataIllegal,
         HYAPIManagerErrorType_NetCanNotReachable,
         HYAPIManagerErrorType_URLNotSupport,
         HYAPIManagerErrorType_NoImage
}

/**  HYAPIManagerRequestType
     api请求方式
 */
public enum HYAPIManagerRequestType:String {
    /**
         1、GET 请求
         2、POST 请求
         3、上传  - 暂未验证可用与否
         4、下载  - 暂未进行实现
     */
    case HYAPIManagerRequestType_GET,
         HYAPIManagerRequestType_POST,
         HYAPIManagerRequestType_UPLOAD,
         HYAPIManagerRequestType_DOWNLOAD
}

/**  HYAPIManager
     由子类manager 实现
     用来约束子类：子类只能实现父类定义的方法，防止子类进行胡乱操作  ****************************************/
@objc protocol HYAPIManager {
    
    /** 方法名-接口名，在做缓存时作为key的一部分*/
    func apiMethodName() -> String
    
    /** 请求类型 HYAPIManagerRequestType*/
    func apiRequestType() -> HYAPIManagerRequestType.RawValue
    
    /** request Api接口地址*/
    func apiRequestUrl() -> String
    
    /** 是否缓存- 该缓存仅作临时存储需求，缓存超时时间为2分钟
     如果需要做持久化存储，在子类中shouldLoadDataFromNative的返回true即可
     */
    func shouldCache() -> Bool
    
    /** 以下为可选的Protocol*/
    @objc optional
    /** 是否为调试 - 调试阶段错误类型信息打印在页面上，方便排查数据*/
    func isDebug() -> Bool
   
    @objc optional
    /** 本地加载数据 */
    func shouldLoadDataFromNative() -> Bool
    
    @objc optional
    /** Base Url - 应对App 中可能会出现不同的根域名*/
    func apiBaseUrl() -> String
    
    @objc optional
    /** 对参数做处理- 只做添加额外参数,不对原有参数做处理*/
    func reformParams(params:[String:Any]?) -> [String:Any]?
}

class HYApiBaseManager: NSObject {
    
    /** 数据返回 - controller 实现*/
    var delegate:HYAPIManagerAPiResultCallBackDelegate?
    /** 参数设置 - controller 实现*/
    var parameterSourceDelegate:HYAPIManagerParameterSourceDelegate?
    
    /** 由子类来实现的*/
    weak var child:HYAPIManager?
    /** 由子类（或者验证者）来实现的- 数据、参数验证*/
    var validator:HYAPIManagerValidator?
    /** Api 原始数据*/
    var apiRowData:Any?
    /** 错误类型 - 默认*/
    var apiErrorType:HYAPIManagerErrorType?
    /** 错误信息 */
    var errorContentMsg:String?
    /** response*/
    var responses:HYURLResponse?
    /** 是否正在请求*/
    var isLoading:Bool?

    override init() {
        
        self.delegate = nil
        self.parameterSourceDelegate = nil
        
        self.apiRowData = nil
        self.apiErrorType = HYAPIManagerErrorType.HYAPIManagerErrorType_Default
        self.errorContentMsg = "默认类型的错误(详情请看源代码)"
        self.isLoading = false
    }
    
    lazy var hyCache: HYCache = {
        let hyCache = HYCache.shared
        return hyCache
    }()

   lazy var requestIdList: NSMutableArray = {
        let requestIdList = NSMutableArray.init()
        return requestIdList
    }()
    
    deinit {
        
        self.cancelALlRequests()
    }
}
/** public request Methods
 */
extension HYApiBaseManager {
    
    /** 请求数据*/
    public func loadData() -> Int{
        
        let apiParameters = self.parameterSourceDelegate?.configureParametersForApi(manager: self)
        if self.responds(to: #selector(self.child?.reformParams(params:))) {
            let params = self.child?.reformParams!(params: apiParameters)
            let requestID = self.loadDataWithParameters(url: self.apiAddress(), params: params)
            return requestID
        }
        let requestID = self.loadDataWithParameters(url: self.apiAddress(), params: apiParameters)
        return requestID
    
    }
    /** 带参数请求*/
    public func loadDataWithParams(params:[String:Any]?) -> Int {
   
        if self.responds(to: #selector(self.child?.reformParams(params:))) {
            let newParams = self.child?.reformParams!(params: params)
            let requestID = self.loadDataWithParameters(url: self.apiAddress(), params: newParams)
            return requestID
        }
        let requestID = self.loadDataWithParameters(url: self.apiAddress(), params: params)
        return requestID
    }
    
    /** 上传图片*/
    func uploadImage() -> Int {
        
        let requestApi = self.child?.apiRequestUrl()
        let requestAddress = HYNetWorkConfiguration.shared.apiBaseUrl() + requestApi!
        let apiParameters = self.parameterSourceDelegate?.configureParametersForApi(manager: self)
        if self.responds(to: #selector(self.parameterSourceDelegate?.configureUploadImageList(manager:))) {
            let imageList = self.parameterSourceDelegate?.configureUploadImageList!(manager: self)
            return  self.uploadImageToServer(url: requestAddress, params: apiParameters, imageList: imageList!)
        }else {
            self.errorContentMsg = "没有待上传的图片"
            self.faildCallApi(response: nil, errorType: .HYAPIManagerErrorType_NoImage)
            return 0
        }
    }
    /** 解析数据 （正确或失败的）*/
    func fetchDataWithReformer(reformer:HYAPIManagerCallBackDataReformer?) -> Any? {
        if reformer != nil {
            let response = reformer?.reformerData(manager: self, reformerData: self.apiRowData as? NSDictionary)
            return response
        }else {
            return self.apiRowData
        }
    }
    /** 获取失败信息（失败原因）-- 根据不同的失败情况显示不同的错误展示页面 */
    func fetchReasonOfApiFailure() -> HYAPIManagerErrorType {
        return self.apiErrorType!
    }
    /** 显示错误的信息*/  /// Debug 使用
    func showErrorInfo() {
        ///HUD Showing - 非调试不显示
        if self.responds(to: #selector(self.child?.isDebug)) {
            if !(self.child?.isDebug!())! { return }
            /// self.child 哪个apiManager 出错 + 错误信息
            let errorMessageInfo = "\(String(describing: self.child!)) \n \(String(describing: self.errorContentMsg!))"
            let faildView = HYNetWorkErrorView.init(frame: UIScreen.main.bounds)
            faildView.showErrorView(view: UIApplication.shared.keyWindow, duration: 3)
            faildView.configureErrorInfo(errorType: self.apiErrorType?.rawValue, errorInfo: errorMessageInfo)
        }
    }
    /** 取消当前的所有请求*/
    public func cancelALlRequests() {
        HYApiProxy.shared.cancelAllRequest()
        self.requestIdList.removeAllObjects()
    }
    
    /** 取消请求by ID*/
    public func cancelRequestByRequestID(requestId:Int) {
        self.removeRequestById(requestId: requestId)
        HYApiProxy.shared.cancelRequestByRequestId(requestId: requestId)
    }
}

/** fileprivate request Methods
 */
extension HYApiBaseManager {
    /** Upload 上传*/
    fileprivate func uploadImageToServer(url:String,params:[String:Any]?,imageList:[UIImage]) -> Int {
        if HYNetWorkConfiguration.shared.isReachable() {
          let requestId = HYApiProxy.shared.requestUpload(uploadApiAddress: url, withParams: params, imageList: imageList, success: { (successRespone) in
                self.successedCallApi(response: successRespone)
            }, faild: { (faildResponse) in
                self.faildCallApi(response: faildResponse, errorType: .HYAPIManagerErrorType_Default)
            })
            self.requestIdList.adding(NSNumber.init(value: requestId))
        }else{
            self.errorContentMsg = "网络不通"
            self.faildCallApi(response: nil, errorType: .HYAPIManagerErrorType_NetCanNotReachable)
            return 0
        }
        return 0
    }
    /** get post 取数据*/
    fileprivate func loadDataWithParameters(url:String,params:[String:Any]?) -> Int {
        /// 验证参数
        if (self.validator?.validatorApiParameterIsCorrect(manager: self, apiParameter: params))! {
            
            ///本地加载
            if self.responds(to: #selector(self.child?.shouldLoadDataFromNative)) 
            {
                if (self.child?.shouldLoadDataFromNative!())! {
                    self.loadDataFromNative()
                }
            }
            ///判断是否存在缓存
            if (self.child?.shouldCache())! && self.isHasCacheWithParams(params: params) {
                return 0
            }
        
            if HYNetWorkConfiguration.shared.isReachable() {
                self.isLoading = true
                let requestType = self.child?.apiRequestType()
                switch requestType {
                case HYAPIManagerRequestType.HYAPIManagerRequestType_GET.rawValue?:
                    let requestId =  HYApiProxy.shared.requestGetApi(withParams: params, methodName: url, success: { [weak self] (successResponse) in
                            self?.successedCallApi(response: successResponse)
                        }, faild: { [weak self] (faildResponse) in
                            self?.faildCallApi(response: faildResponse, errorType: .HYAPIManagerErrorType_Default)
                    })
                    self.requestIdList.adding(NSNumber.init(value: requestId))
                    break
                case HYAPIManagerRequestType.HYAPIManagerRequestType_POST.rawValue?:
                    let requestId = HYApiProxy.shared.requestPOSTApi(withParams: params, methodName: url, success: {[weak self] (successResponse) in
                            self?.successedCallApi(response: successResponse)
                        }, faild: {[weak self] (faildResponse) in
                            self?.faildCallApi(response: faildResponse, errorType: .HYAPIManagerErrorType_Default)
                    })
                    self.requestIdList.adding(NSNumber.init(value: requestId))
                    break
                case HYAPIManagerRequestType.HYAPIManagerRequestType_UPLOAD.rawValue?:
                    return self.uploadImage()

                case HYAPIManagerRequestType.HYAPIManagerRequestType_DOWNLOAD.rawValue?:
                    self.errorContentMsg = "下载功能暂未实现"
                    self.faildCallApi(response: nil, errorType: .HYAPIManagerErrorType_Default)
                    return 0
                    
                default:
                    self.errorContentMsg = "…… ？？？……"
                    self.faildCallApi(response: nil, errorType: .HYAPIManagerErrorType_Default)
                    return 0
                }
            }else{
                self.errorContentMsg = "网络已断开"
                self.faildCallApi(response: nil, errorType: .HYAPIManagerErrorType_NetCanNotReachable)
                return 0
            }
        }else {

            self.errorContentMsg = "参数验证失败"
            self.faildCallApi(response: nil, errorType: .HYAPIManagerErrorType_PatameterError)
            return 0
        }
        return 0
    }
    /** 从本地加载数据*/
    fileprivate func loadDataFromNative() {
        
        let userDefault = UserDefaults.standard
        let data:Data? = userDefault.value(forKey: (self.child?.apiMethodName())!) as? Data
        if data == nil { return }
        let result:NSDictionary? = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        if result != nil {
        
            let data = try? JSONSerialization.data(withJSONObject: result!, options: JSONSerialization.WritingOptions.prettyPrinted)
            let queue = DispatchQueue.init(label: "com.hynet.loadNative")
            queue.sync {
                let response = HYURLResponse.init().initWithData(data: data!)
                self.successedCallApi(response: response)
            }
        }
    }
}
/** request result Private methods
 */
extension HYApiBaseManager {

    /** 获取API地址*/
    fileprivate func apiAddress() -> String {
        var requestAddress:String = ""
        let requestApi = self.child?.apiRequestUrl()
        requestAddress = HYNetWorkConfiguration.shared.apiBaseUrl() + requestApi!
        if self.responds(to: #selector(self.child?.apiBaseUrl)) {
            requestAddress = (self.child?.apiBaseUrl!())! + requestApi!
        }
        return requestAddress
    }
     /** 请求成功*/
    fileprivate func successedCallApi(response:HYURLResponse) {
        print("数据 = \(response)")
        self.isLoading = false
        if response.content != nil {
            self.apiRowData = response.content
        }else {
            self.apiRowData = response.responseData
        }
     
        if self.responds(to: #selector(self.child?.shouldLoadDataFromNative)) {
            if (self.child?.shouldLoadDataFromNative!())! {
                if response.isCache == false {
                    let userDefault = UserDefaults.standard
                    userDefault.set(response.responseData, forKey: (self.child?.apiMethodName())!)
                    userDefault.synchronize()
                }
            }
        }
        ///移除该请求
        self.removeRequestById(requestId: (response.requestId?.intValue)!)
        /// 设置API请求得到的数据
        if (self.validator?.validatorCallBackDataIsCorrect(manager: self, apiData: response.content as! NSDictionary))! {
         
            ///如果数据（response）已经不是缓存数据（写入缓存）
            if (self.child?.shouldCache())! && !response.isCache! {
                if !(response.responseData?.isEmpty)! {
                    self.hyCache.saveCacheDataWith(cacheData: (response.responseData!), requestIdentifier: (self.child?.apiRequestType())!, methodName: (self.child?.apiMethodName())!, params: self.parameterSourceDelegate?.configureParametersForApi(manager: self))
                }
            }
            self.delegate?.managerCallAPIDidSuccess(manager: self)
        }else {
            self.errorContentMsg = "数据不合法"
            self.faildCallApi(response: response, errorType: .HYAPIManagerErrorType_ResponseDataIllegal)
        }
    }
    
    /** 请求失败*/
    fileprivate func faildCallApi(response:HYURLResponse?, errorType:HYAPIManagerErrorType) {
     
        self.isLoading = false
        if response?.content != nil {
            self.apiRowData = response?.content
        }else {
            self.apiRowData = response?.responseData
        }
        self.apiErrorType = errorType

        self.removeRequestById(requestId: (response?.requestId?.intValue))
        self.delegate?.managerCallAPIDidFaild(manager: self)
        
        if self.apiErrorType == .HYAPIManagerErrorType_Default {
            self.errorContentMsg = "默认类型的错误(详情请看源代码)"
        }
        if response?.status == .HYURLResponseStatus_RequestTimeOut {
            ////请求超时
            self.apiErrorType = .HYAPIManagerErrorType_RequestTimeout
            self.errorContentMsg = "请求超时"
        }
        if response?.status == .HYURLResponseStatus_URLErrorUnsupportedURL {
            //// Url 不支持
            self.apiErrorType = .HYAPIManagerErrorType_URLNotSupport
            self.errorContentMsg = "该URL无法被响应,无效的URL"
        }
        /// 屏幕显示错误信息
        DispatchQueue.main.async {
             self.showErrorInfo()
        }
    }
   
    /** 取消请求by Id*/
    fileprivate func removeRequestById(requestId:Int?) {
        
        if requestId != nil {
            var requestObj:NSNumber? = nil
            for queueRequestId in self.requestIdList {
                if (queueRequestId as! NSNumber).intValue == requestId {
                    requestObj = queueRequestId as? NSNumber
                }
            }
            if requestObj != nil {
                self.requestIdList.remove(requestObj!)
            }
        }
    }
    
    /** 查找已经存在的缓存*/
    fileprivate func isHasCacheWithParams(params:[String:Any]?) -> Bool {
        
        let requestType = self.child?.apiRequestType()
        let methodName = self.child?.apiMethodName()
        
        let cacheObj = self.hyCache.fetchCacheDataWith(requestIdentifier: requestType!, methodName: methodName!, params: params)
        if cacheObj == nil {
            return false
        }
        let responseData = HYURLResponse.init().initWithData(data: cacheObj!)
        self.successedCallApi(response: responseData)
        return true
    }
}
