//
//  VVNetApiProxy.swift
//  NetWork
//
//  Created by 王海洋 on 2017/8/8.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
let VVAPIIDPrefix = "VVAPIIDPrefix"
typealias VVApiCallBack = (_ response:VVURLResponse) -> Void

class VVNetApiProxy: NSObject {
    lazy var dataTaskList:[String:URLSessionDataTask] = [:]

    static let shared = VVNetApiProxy()
    private override init() {
        
    }
}


// MARK: - if you want to exchange Net Framework (example:Alamofire) , please fix 
extension VVNetApiProxy {
    
    func callApiWith(_ request:URLRequest,success: @escaping VVApiCallBack,faild: @escaping VVApiCallBack) -> Int {
        var requestId = 0
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let responeData:Data = data, let responseStr:String = String.init(data: responeData, encoding: .utf8) {
                let vResponse = VVURLResponse.init(with: responseStr, urlRequest: request, error: error)
                
                print("visit net")
                let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
               
                switch httpResponse.statusCode {
                case 200...400:
                    success(vResponse)
                    break
                default:
                    faild(vResponse)
                    break
                }
                
            }else {
                ///k
                faild(VVURLResponse())
                print("sorry , there is no data back")
            }
        }
        dataTask.resume()
        requestId = dataTask.taskIdentifier
        dataTaskList["\(VVAPIIDPrefix)\(requestId)"] = dataTask
        return requestId
    }
    
    
    /// Cancel request by requestId
    /// - Parameter requestId: request ID
    func cancelRequestBy(_ requestId:Int) {
        
        let requestKey = VVAPIIDPrefix + "\(requestId)"
        
        if dataTaskList.contains(where: { (requestIdr,dataTask) -> Bool in
            requestKey == requestIdr
        }) {
            dataTaskList[requestKey]?.cancel()
        }
    }
    
    
    /// Cancel all Requset
    func cancelAllRequest() {
        for dataTask in dataTaskList.values.reversed() {
            dataTask.cancel()
        }
        dataTaskList.removeAll()
    }
}
