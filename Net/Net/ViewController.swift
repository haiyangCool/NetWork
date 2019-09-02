//
//  ViewController.swift
//  Net
//
//  Created by 王海洋 on 2019/9/2.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var demoApiManager: DemoApiManager = {
        let demoApiManager = DemoApiManager()
        demoApiManager.dataCallBackDelegate = self
        demoApiManager.paramSource = self
        return demoApiManager
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGray
        
        let btn = UIButton()
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        btn.setTitle("LoadData", for: .normal)
        btn.setTitleColor(.orange, for: .normal)
        btn.addTarget(self, action: #selector(loadAction), for: .touchUpInside)
        self.view.addSubview(btn)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func loadAction()  {
        demoApiManager.loadData()
    }


}

// APIManager
extension ViewController: VVAPIManagerParamDataSource, VVAPIManagerDataCallBackDelegate {
    func paramsForApiManager(_ manager: VVBaseApiManager) -> [String : String?]? {
        return [
            "apiKey":"123fd90af7904388804555f1090d71db",
            "categoryId":"1",
            "topType":"1",
            "limit":"50"
        ]
    }
    
    func managerCallApiSuccess(_ manager: VVBaseApiManager) {
        
        let data:Dictionary<String,Any>? = manager.fetchDataWith(nil) as? Dictionary<String, Any>
        print("Success Data = \(data)")
    }
    
    func managerCallApiFaild(_ manager: VVBaseApiManager) {
        print("faild Data = \n \(manager.faildType())")
        
    }
    
}

