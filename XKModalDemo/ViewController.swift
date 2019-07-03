//
//  ViewController.swift
//  XKModalDemo
//
//  Created by rober_x on 2019/6/27.
//  Copyright © 2019 xie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /// 正常点击背景关闭
    @IBAction func test1(_ sender: Any) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        view.backgroundColor = .white
        XKModal.shared.show(contentView: view)
        
    }
    
    // 不可点击背景关闭
    @IBAction func test2(_ sender: Any) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        view.backgroundColor = .white
        XKModal.shared.tapOutsideToDismiss = false
        XKModal.shared.show(contentView: view)
    }
    
    // 自适应高度
    @IBAction func test3(_ sender: Any) {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textAlignment = .center
        label.text = """
        KKKKK
        LLLLLL
        NNMMMM
        ssssss
        MMMMMM
        
        """
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 0 )
        //        label.sizeToFit()
        XKModal.shared.show(contentView: label, autoSize: true)
    }


}

