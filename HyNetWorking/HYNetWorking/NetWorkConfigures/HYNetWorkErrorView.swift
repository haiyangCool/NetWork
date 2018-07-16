//
//  HYNetWorkErrorView.swift
//  HyNetWorking
//
//  Created by hiveViewhy on 2018/1/9.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/** 网络请求发生错误的时候进行提示
     1、debug 时，显示错误信息和数据
 
 */
import UIKit
let HyNetErrorContentViewHeight:CGFloat = 90
let HyNeterrorTypeLabelHeight:CGFloat = 20
let HyNeterrorTypeInfoLabelHeight:CGFloat = 40

class HYNetWorkErrorView: UIView {

    /** error view*/
    lazy  fileprivate var errorContentView:UIView = {
        let errorCV = UIView.init()
        errorCV.frame = CGRect.init(x: 0, y: -HyNetErrorContentViewHeight, width: UIScreen.main.bounds.size.width, height: HyNetErrorContentViewHeight)
        errorCV.backgroundColor = UIColor.white
        return errorCV
    }()
    /** 错误类型*/
    lazy fileprivate var errorTypeLabel:UILabel = {
        
        let errorTL = UILabel.init()
        errorTL.frame = CGRect.init(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: HyNeterrorTypeLabelHeight)
        errorTL.backgroundColor = UIColor.clear
        errorTL.textColor = UIColor.red
        errorTL.textAlignment = .center
        errorTL.font = UIFont.boldSystemFont(ofSize: 15)
        return errorTL
    }()
    /** 类型详情*/
    lazy fileprivate var errorInfoLabel:UILabel = {
        
        let errorTIL = UILabel.init()
        errorTIL.frame = CGRect.init(x: 10, y: 40, width: UIScreen.main.bounds.size.width-20, height: HyNeterrorTypeInfoLabelHeight)
        errorTIL.backgroundColor = UIColor.white
        errorTIL.textColor = UIColor.black
        errorTIL.textAlignment = .center
        errorTIL.numberOfLines = 0
        errorTIL.font = UIFont.systemFont(ofSize: 14)
        return errorTIL
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ininUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/**
     显示
 */
extension HYNetWorkErrorView {

    func configureErrorInfo(errorType:String?, errorInfo:String?) {
        self.errorTypeLabel.text = errorType
        self.errorInfoLabel.text = errorInfo

    }
    /** animation show*/
    func showErrorView(view:UIView?,duration:TimeInterval) {
        
        view?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.errorContentView.transform = CGAffineTransform.init(translationX: 0, y: HyNetErrorContentViewHeight)
        }
        self.autoPackUpThisView(duration: duration)
    }
    
    /** 自动收起*/
    fileprivate func autoPackUpThisView(duration:TimeInterval) {
            UIView.animate(withDuration: duration, animations: {
            self.errorInfoLabel.alpha = 0.6
            }) { (flag) in
            UIView.animate(withDuration: 0.3, animations: {
            self.errorContentView.transform = CGAffineTransform.identity
            }, completion: { (flag) in
            self.removeFromSuperview()
            })
        }
    }
}
/**
     错误页面的UI
 */
extension HYNetWorkErrorView {
    
    fileprivate func ininUI() {
        
        self.addSubview(self.errorContentView)
        self.errorContentView.addSubview(self.errorTypeLabel)
        self.errorContentView.addSubview(self.errorInfoLabel)
    }
}
