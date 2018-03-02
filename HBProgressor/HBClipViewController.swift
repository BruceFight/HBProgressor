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
        view.backgroundColor = .white
        imageView.image = #imageLiteral(resourceName: "lufei")
        imageView.frame = view.bounds
        view.addSubview(imageView)

        shelterView = HBShelterView.init(frame: view.bounds)
        view.addSubview(shelterView)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

enum HBSkipInitialType {
    case topLeft
    case top
    case topRight
    case left
    case right
    case bottomLeft
    case bottom
    case bottomRight
}
class HBShelterView: UIView, CAAnimationDelegate {
    
    fileprivate var scopeBezierPath : UIBezierPath = UIBezierPath()
    fileprivate var clipBezierPath : UIBezierPath = UIBezierPath()
    fileprivate var scopeLayer : CAShapeLayer = CAShapeLayer()
    fileprivate var centerAnchorPoint : CGPoint = .zero
    fileprivate var previousTouchPoint : CGPoint = .zero
    fileprivate var currentTouchPoint : CGPoint = .zero
    
    fileprivate var assistBigView : UIView = UIView()
    fileprivate var assistSmallView : UIView = UIView()
    fileprivate var clipView : UIView = UIView()
    
    fileprivate var scopeLineWidth : CGFloat = 5
    fileprivate var scopeMarginWidth : CGFloat = 30
    fileprivate var skipInitialType : HBSkipInitialType?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        skipFrame = CGRect.init(x: (frame.width - 100) / 2, y: (frame.height - 100) / 2, width: 100, height: 100)
        centerAnchorPoint = CGPoint.init(x: frame.width / 2, y: frame.height / 2)
        setSkipFrame(frame: frame)
        
        scopeLayer.borderWidth = 0
        scopeLayer.lineWidth = scopeLineWidth
        scopeLayer.strokeColor = UIColor.blue.cgColor
        scopeLayer.fillColor = RGB(0x000000).cgColor
        scopeLayer.fillRule = "even-odd"
        scopeLayer.path = scopeBezierPath.cgPath
        scopeLayer.opacity = 0.5
        layer.addSublayer(scopeLayer)
        
        //assistBigView.backgroundColor = RGBA(0x00ff00, alpha: 0.5)
        assistBigView.backgroundColor = .clear
        addSubview(assistBigView)
        //assistSmallView.backgroundColor = RGBA(0x0000ff, alpha: 0.5)
        assistSmallView.backgroundColor = .clear
        addSubview(assistSmallView)
        
        clipView.backgroundColor = .clear
        clipView.layer.borderColor = UIColor.red.cgColor
        clipView.layer.borderWidth = scopeLineWidth
        addSubview(clipView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    fileprivate var kIfTouched : Bool = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let _touch = touches.first {
            currentTouchPoint = _touch.location(in: self)
            if assistBigView.frame.contains(currentTouchPoint) && !assistSmallView.frame.contains(currentTouchPoint) {
                kIfTouched = true
                /// 确定起始类型
                if currentTouchPoint.x <= assistSmallView.frame.minX {
                    if currentTouchPoint.y <= assistSmallView.frame.minY {
                        skipInitialType = .topLeft
                    }else if currentTouchPoint.y >= assistSmallView.frame.maxY {
                        skipInitialType = .bottomLeft
                    }else {
                        skipInitialType = .left
                    }
                }else if currentTouchPoint.x >= assistSmallView.frame.maxX {
                    if currentTouchPoint.y <= assistSmallView.frame.minY {
                        skipInitialType = .topRight
                    }else if currentTouchPoint.y >= assistSmallView.frame.maxY {
                        skipInitialType = .bottomRight
                    }else {
                        skipInitialType = .right
                    }
                }else if currentTouchPoint.y <= assistSmallView.frame.minY {
                    skipInitialType = .top
                }else {
                    skipInitialType = .bottom
                }
            }else {
                kIfTouched = false
            }
        }
    }
    
    fileprivate var skipFrame : CGRect = .zero
    //fileprivate let mostLargeMargin : CGFloat = 2 * (scopeMarginWidth + scopeLineWidth)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if !kIfTouched { return }
        let mostLargeMargin : CGFloat = 2 * (scopeMarginWidth + scopeLineWidth)
        if let _touch = touches.first,
        let _initialType = skipInitialType {
            previousTouchPoint = _touch.previousLocation(in: self)
            currentTouchPoint = _touch.location(in: self)
            
            let xDisValue : CGFloat = currentTouchPoint.x - previousTouchPoint.x
            let yDisValue : CGFloat = currentTouchPoint.y - previousTouchPoint.y
            
            switch _initialType {
            case .topLeft:
                if skipFrame.width - xDisValue < mostLargeMargin || skipFrame.height - yDisValue < mostLargeMargin {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x + xDisValue, y: skipFrame.origin.y + yDisValue, width: skipFrame.width - xDisValue, height: skipFrame.height - yDisValue)
                break
            case .top:
                if skipFrame.width < mostLargeMargin || skipFrame.height - yDisValue < mostLargeMargin {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y + yDisValue, width: skipFrame.width, height: skipFrame.height - yDisValue)
                break
            case .topRight:
                if skipFrame.width + xDisValue < mostLargeMargin || skipFrame.height - yDisValue < mostLargeMargin {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x + xDisValue, y: skipFrame.origin.y + yDisValue, width: skipFrame.width + xDisValue, height: skipFrame.height - yDisValue)
                break
            case .left:
                if skipFrame.width - xDisValue < mostLargeMargin || skipFrame.height < mostLargeMargin {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x + xDisValue, y: skipFrame.origin.y, width: skipFrame.width - xDisValue, height: skipFrame.height)
                break
            case .right:
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y, width: skipFrame.width + xDisValue, height: skipFrame.height)
                break
            case .bottomLeft:
                if skipFrame.width - xDisValue < mostLargeMargin || skipFrame.height + yDisValue < mostLargeMargin {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x + xDisValue, y: skipFrame.origin.y, width: skipFrame.width - xDisValue, height: skipFrame.height + yDisValue)
                break
            case .bottom:
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y, width: skipFrame.width, height: skipFrame.height + yDisValue)
                break
            case .bottomRight:
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y, width: skipFrame.width + xDisValue, height: skipFrame.height + yDisValue)
                break
            }
            
            var _width : CGFloat = skipFrame.width
            var _height : CGFloat = skipFrame.height
            if _width < mostLargeMargin {
                _width = mostLargeMargin
            }
            if _height < mostLargeMargin {
                _height = mostLargeMargin
            }
            skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y, width: _width, height: _height)
            setSkipFrame(frame: bounds)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        resetToCenter()
    }
    
    func setSkipFrame(frame: CGRect) -> () {
        clipViewLayer.frame = skipFrame
        clipBezierPath = UIBezierPath.init(rect: skipFrame)
        scopeBezierPath = UIBezierPath.init(rect: frame)
        scopeBezierPath.append(clipBezierPath)
        scopeBezierPath.usesEvenOddFillRule = true
        assistBigView.frame = CGRect.init(x: skipFrame.origin.x - scopeMarginWidth, y: skipFrame.origin.y - scopeMarginWidth, width: skipFrame.width + 2 * scopeMarginWidth, height: skipFrame.height + 2 * scopeMarginWidth)
        assistSmallView.frame = CGRect.init(x: skipFrame.origin.x + scopeMarginWidth + scopeLineWidth, y: skipFrame.origin.y + scopeMarginWidth + scopeLineWidth, width: skipFrame.width - 2 * (scopeMarginWidth + scopeLineWidth), height: skipFrame.height - 2 * (scopeMarginWidth + scopeLineWidth))
        clipView.frame = skipFrame
        scopeLayer.path = scopeBezierPath.cgPath
    }
    
    fileprivate var animationDuration : TimeInterval = 0.25
    func resetToCenter() -> () {
        skipFrame = CGRect.init(x: (bounds.width - skipFrame.width) / 2, y: (bounds.height - skipFrame.height) / 2, width: skipFrame.width, height: skipFrame.height)
        clipBezierPath = UIBezierPath.init(rect: skipFrame)
        scopeBezierPath = UIBezierPath.init(rect: bounds)
        scopeBezierPath.append(clipBezierPath)
        scopeBezierPath.usesEvenOddFillRule = true
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.assistBigView.frame = CGRect.init(x: self.skipFrame.origin.x - self.scopeMarginWidth, y: self.skipFrame.origin.y - self.scopeMarginWidth, width: self.skipFrame.width + 2 * self.scopeMarginWidth, height: self.skipFrame.height + 2 * self.scopeMarginWidth)
            self.assistSmallView.frame = CGRect.init(x: self.skipFrame.origin.x + self.scopeMarginWidth + self.scopeLineWidth, y: self.skipFrame.origin.y + self.scopeMarginWidth + self.scopeLineWidth, width: self.skipFrame.width - 2 * (self.scopeMarginWidth + self.scopeLineWidth), height: self.skipFrame.height - 2 * (self.scopeMarginWidth + self.scopeLineWidth))
            self.clipView.frame = self.skipFrame
        })
        let pathAnimation = CABasicAnimation.init(keyPath: "path")
        pathAnimation.toValue = scopeBezierPath.cgPath
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.duration = animationDuration
        pathAnimation.delegate = self
        scopeLayer.add(pathAnimation, forKey: "path_animation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let _anim = anim as? CABasicAnimation {
            if _anim.keyPath == "path" {
                scopeLayer.path = scopeBezierPath.cgPath
                scopeLayer.removeAllAnimations()
            }
        }
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

