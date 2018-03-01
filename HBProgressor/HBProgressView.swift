//
//  HBProgressView.swift
//  circleSector
//
//  Created by jianghongbao on 2018/2/28.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBProgressView: UIView {

    fileprivate var scopeLayer : CAShapeLayer = CAShapeLayer()
    fileprivate var aimLayer : CAShapeLayer = CAShapeLayer()
    fileprivate var transLayer : CAShapeLayer = CAShapeLayer()
    fileprivate var totalDegree : CGFloat = CGFloat.pi * 2
    
    /// 开始位置
    public var startAngle : CGFloat = -CGFloat.pi / 2
    /// 遮罩色
    public var maskColor : UIColor = .black {
        didSet{
            aimLayer.fillColor = maskColor.cgColor
        }
    }
    /// 渲染色
    public var renderColor : UIColor = .white {
        didSet{
            scopeLayer.fillColor = renderColor.cgColor
            transLayer.fillColor = renderColor.cgColor
        }
    }
    /// 圆边宽度
    public var scopeLineWidth : CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        scopeLayer.strokeColor = UIColor.clear.cgColor
        scopeLayer.fillColor = renderColor.cgColor
        layer.addSublayer(scopeLayer)
        
        aimLayer.strokeColor = UIColor.clear.cgColor
        aimLayer.fillColor = maskColor.cgColor
        layer.addSublayer(aimLayer)
        
        transLayer.strokeColor = UIColor.clear.cgColor
        transLayer.fillColor = renderColor.cgColor
        layer.addSublayer(transLayer)
    }
    
    /** 指代范围
     - progress: indicator the interface-scope between 0 and 1
     */
    func setScopeProgress(progress: CGFloat) -> () {
        if progress > 1 { return }
        let bezierPath = UIBezierPath.init()
        let _center : CGPoint = CGPoint.init(x: bounds.width / 2, y: bounds.height / 2)
        let _radius : CGFloat = min(bounds.width, bounds.height) / 2
        bezierPath.move(to: CGPoint.init(x: _center.x + _radius, y: _center.y))
        bezierPath.addArc(withCenter: _center, radius: _radius, startAngle: 0, endAngle: totalDegree, clockwise: true)
        scopeLayer.path = bezierPath.cgPath
    }
    
    /** 目标范围
     */
    func setAnimProgress() -> () {
        let bezierPath = UIBezierPath.init()
        let _center : CGPoint = CGPoint.init(x: bounds.width / 2, y: bounds.height / 2)
        let _radius : CGFloat = min(bounds.width, bounds.height) / 2 - scopeLineWidth
        bezierPath.move(to: CGPoint.init(x: _center.x + _radius, y: _center.y))
        bezierPath.addArc(withCenter: _center, radius: _radius, startAngle: 0, endAngle: totalDegree, clockwise: true)
        aimLayer.path = bezierPath.cgPath
    }
    
    /** 加载范围
     - progress: indicator the loaded-scope between 0 and 1
     */
    func setTransProgress(progress: CGFloat) -> () {
        if progress > 1 { return }
        let bezierPath = UIBezierPath.init()
        let _center : CGPoint = CGPoint.init(x: bounds.width / 2, y: bounds.height / 2)
        let _radius : CGFloat = min(bounds.width, bounds.height) / 2
        bezierPath.move(to: CGPoint.init(x: _center.x , y: _center.y))
        bezierPath.addArc(withCenter: _center, radius: _radius, startAngle: startAngle, endAngle: totalDegree * progress + startAngle, clockwise: true)
        transLayer.path = bezierPath.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
