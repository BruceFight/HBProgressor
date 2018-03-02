//
//  ViewController.swift
//  HBProgressor
//
//  Created by jianghongbao on 2018/3/1.
//  Copyright © 2018年 HonBoom. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    
    fileprivate var timer = Timer()
    fileprivate var progress : CGFloat = 0
    fileprivate var progressView = HBProgressView()
    fileprivate var backImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        backImageView.image = #imageLiteral(resourceName: "back")
        backImageView.sizeToFit()
        backImageView.frame = CGRect.init(x: (view.bounds.width - 200) / 2, y: (view.bounds.height - 200) / 2, width: 200, height: 200)
        view.addSubview(backImageView)
        
        progressView = HBProgressView.init(frame: CGRect.init(x: (view.bounds.width - 41) / 2, y: (view.bounds.height - 41) / 2, width: 41, height: 41))
        progressView.setScopeProgress(progress: 1)
        progressView.setAnimProgress()
        progressView.setTransProgress(progress: 0)
        view.addSubview(progressView)
        
        let startButton = UIButton.init(frame: CGRect.init(x: 0, y: 100, width: 100, height: 30))
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.red, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        view.addSubview(startButton)
        
        let toClipButton = UIButton.init(frame: CGRect.init(x: startButton.frame.maxX + 30, y: 100, width: 100, height: 30))
        toClipButton.setTitle("ToClip", for: .normal)
        toClipButton.setTitleColor(UIColor.red, for: .normal)
        toClipButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        toClipButton.addTarget(self, action: #selector(toClipVc), for: .touchUpInside)
        view.addSubview(toClipButton)
    }
    
    @objc func start() -> () {
        /// 1% CPU occupied for timer
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() -> () {
        progress += 0.02
        if progress >= 1 {
            progress = 1
        }
        progressView.setTransProgress(progress: progress)
        
        if progress >= 1 {
            timer.invalidate()
        }
    }
    
    @objc func toClipVc() -> () {
        let clipVc = HBClipViewController()
        self.navigationController?.pushViewController(clipVc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


