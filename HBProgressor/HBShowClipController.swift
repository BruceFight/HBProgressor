//
//  HBShowClipController.swift
//  HBProgressor
//
//  Created by jianghongbao on 2018/3/3.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBShowClipController: UIViewController {

    var clipImage = UIImage()
    
    fileprivate var imageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageView.image = clipImage
        imageView.sizeToFit()
        imageView.frame = CGRect.init(x: (view.bounds.width - imageView.bounds.width) / 2, y: (view.bounds.height - imageView.bounds.height) / 2, width: imageView.bounds.width, height: imageView.bounds.height)
        view.addSubview(imageView)
        print("❤️ clipImage : \(clipImage)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
