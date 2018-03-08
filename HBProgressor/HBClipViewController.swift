//
//  HBClipViewController.swift
//  HBProgressor
//
//  Created by jianghongbao on 2018/3/1.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBClipViewController: UIViewController {
    
    fileprivate var shelterView = HBShelterView()
    private let rephotographButton: UIButton = UIButton()
    private let implementLabel : UILabel = UILabel()
    let confirmButton: UIButton = UIButton()
    private let rephotographButtonSize = CGSize.init(width: 62, height: 40)
    private let confirmButtonSize = CGSize.init(width: 66, height: 66)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            
        }else {
            automaticallyAdjustsScrollViewInsets = false
        }
        shelterView = HBShelterView.init(frame: view.bounds)
        view.addSubview(shelterView)
        
        rephotographButton.setTitle("返回", for: .normal)
        rephotographButton.setTitleColor(.white, for: .normal)
        rephotographButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rephotographButton.addTarget(self, action: #selector(rephotographButtonClick), for: .touchUpInside)
        rephotographButton.sizeToFit()
        rephotographButton.frame = CGRect.init(x: 24, y: view.bounds.height - 68, width: 62, height: 40)
        view.addSubview(rephotographButton)
        
        confirmButton.setTitleColor(.green, for: .normal)
        confirmButton.setTitle("确定", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonClick), for: .touchUpInside)
        confirmButton.sizeToFit()
        confirmButton.frame = CGRect.init(x: 0, y: 0, width: confirmButton.bounds.width, height: confirmButton.bounds.height)
        confirmButton.center.x = view.center.x
        confirmButton.center.y = rephotographButton.center.y
        view.addSubview(confirmButton)
        
        implementLabel.text = "一次只能上传一道题目"
        implementLabel.textColor = HB_CLIPRGB(0xFFFFFF)
        implementLabel.textAlignment = .center
        implementLabel.font = UIFont.systemFont(ofSize: 13)
        implementLabel.backgroundColor = .clear
        implementLabel.sizeToFit()
        implementLabel.frame = CGRect.init(x: 0, y: view.bounds.height - 109, width: implementLabel.bounds.width, height: 13)
        implementLabel.center.x = view.center.x
        view.addSubview(implementLabel)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// 确定
    @objc func confirmButtonClick() -> () {
        let showVc = HBShowClipController()
        showVc.clipImage = shelterView.clipImage()
        self.navigationController?.pushViewController(showVc, animated: true)
    }
    
    /// 重拍
    @objc func rephotographButtonClick() -> () {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
/** operation scope
 */
class HBShelterView: UIView, UIScrollViewDelegate {
    
    fileprivate var centerAnchorPoint : CGPoint = .zero
    fileprivate var previousTouchPoint : CGPoint = .zero
    fileprivate var currentTouchPoint : CGPoint = .zero
    fileprivate var activityScrollView : UIScrollView = UIScrollView()
    fileprivate var _imageView = UIImageView()
    fileprivate var assistBigView : UIView = UIView()
    fileprivate var assistSmallView : UIView = UIView()
    fileprivate var clipView : HBClipView = HBClipView()
    
    fileprivate var scopeLineWidth : CGFloat = 5
    fileprivate var scopeMarginWidth : CGFloat = 20
    fileprivate var skipInitialType : HBSkipInitialType?
    fileprivate var totalScale : CGFloat = 1
    fileprivate var animationDuration : TimeInterval = 0.25
    
    var mostSmallWidth : CGFloat = 50
    var mostSmallHeight : CGFloat = 50
    var remainBottomHeight : CGFloat = 96.0
    var skipScopeToBorderMargin : CGFloat = 15.0
    var image : UIImage = #imageLiteral(resourceName: "Test7") {
        didSet{
            _imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        backgroundColor = HB_CLIPRGB(0x000000)
        
        let initialImageFrame : CGRect = CGRect.init(x: 34, y: skipScopeToBorderMargin, width: frame.width - 68, height: frame.height - remainBottomHeight - skipScopeToBorderMargin)
        activityScrollView.frame = bounds
        _imageView.frame = initialImageFrame
        _imageView.image = image
        if #available(iOS 11.0, *) {
            activityScrollView.contentInsetAdjustmentBehavior = .never
        }
        activityScrollView.minimumZoomScale = 0.5
        activityScrollView.maximumZoomScale = 2.5
        activityScrollView.delegate = self
        _imageView.isUserInteractionEnabled = true
        activityScrollView.addSubview(_imageView)
        addSubview(activityScrollView)
        
        skipFrame = CGRect.init(x: 34, y: (frame.height - remainBottomHeight - 160) / 2, width: frame.width - 68, height: 160)
        centerAnchorPoint = CGPoint.init(x: frame.width / 2, y: frame.height / 2)
        setSkipFrame(frame: frame)
        
        //assistBigView.backgroundColor = RGBA(0x00ff00, alpha: 0.5)
        assistBigView.backgroundColor = .clear
        addSubview(assistBigView)
        //assistSmallView.backgroundColor = RGBA(0x0000ff, alpha: 0.5)
        assistSmallView.backgroundColor = .clear
        addSubview(assistSmallView)
        
        clipView.backgroundColor = .clear
        addSubview(clipView)
    }
    
    fileprivate var kIfTouched : Bool = false
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
        currentTouchPoint = point
        if assistBigView.frame.contains(point) && !assistSmallView.frame.contains(point) {
            kIfTouched = true
            return clipView
        }else {
            kIfTouched = false
            return activityScrollView
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let _ = touches.first {
            if kIfTouched {
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
            }
        }
    }
    
    fileprivate var skipFrame : CGRect = .zero
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if !kIfTouched { return }
        //let mostSmallMargin : CGFloat = 50//2 * (scopeMarginWidth + scopeLineWidth)
        let mostLargeHeight : CGFloat = bounds.height - remainBottomHeight - skipScopeToBorderMargin
        let mostLargeWidth : CGFloat = bounds.width - 2 * skipScopeToBorderMargin
        if let _touch = touches.first,
            let _initialType = skipInitialType {
            previousTouchPoint = _touch.previousLocation(in: self)
            currentTouchPoint = _touch.location(in: self)
            
            let xDisValue : CGFloat = currentTouchPoint.x - previousTouchPoint.x
            let yDisValue : CGFloat = currentTouchPoint.y - previousTouchPoint.y
            
            switch _initialType {
            case .topLeft:
                if skipFrame.width - xDisValue < mostSmallWidth || skipFrame.height - yDisValue < mostSmallHeight || skipFrame.origin.y <= 15  {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x + xDisValue, y: skipFrame.origin.y + yDisValue, width: skipFrame.width - xDisValue, height: skipFrame.height - yDisValue)
                break
            case .top:
                if skipFrame.width < mostSmallWidth || skipFrame.height - yDisValue < mostSmallHeight || skipFrame.origin.y <= 15 {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y + yDisValue, width: skipFrame.width, height: skipFrame.height - yDisValue)
                break
            case .topRight:
                if skipFrame.width + xDisValue < mostSmallWidth || skipFrame.height - yDisValue < mostSmallHeight || skipFrame.origin.y <= 15 {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y + yDisValue, width: skipFrame.width + xDisValue, height: skipFrame.height - yDisValue)
                break
            case .left:
                if skipFrame.width - xDisValue < mostSmallWidth || skipFrame.height < mostSmallHeight {
                    break
                }
                skipFrame = CGRect.init(x: skipFrame.origin.x + xDisValue, y: skipFrame.origin.y, width: skipFrame.width - xDisValue, height: skipFrame.height)
                break
            case .right:
                skipFrame = CGRect.init(x: skipFrame.origin.x, y: skipFrame.origin.y, width: skipFrame.width + xDisValue, height: skipFrame.height)
                break
            case .bottomLeft:
                if skipFrame.width - xDisValue < mostSmallWidth || skipFrame.height + yDisValue < mostSmallHeight {
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
            var _origin : CGPoint = skipFrame.origin
            /// 最小范围
            if _width < mostSmallWidth {
                _width = mostSmallWidth
            }
            if _height < mostSmallHeight {
                _height = mostSmallHeight
            }
            /// 最大范围
            if _width > mostLargeWidth {
                _width = mostLargeWidth
            }
            if _height > mostLargeHeight {
                _height = mostLargeHeight
            }
            /// 原点
            if _origin.y < skipScopeToBorderMargin {
                _origin.y = skipScopeToBorderMargin
            }
            if _origin.x < skipScopeToBorderMargin {
                _origin.x = skipScopeToBorderMargin
            }
            skipFrame = CGRect.init(x: _origin.x, y: _origin.y, width: _width, height: _height)
            setSkipFrame(frame: bounds)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        resetToCenter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Methods
extension HBShelterView {
    func setSkipFrame(frame: CGRect) -> () {
        assistBigView.frame = CGRect.init(x: skipFrame.origin.x - scopeMarginWidth, y: skipFrame.origin.y - scopeMarginWidth, width: skipFrame.width + 2 * scopeMarginWidth, height: skipFrame.height + 2 * scopeMarginWidth)
        assistSmallView.frame = CGRect.init(x: skipFrame.origin.x + scopeMarginWidth + scopeLineWidth, y: skipFrame.origin.y + scopeMarginWidth + scopeLineWidth, width: skipFrame.width - 2 * (scopeMarginWidth + scopeLineWidth), height: skipFrame.height - 2 * (scopeMarginWidth + scopeLineWidth))
        clipView.frame = skipFrame
    }
    
    func resetToCenter() -> () {
        skipFrame = CGRect.init(x: (bounds.width - skipFrame.width) / 2, y: (bounds.height - remainBottomHeight - skipFrame.height + skipScopeToBorderMargin) / 2, width: skipFrame.width, height: skipFrame.height)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.assistBigView.frame = CGRect.init(x: self.skipFrame.origin.x - self.scopeMarginWidth, y: self.skipFrame.origin.y - self.scopeMarginWidth, width: self.skipFrame.width + 2 * self.scopeMarginWidth, height: self.skipFrame.height + 2 * self.scopeMarginWidth)
            self.assistSmallView.frame = CGRect.init(x: self.skipFrame.origin.x + self.scopeMarginWidth + self.scopeLineWidth, y: self.skipFrame.origin.y + self.scopeMarginWidth + self.scopeLineWidth, width: self.skipFrame.width - 2 * (self.scopeMarginWidth + self.scopeLineWidth), height: self.skipFrame.height - 2 * (self.scopeMarginWidth + self.scopeLineWidth))
            self.clipView.frame = self.skipFrame
        })
    }
    
    func clipImage() -> UIImage {
        var _clipImage = UIImage()
        UIGraphicsBeginImageContext(CGSize.init(width: bounds.width, height: bounds.height))
        if let currentContext = UIGraphicsGetCurrentContext() {
            layer.render(in: currentContext)
        }
        if let result = UIGraphicsGetImageFromCurrentImageContext() {
            _clipImage = result
        }
        UIGraphicsEndImageContext()
        
        if let sourceImageRef = _clipImage.cgImage {
            if let cgImage = sourceImageRef.cropping(to: clipView.frame) {
                _clipImage = UIImage.init(cgImage: cgImage)
            }
        }
        return _clipImage
    }
}

//MARK: - UIScrollView Delegate
extension HBShelterView {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 延中心点缩放
        var rect = _imageView.frame
        rect.origin.x = 0
        rect.origin.y = 0
        
        let widthDisRatio = (self.frame.width - rect.size.width) / 2.0
        let heightDisRatio = (self.frame.height - rect.size.height) / 2.0
        
        if (rect.size.width < self.frame.width) {
            rect.origin.x = CGFloat(floorf(Float(widthDisRatio)))
        }
        if (rect.size.height < self.frame.height) {
            rect.origin.y = CGFloat(floorf(Float(heightDisRatio)))
        }
        
        _imageView.frame = rect
    }
}

/** indicate the clip scope
 */
class HBClipView: UIView {
    
    fileprivate var scopeBezierPath : UIBezierPath = UIBezierPath()
    fileprivate var clipBezierPath : UIBezierPath = UIBezierPath()
    fileprivate var scopeLayer : CAShapeLayer = CAShapeLayer()
    fileprivate var scopeImageView : UIImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        scopeLayer.borderWidth = 0
        scopeLayer.lineWidth = 0
        scopeLayer.strokeColor = UIColor.clear.cgColor
        scopeLayer.fillColor = HB_CLIPRGB(0x000000).cgColor
        scopeLayer.fillRule = "even-odd"
        scopeLayer.path = scopeBezierPath.cgPath
        scopeLayer.opacity = 0.5
        layer.addSublayer(scopeLayer)
        let _image = #imageLiteral(resourceName: "photograph_clip").stretchableImage(withLeftCapWidth: Int(#imageLiteral(resourceName: "photograph_clip").size.width * 0.5), topCapHeight: Int(#imageLiteral(resourceName: "photograph_clip").size.height * 0.5))
        scopeImageView.image = _image
        scopeImageView.contentMode = .scaleToFill
        addSubview(scopeImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scopeImageView.frame = CGRect.init(x: -3, y: -3, width: bounds.width + 6, height: bounds.height + 6)
        
        let wholeRect = CGRect.init(x: -UIScreen.main.bounds.width, y: -UIScreen.main.bounds.height, width: 2 * UIScreen.main.bounds.width, height: 2 * UIScreen.main.bounds.height)
        clipBezierPath = UIBezierPath.init(rect: wholeRect)
        scopeBezierPath = UIBezierPath.init(rect: bounds)
        scopeBezierPath.append(clipBezierPath)
        scopeBezierPath.usesEvenOddFillRule = true
        scopeLayer.path = scopeBezierPath.cgPath
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



/** RGBA颜色
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 - parameter alpha: 透明度值
 - returns: 相应颜色
 */
func HB_CLIPRGBA(_ colorValue: UInt32, alpha: CGFloat) -> UIColor {
    
    return UIColor.init(red: CGFloat((colorValue>>16)&0xFF)/256.0, green: CGFloat((colorValue>>8)&0xFF)/256.0, blue: CGFloat((colorValue)&0xFF)/256.0 , alpha: alpha)
}

/** RGB颜色
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 - returns: 相应颜色
 */
func HB_CLIPRGB(_ colorValue: UInt32) -> UIColor {
    return HB_CLIPRGBA(colorValue, alpha: 1.0)
}

