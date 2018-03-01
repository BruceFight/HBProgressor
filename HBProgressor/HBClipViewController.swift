//
//  HBClipViewController.swift
//  HBProgressor
//
//  Created by jianghongbao on 2018/3/1.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBClipViewController: UIViewController {

    fileprivate var imageView = UIImageView()
    fileprivate var shelterView = HBShelterView()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = #imageLiteral(resourceName: "lufei")
        imageView.frame = view.bounds
        view.addSubview(imageView)
        
        shelterView.frame = view.bounds
        view.addSubview(shelterView)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


class HBShelterView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = RGBA(0x000000, alpha: 0.3)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



/**
 RGBA颜色
 
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 - parameter alpha:      透明度值
 
 - returns: 相应颜色
 */
func RGBA(_ colorValue: UInt32, alpha: CGFloat) -> UIColor {
    
    return UIColor.init(red: CGFloat((colorValue>>16)&0xFF)/256.0, green: CGFloat((colorValue>>8)&0xFF)/256.0, blue: CGFloat((colorValue)&0xFF)/256.0 , alpha: alpha)
}

/**
 RGB颜色
 
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 
 - returns: 相应颜色
 */
func RGB(_ colorValue: UInt32) -> UIColor {
    return RGBA(colorValue, alpha: 1.0)
}

