//
//  XKModal.swift
//  SaaSForDriver
//
//  Created by rober_x on 2019/5/21.
//  Copyright © 2019 xie. All rights reserved.
//

import UIKit
private let XKModalTapOutSideNotification = "XKModalTapOutSideNotification"
private let XKModalWillHideNotification = "XKModalWillHideNotification"
enum CloseButtonType {
    case none
    case leftTop
    case rightTop
    case middleBottom
}

fileprivate let kAlphaAnimateDuration = 0.3
fileprivate let kTransformAnimateDuration = 0.14

///


/// modal 控制器
class XKModalViewController: UIViewController {
    
    override func viewDidLoad() {
        self.view.isOpaque = false
        self.view.addSubview(contanierView)
        contanierView.snp.makeConstraints({ (make) in
            make.centerX.centerY.equalToSuperview()
        })
        
        self.view.addSubview(closeButton)
        
    }
    
    
    
    lazy var contanierView: UIView = {
        let contanierView = UIView()
        return contanierView
    }()
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        if let point =  touch?.location(in: self.view) {

            if self.contanierView.frame.contains(point) {
                return
            } else {
                NotificationCenter.default.post(name: Notification.Name(XKModalTapOutSideNotification), object: nil)
            }
        }
        
    }
    
    /// 需要+按钮在这里加，并且在show（contentView）方法里更新坐标
    lazy var closeButton: UIButton = {
        let button = UIButton()
        //        button.frame =
        button.setImage(UIImage(named: "icon_close"), for: .normal)
        button.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        return button
    }()
    
    @objc func hiddenView() {
        
    }

    
    
    deinit {
        print("控制器已被移除")
    }

    
    
    
    
    
}


/// 主类
class XKModal: NSObject {
    
    /// 单例
    static let shared = XKModal()
    
    var window: UIWindow?
    var contentViewController: XKModalViewController?
    var containerView: UIView?
    
    
    var tapOutsideToDismiss: Bool = true
    var closeButtonType: CloseButtonType = .none
    var modalBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.5)
    
    
    
    deinit {
        print("已被移除")
    }
    
    
    
    
    
    
    

}

extension XKModal {
    
    func showToast(contentView: UIView) {
        self.show(contentView: contentView)
        self.contentViewController?.perform(#selector(delayDismissed), with: nil, afterDelay: 2)
    }
    
    @objc func delayDismissed() {
        XKModal.shared.hidden(animated: true)
    }

    
    func show(contentView: UIView,  animated: Bool = true, autoSize: Bool = false, completion: (() -> Void)? = nil) {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)

        window?.windowLevel = .normal + 10
        window?.isOpaque = false
        let viewController = XKModalViewController()
        viewController.contanierView.addSubview(contentView)
        
        window?.rootViewController = viewController
        self.contentViewController = viewController

        contentView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
            make.width.equalTo(contentView.frame.size.width)
            if(!autoSize) {
                make.height.equalTo(contentView.frame.size.height)
            }
//
        }
//
        
        if(closeButtonType != .none) {
            
        }
        
        self.containerView = viewController.contanierView
       
        
        DispatchQueue.main.async {
           
            
            // 展示当前window
            self.window?.makeKeyAndVisible()
            
            self.contentViewController?.view.backgroundColor = self.modalBackgroundColor
            NotificationCenter.default.addObserver(self, selector: #selector(self.tapCloseAction), name: NSNotification.Name(XKModalTapOutSideNotification), object: nil)
            
            if(animated) {
                // 初始化状态
                self.containerView?.alpha = 0;
                self.containerView?.layer.shouldRasterize = true;
                self.containerView?.transform =  CGAffineTransform(scaleX: 0.4, y: 0.4)
                
                UIView.animate(withDuration: kTransformAnimateDuration, animations: {
                    self.containerView?.alpha = 1;
                    self.containerView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }) { (complte) in
                    UIView.animate(withDuration: kTransformAnimateDuration, animations: {
                        self.containerView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { (complte) in
                        self.containerView?.layer.shouldRasterize = false
                        
                    })
                    
                }
            }
        }
       
        
        
        
    }
    
    /// 手动隐藏，可以添加回调
    func hidden(animated: Bool, completeHandler: (() -> Void)? = nil) {
        if(!animated){
            cleanUp()
            return;
        }
        UIView.animate(withDuration: kAlphaAnimateDuration) {
            self.contentViewController?.view.alpha = 0
        }
        
        self.containerView?.layer.shouldRasterize = true;
        UIView.animate(withDuration: kTransformAnimateDuration, animations: {
            self.containerView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (complete) in
            UIView.animate(withDuration: kTransformAnimateDuration, delay: 0, options: .curveEaseOut, animations: {
                self.containerView?.alpha = 0;
                self.containerView?.transform = CGAffineTransform(scaleX: 0.4, y: 0.4);
                self.cleanUp()
            }, completion: { (complete) in
                completeHandler?()
            })
        }
        
    }
    
    
    /// 点击外部隐藏，灭有回调，如需要回调可以关闭 tapOutsideToDismiss
    @objc func tapCloseAction() {
        if (tapOutsideToDismiss) {
            self.hidden(animated: true)
        }
    }
    
    fileprivate func cleanUp() {
        NotificationCenter.default.removeObserver(self)
//        self.containerView?.removeFromSuperview()
        self.containerView = nil
        UIApplication.shared.delegate?.window?!.makeKey()
        
        self.window?.removeFromSuperview()
        self.contentViewController = nil;
        self.window?.isHidden = true;
        self.window = nil;
    }
    
}
