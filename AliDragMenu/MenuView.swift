//
//  MenuView.swift
//  AliDragMenu
//
//  Created by hg w on 2017/2/16.
//  Copyright © 2017年 tton. All rights reserved.
//

import UIKit
//MARK:iconView状态的枚举,用来增加提示动画
enum TouchState {
    case UNTOUCHE
    case SUSPEND
    case MOVE
}

//MARK:menuView代理方法
protocol MenuViewDelegate {
    func updateDelegateFrame()
    func addTitleToViewArrInDelegate(iconView:IconAndTitleView)
}


//MARK:iconAndTitleView代理
extension MenuView:IconAndTitleViewDelegate {
    //TODO:点击添加
    func clickEditButtonOnIconInDelegate(iconView: IconAndTitleView) {
        self.delegate?.addTitleToViewArrInDelegate(iconView:iconView)
    }
    
    //TODO:点击删除
    func clickDeleteButtonOnIConInDelegate(iconView: IconAndTitleView) {
        
        //1.移除被删除iconView的标题,删除后自动执行viewArr的willSet方法
        viewsArr?.remove(at: (viewsArr?.index(where: { (element) -> Bool in
            return element == iconView.titleLabel.text!
        }))!)
        
        //2.记录被删除iconView的中心位置
        var preCenter = iconView.center
        
        //3.遍历iconView的数组,从被删除的iconView开始,依次前置
        var currentCenter:CGPoint?
        for i in iconView.tag-1000+1..<buttonArr.count{
            let nextIconView = buttonArr[i]
            currentCenter = nextIconView.center
            UIView.animate(withDuration: 0.3, animations: { 
                nextIconView.center = preCenter
            })
            
            preCenter = currentCenter!
            nextIconView.tag -= 1
            buttonArr[i-1] = nextIconView
        }
        
        //4.移除数组中被删除的iconView
        buttonArr.removeLast()
        
        //5.删除动画,更新控件的frame,并通知代理更新frame
        UIView.animate(withDuration: 0.3, animations: {
            iconView.transform = CGAffineTransform.init(scaleX: 0.05, y: 0.05)
        }) { (bool) in
            iconView.removeFromSuperview()
            let maxHeight:CGFloat = CGFloat((self.buttonArr.count-1)/4)
            
            self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: (maxHeight)*self.YGap+maxHeight*(self.viewHeight)+40+self.viewHeight+20)
            
            self.delegate?.updateDelegateFrame()
        }
        
        
    }
}



class MenuView: UIView {
    deinit {
        print("MenuView被释放")
    }
    
    //TODO:获取最后一个视图的下一个位置
    var lastNextCenter:CGPoint? {
        get {
            let maxHeight:CGFloat = CGFloat((self.buttonArr.count-1)/4)
            let maxYu = CGFloat((self.buttonArr.count-1)%4)
            return CGPoint.init(x: XGap*maxYu+XGap+viewWidth*maxYu+(viewWidth)/2, y: (maxHeight)*YGap+maxHeight*(viewHeight)+40+viewHeight/2)
        }
    }
    
    
    //TODO:比较数组,用于判断显示添加还是删除
    var compareArr:Array<String>? {
        willSet {
            for view in buttonArr {
                var ifAdded = false
                let iconAndTitleView = view as? IconAndTitleView
                for i in 0..<(newValue?.count)! {
                    let str = newValue![i]
                    if iconAndTitleView?.titleLabel.text == str {
                        ifAdded = true
                        break
                    }
                }
                
                if ifAdded {
                    iconAndTitleView?.editState = .ADDED
                }else{
                    iconAndTitleView?.editState = .ADD
                }
            }
        }
    }
    
    
    //TODO:初始化视图的数组
    var viewsArr:Array<String>? {
        willSet {
            let maxHeight = CGFloat(((newValue?.count)!-1)/4)
            let maxYu = CGFloat(((newValue?.count)!-1)%4)
            let lastStr = newValue?.last
            
            
            //只在数组初始化或增加数组的时候执行
            if let newValueCount = newValue?.count{
                
                let viewArrCount = viewsArr?.count ?? 0
                if newValueCount > viewArrCount {
                    if viewsArr?.count == nil {
                        for i in 0..<(newValue?.count)! {
                            
                            let yu:CGFloat = CGFloat(i%4)
                            let chu:CGFloat = CGFloat(i/4)
                            
                            let str = newValue?[i]
                            
                            let iconAndTitle = Bundle.main.loadNibNamed("IconAndTitleView", owner: nil, options: nil)?.last as! IconAndTitleView
                            
                            iconAndTitle.frame = CGRect.init(x: XGap*yu+XGap+viewWidth*yu, y: (chu)*YGap+chu*(viewHeight)+40, width: viewWidth, height: viewHeight)
                            iconAndTitle.tag = 1000+i
                            
                            iconAndTitle.backgroundColor = UIColor.cyan
                            iconAndTitle.titleLabel.text = str
                            iconAndTitle.editButton.isHidden = true
                            iconAndTitle.editState = iconBeginState
                            iconAndTitle.delegate = self
                            
                            if self.ifCanDrag {
                                let longGester = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(gester:)))
                                iconAndTitle.addGestureRecognizer(longGester)
                            }
                            self.buttonArr.append(iconAndTitle)
                            self.addSubview(iconAndTitle)
                        }
                    }else{
                        let iconAndTitle = Bundle.main.loadNibNamed("IconAndTitleView", owner: nil, options: nil)?.last as! IconAndTitleView
                        
                        iconAndTitle.frame = CGRect.init(x: XGap*maxYu+XGap+viewWidth*maxYu, y: (maxHeight)*YGap+maxHeight*(viewHeight)+40, width: viewWidth, height: viewHeight)
                        
                        iconAndTitle.backgroundColor = UIColor.cyan
                        iconAndTitle.titleLabel.text = lastStr
                        iconAndTitle.tag = ((newValue?.count)!-1)+1000
                        iconAndTitle.editState = iconBeginState
                        iconAndTitle.delegate = self
                        if ifShowEditButton {
                            iconAndTitle.editButton.isHidden = false
                        }else{
                            iconAndTitle.editButton.isHidden = true
                        }
                        
                        if self.ifCanDrag {
                            let longGester = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(gester:)))
                            iconAndTitle.addGestureRecognizer(longGester)
                        }
                        
                        self.addSubview(iconAndTitle)
                        self.buttonArr.append(iconAndTitle)
                        iconAndTitle.transform = CGAffineTransform.init(scaleX: 0.05, y: 0.05)
                        UIView.animate(withDuration: 0.3, animations: {
                            
                            iconAndTitle.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                            
                        }, completion: { (bool) in
                            
                        })
                        
                        
                    }
                    
                    
                    print(maxHeight)
                    self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: (maxHeight)*YGap+maxHeight*(viewHeight)+40+viewHeight+20)
                    
                    self.delegate?.updateDelegateFrame()
                }
            }
            
            
            
            
            
        }
    }
    
    
    //是否开始编辑
    var ifShowEditButton:Bool = false {
        willSet {
            //开始编辑
            if newValue {
                for i in 0..<buttonArr.count {
                    let iconView = buttonArr[i] as? IconAndTitleView
                    
                    iconView?.editButton.isHidden = false
                }
            }
                //结束编辑
            else{
                for i in 0..<buttonArr.count {
                    let iconView = buttonArr[i] as? IconAndTitleView
                    
                    iconView?.editButton.isHidden = true
                }
            }
        }
    }
    
    var titleLabel:UILabel!
    var XGap:CGFloat = 20
    var YGap:CGFloat = 15
    var viewWidth:CGFloat = 80
    
    
    var viewHeight:CGFloat = 0
    var delegate:MenuViewDelegate?
    var buttonArr = Array<UIView>.init()
    
    var pressButtonCenter:CGPoint?
    var startPos:CGPoint?
    var pressButtonTag:Int?
    
    var ifCanDrag = true
    var iconBeginState:IconViewState = .DEL

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.titleLabel = UILabel.init()
        self.titleLabel.frame = CGRect.init(x: 10, y: 0, width: frame.size.width, height: 40)
        if UIScreen.main.bounds.size.width == 320 {
            viewWidth = 60
        }
        
        viewHeight = viewWidth+25
        
        XGap = (UIScreen.main.bounds.size.width-4*viewWidth)/5
        
        if UIScreen.main.bounds.size.width == 414 {
            YGap = 40
        }else if UIScreen.main.bounds.size.width == 375 {
            YGap = 30
        }else{
            YGap = 30
        }
        
        
        
        self.addSubview(self.titleLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:--长按手势执行方法
    func handleLongPress(gester:UILongPressGestureRecognizer) {
        
        if ifShowEditButton {
            let pressOnButton = gester.view as? IconAndTitleView
            
            // self.delegate.bringSubview(toFront: self)
            
            switch gester.state {
            case .began:
                startPos = gester.location(in: gester.view)
                pressButtonCenter = pressOnButton?.center
                pressButtonTag = (pressOnButton?.tag)! - 1000
                
            case .changed:
                let newPoint = gester.location(in: gester.view)
                let offsetX = newPoint.x - (startPos?.x)!
                let offsetY = newPoint.y - (startPos?.y)!
                
                pressOnButton?.center = CGPoint.init(x: (pressOnButton?.center.x)!+offsetX, y: (pressOnButton?.center.y)!+offsetY)
                
                
                var willCrossTag = -1
                for i in 0..<self.buttonArr.count {
                    if pressOnButton != self.buttonArr[i] && self.buttonArr[i].frame.contains((pressOnButton?.center)!) {
                        willCrossTag = self.buttonArr[i].tag
                        
                        print(willCrossTag)
                        break
                    }
                }
                
                //分3种情况
                if willCrossTag != -1 {
                    
                    //被遮盖元素在被拖拽元素后一位
                    if willCrossTag - (pressOnButton?.tag)! == 1 {
                        let willPressButton = self.buttonArr[willCrossTag-1000]
                        let tempCenter = willPressButton.center
                        UIView.animate(withDuration: 0.3, animations: {
                            willPressButton.center = self.pressButtonCenter!
                            self.pressButtonCenter = tempCenter
                        })
                        
                        buttonArr[willCrossTag-1000] = pressOnButton!
                        buttonArr[(pressOnButton?.tag)!-1000] = willPressButton
                        
                        let tempID = willPressButton.tag
                        willPressButton.tag = (pressOnButton?.tag)!
                        pressOnButton?.tag = tempID
                        
                        
                    }
                    else if willCrossTag - (pressOnButton?.tag)! > 1 {
                        var preCenter = pressButtonCenter
                        var currentCenter:CGPoint?
                        
                        for i in (pressOnButton?.tag)!-1000+1...willCrossTag - 1000 {
                            print("i==\(i)")
                            
                            let willCrossView = buttonArr[i]
                            currentCenter = willCrossView.center
                            
                            UIView.animate(withDuration: 0.3, animations: {
                                willCrossView.center = preCenter!
                            })
                            
                            preCenter = currentCenter
                            willCrossView.tag = willCrossView.tag - 1
                            
                            buttonArr[i-1] = willCrossView
                        }
                        
                        
                        pressButtonCenter = preCenter
                        pressOnButton?.tag = willCrossTag
                        buttonArr[willCrossTag-1000] = pressOnButton!
                        
                    }else{
                        var preCenter = pressButtonCenter
                        var currentCenter:CGPoint?
                        
                        for i in (willCrossTag-1000...(pressOnButton?.tag)!-1000-1).reversed() {
                            let willCrossView = buttonArr[i]
                            currentCenter = willCrossView.center
                            UIView.animate(withDuration: 0.3, animations: {
                                willCrossView.center = preCenter!
                            })
                            
                            preCenter = currentCenter
                            willCrossView.tag += 1
                            buttonArr[i+1] = willCrossView
                            
                        }
                        
                        pressButtonCenter = preCenter
                        pressOnButton?.tag = willCrossTag
                        buttonArr[willCrossTag-1000] = pressOnButton!
                    }
                    
                }
            case .ended:
                
                UIView.animate(withDuration: 0.3, animations: { 
                    pressOnButton?.center = self.pressButtonCenter!
                })
                
                
                
            default:
                print("default")
                
            }
        }
    }
    
    //添加按钮
    func addtitleViewWith(title:String) {
        
        
    }
    
    

}
