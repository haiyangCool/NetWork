//
//  HYApiProxy.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/3.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/** 网络请求代理
      执行生成的网络请求
*/
import UIKit
import Alamofire
typealias HYApiCallBack = (_ response:HYURLResponse) ->Void
/** 执行一次*/
final class HYApiProxy: NSObject {
    
    fileprivate var requestList:Dictionary<NSNumber, DataRequest>?
    static let shared = HYApiProxy()
    private override init() {
        super.init()
        self.requestTable()
    }
    func requestTable() {
        if self.requestList == nil {
            requestList = Dictionary.init()
        }
    }
}
/**
     Public methods
 */
extension HYApiProxy {
    
    /**GET*/
    func requestGetApi(withParams:[String:Any]?, methodName:String, success:@escaping HYApiCallBack, faild:@escaping HYApiCallBack ) -> Int {
        
        let request = HYRequestGenerator.shared.generatorGETRequest(withParams: withParams, methodName: methodName)
        let requestId = self.callRequest(request: request, success: success, faild: faild)
        return requestId
    }
    
    /**POST*/
    func requestPOSTApi(withParams:[String:Any]?, methodName:String, success:@escaping HYApiCallBack, faild:@escaping HYApiCallBack ) -> Int {
        
        let request = HYRequestGenerator.shared.generatorPOSTRequest(withParams: withParams, methodName: methodName)
        let requestId = self.callRequest(request: request, success: success, faild: faild)
        return requestId
    }
    /** 上传图片 */
    func requestUpload(uploadApiAddress:String, withParams:[String:Any]?, imageList:[UIImage], success:@escaping HYApiCallBack, faild:@escaping HYApiCallBack ) -> Int {
        let requestId = self.UploadRequest(uploadApiAddress, withParams: withParams, imageList: imageList, success: success, faild: faild)
        return requestId
    }
    /** 取消请求by RequestID*/
    func cancelRequestByRequestId(requestId:Int) {
        
        let requestIdNum = NSNumber.init(value: requestId)
        let dataRequest = self.requestList![requestIdNum]
        dataRequest?.cancel()
        self.requestList?.removeValue(forKey: requestIdNum)

    }
    /** 取消队列中的所有请求*/
    func cancelAllRequest() {
    
        for dataRequest in (self.requestList?.values.reversed())! {
            dataRequest.cancel()
        }
        self.requestList?.removeAll()
    }
}
/**
     Private methods
     更改网络请求框架时，只需要修改这里Alamofire即可
     /// Apple原生的网络框架越来越完善，而且功能越来越强大，这里可以直接使用Apple原生的网络层来写
 */
extension HYApiProxy {
    
    /** get和post 请求*/
    fileprivate func callRequest(request:URLRequest, success:@escaping HYApiCallBack, faild:@escaping HYApiCallBack ) -> Int{
        
        var dataRequest:DataRequest? = nil
        dataRequest = Alamofire.request(request)
            .validate(statusCode:  200..<300)
            .responseJSON { (response) in
                
            let requestID:NSNumber = (dataRequest?.task?.taskIdentifier as NSNumber?)!
            self.requestList?.removeValue(forKey: requestID)
            let responseString  = String.init(data: response.data!, encoding: String.Encoding.utf8)
            switch response.result {
            case .success( _):

                HYApiLoger.shared.logInfoWithRequest(request: dataRequest?.request, httpMethod: dataRequest?.request?.httpMethod, httpBody: dataRequest?.request?.httpBody, responseString: responseString, responseValue: response.value)
                let hyUrlResponse = HYURLResponse.init().initWith(responseString: responseString!, requestId: requestID, responseData: response.data!, status: .HYURLResponseStatus_SUCCESS)
                success(hyUrlResponse)
                break
            case .failure(let error):
                
                HYApiLoger.shared.logInfoWithRequest(request: dataRequest?.request, httpMethod: dataRequest?.request?.httpMethod, httpBody: dataRequest?.request?.httpBody, responseString: responseString, responseValue: response.value, error: error as NSError)
                let hyUrlResponse = HYURLResponse.init().initWith(responseString: responseString, requestId: requestID, responseData: response.data!, error: error as NSError)
                faild(hyUrlResponse)
                break
            }
        }

        let requestId:NSNumber = (dataRequest?.task?.taskIdentifier as NSNumber?)!
        self.requestList![requestId] = dataRequest
        dataRequest?.task?.resume()
        return requestId.intValue
    }
    
    /** 图片上传*/
    fileprivate func UploadRequest(_ uploadApiAddress:String,withParams:[String:Any]?,  imageList:[UIImage], success:@escaping HYApiCallBack, faild:@escaping HYApiCallBack ) -> Int{
        
        let defaultName = "ios" + uploadApiAddress + "USERID"
        let param = withParams?.reversed()
    
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                /** 参数*/
                if param != nil{
                    for (key,value) in param! {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
                /** 图片*/
                for i in 0..<imageList.count {
                    let imageData = UIImageJPEGRepresentation(imageList[i], 1)
                    multipartFormData.append(imageData!, withName: "file", fileName: defaultName+"\(i)", mimeType: "image/png")
                }
             
        },to: uploadApiAddress,encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                ///连接服务器成功后，对json的处理
                upload.responseJSON { response in
                    let responseString  = String.init(data: response.data!, encoding: String.Encoding.utf8)
                    let hyUrlResponse = HYURLResponse.init().initWith(responseString: responseString!, requestId: 0, responseData: response.data!, status: .HYURLResponseStatus_SUCCESS)
                    success(hyUrlResponse)
                }
                ///获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("图片上传进度: \(progress.fractionCompleted)")
                }
            case .failure(let error):
                let hyUrlResponse = HYURLResponse.init().initWith(responseString: nil, requestId: 0, responseData: nil, error: error as NSError)
                faild(hyUrlResponse)
                print("error\(error)")
            }
        })
        
        return 0
    }
}
