//
//  ViewController.swift
//  AliDragMenu
//
//  Created by hg w on 2017/2/16.
//  Copyright © 2017年 tton. All rights reserved.
//

import UIKit




class ViewController: UIViewController {
    
    var dataSource = Array<String>.init()
    var scrollView:UIScrollView?
    var menuView:MenuView?
    var menuViewOne:MenuView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        let leftBar = UIBarButtonItem.init(title: "添加", style: .done, target: self, action: #selector(clickLeftBarButton))
        self.navigationItem.leftBarButtonItem = leftBar
        
        let rightBarbutton = UIBarButtonItem.init(title: "编辑", style: .done, target: self, action: #selector(clickRightBarButton))
        self.navigationItem.rightBarButtonItem = rightBarbutton

        self.setupScrollView()
        
        menuView = MenuView.init(frame: CGRect.init(x: 0, y:0, width: self.view.frame.size.width, height: 300))
        menuView?.delegate = self
        menuView?.viewsArr = ["1", "2", "3"]
        menuView?.titleLabel.text = "我的应用"
        
        
        
        
        self.setupMenuViewOne()
        
        self.scrollView?.addSubview(menuView!)
        
        self.view.bringSubview(toFront: menuView!)
        

    }
    
    func setupScrollView() {
        scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        scrollView?.backgroundColor = UIColor.init(colorLiteralRed: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        self.view.addSubview(scrollView!)
    }
    
    
    func setupMenuViewOne() {
        menuViewOne = MenuView.init(frame: CGRect.init(x: 0, y: (menuView?.frame.origin.y)!+(menuView?.frame.size.height)!, width: self.view.frame.size.width, height: 300))
        menuViewOne?.delegate = self
        menuViewOne?.ifCanDrag = false
        menuViewOne?.iconBeginState = .ADD
        menuViewOne?.viewsArr = ["1", "2", "3", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
        menuViewOne?.titleLabel.text = "其他应用"
        menuViewOne?.compareArr = menuView?.viewsArr
        
        self.scrollView?.addSubview(menuViewOne!)
    }
    
    func clickLeftBarButton() {
//        menuView?.viewsArr?.append("\((menuView?.viewsArr?.count)!+1)")
//        menuViewOne?.compareArr = menuView?.viewsArr
    }
    
    func clickRightBarButton() {
        if self.navigationItem.rightBarButtonItem?.title == "编辑" {
            menuView?.ifShowEditButton = true
            menuViewOne?.ifShowEditButton = true
            self.navigationItem.rightBarButtonItem?.title = "完成"
        }else{
            menuView?.ifShowEditButton = false
            menuViewOne?.ifShowEditButton = false
            self.navigationItem.rightBarButtonItem?.title = "编辑"
        }
        
        
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:MenuViewDelegate {
    func updateDelegateFrame() {
        
        menuViewOne?.frame = CGRect.init(x: 0, y: (menuView?.frame.origin.y)!+(menuView?.frame.size.height)!+20, width: self.view.frame.size.width, height: (menuViewOne?.frame.size.height)!)
        
        if let height = menuViewOne?.frame.size.height {
            self.scrollView?.contentSize = CGSize.init(width: self.view.frame.size.width, height: (menuViewOne?.frame.origin.y)!+height)
        }
        
        print(menuView?.viewsArr)
        
        menuViewOne?.compareArr = menuView?.viewsArr
        
        
    }
    
    func addTitleToViewArrInDelegate(title:String) {
        menuView?.viewsArr?.append(title)
        
        menuViewOne?.compareArr = menuView?.viewsArr
    }
    
    
    
}


