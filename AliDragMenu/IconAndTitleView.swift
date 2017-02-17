//
//  IconAndTitleView.swift
//  AliDragMenu
//
//  Created by hg w on 2017/2/16.
//  Copyright © 2017年 tton. All rights reserved.
//

import UIKit

@objc protocol IconAndTitleViewDelegate {
    @objc func clickEditButtonOnIconInDelegate(iconView:IconAndTitleView)
    @objc func clickDeleteButtonOnIConInDelegate(iconView:IconAndTitleView)
}

enum IconViewState {
    case DEL
    case ADD
    case ADDED
}

class IconAndTitleView: UIView {
    
    var delegate:IconAndTitleViewDelegate?

    var editState:IconViewState = .DEL {
        willSet {
            switch newValue {
            case .DEL:
                self.editButton.backgroundColor = UIColor.red
            case .ADD:
                self.editButton.backgroundColor = UIColor.green
            case .ADDED:
                self.editButton.backgroundColor = UIColor.gray
                
            }
        }
    }
    @IBOutlet var editButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBAction func clickButton(_ sender: Any) {
        
        if self.editState == .DEL{
            self.delegate?.clickDeleteButtonOnIConInDelegate(iconView: self)
        }else if self.editState == .ADD{
            self.delegate?.clickEditButtonOnIconInDelegate(iconView: self)
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
