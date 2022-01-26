//
//  JPCropViewController.swift
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2021/4/17.
//  Copyright © 2021 ZhouJianPing. All rights reserved.
//

import UIKit
import JPCrop
import JPImageresizerView

@objcMembers class JPCropViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var rotateLeftBtn: UIButton!
    @IBOutlet weak var rotateRightBtn: UIButton!
    @IBOutlet weak var recoveryBtn: UIButton!
    @IBOutlet weak var operationView: UIView!
    
    private(set) var isCroper: Bool = true
    private var croper: Croper? = nil
    private var imageresizerView: JPImageresizerView? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageName = "Girl\(1 + arc4random_uniform(8)).jpg"
        guard let path = Bundle.main.path(forResource: imageName, ofType: nil),
              let image = UIImage(contentsOfFile: path)
        else {
            JPProgressHUD.showError(withStatus: "图片不存在", userInteractionEnabled: true)
            return
        }
        
        let cropFrame = CGRect(x: 0,
                               y: JPConstant.statusBarH(),
                               width: JPConstant.portraitScreenWidth(),
                               height: JPConstant.portraitScreenHeight() - JPConstant.statusBarH() - JPConstant.diffTabBarH() - 100)
        
        if isCroper {
            setupCroper(image, frame: cropFrame)
        } else {
            setupImageresizerView(image, frame: cropFrame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - 工厂
    class func build(forCroper isCroper: Bool) -> Self {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JPCropViewController") as! Self
        vc.isCroper = isCroper
        return vc
    }
    
    // MARK: - 裁剪后跳转
    private func jumpToPreviewViewController(_ originResult: JPImageresizerResult, fragmentResults: [JPImageresizerResult]? = nil, columnCount: Int = 0, rowCount: Int = 0) {
        guard let navCtr = navigationController else { return }
        
        var results = [originResult]
        if let fragmentResults = fragmentResults, fragmentResults.count > 0 {
            results.append(contentsOf: fragmentResults)
        }
        
        let previewVC = JPPreviewViewController.build(with: results, columnCount: columnCount, rowCount: rowCount)
        navCtr.pushViewController(previewVC, animated: true)
    }
}

extension JPCropViewController {
    // MARK: - 使用JPCroper
    func setupCroper(_ image: UIImage, frame: CGRect) {
        rotateLeftBtn.isHidden = true
        rotateRightBtn.isHidden = true
        slider.addTarget(self, action: #selector(beginSlider), for: .touchDown)
        slider.addTarget(self, action: #selector(sliding), for: .valueChanged)
        slider.addTarget(self, action: #selector(endSlider), for: .touchCancel)
        slider.addTarget(self, action: #selector(endSlider), for: .touchUpInside)
        slider.addTarget(self, action: #selector(endSlider), for: .touchUpOutside)
        
        // 1.初始配置
        let configure = Configure(image)
        
        // 2.创建croper
        let croper = Croper(frame: frame, configure)
        // 当设置裁剪宽高比超出可设置范围时的回调
        croper.cropWHRatioRangeOverstep = { isUpper, _ in
            JPProgressHUD.showInfo(withStatus: isUpper ? "最大裁剪宽高比是 2 : 1" : "最小裁剪宽高比是 3 : 4",
                                   userInteractionEnabled: true)
        }
        
        // 3.添加到视图上
        view.insertSubview(croper, at: 0)
        self.croper = croper
        
        slider.value = Float(configure.radian / Croper.radianRange.upperBound)
    }
    
    // MARK: - 使用JPImageresizerView
    func setupImageresizerView(_ image: UIImage, frame: CGRect) {
        slider.isHidden = true
        rotateLeftBtn.addTarget(self, action: #selector(rotateLeft), for: .touchUpInside)
        rotateRightBtn.addTarget(self, action: #selector(rotateRight), for: .touchUpInside)
        
        // 1.初始配置
        let configure = JPImageresizerConfigure.defaultConfigure(with: image) { c in
            _ = c
                .jp_viewFrame(frame)
                .jp_bgColor(.black)
                .jp_frameType(.classicFrameType)
                .jp_contentInsets(.init(top: 16, left: 16, bottom: 16, right: 16))
                .jp_animationCurve(.easeInOut)
        }
        
        // 2.创建imageresizerView
        let imageresizerView = JPImageresizerView(configure: configure) { [weak self] isCanRecovery in
            // 当不需要重置设置按钮不可点
            self?.recoveryBtn.isEnabled = isCanRecovery
        } imageresizerIsPrepareToScale: { [weak self] isPrepareToScale in
            // 当预备缩放设置按钮不可点，结束后可点击
            self?.operationView.isUserInteractionEnabled = !isPrepareToScale
        }
        
        // 3.添加到视图上
        view.insertSubview(imageresizerView, at: 0)
        self.imageresizerView = imageresizerView
    }
}

// MARK: - 监听Slider（旋转）
extension JPCropViewController {
    @objc func beginSlider() {
        croper?.showRotateGrid(animated: true)
    }
    
    @objc func sliding() {
        guard let croper = croper else { return }
        let radian = CGFloat(slider.value) * Croper.radianRange.upperBound
        croper.updateRadian(radian)
    }
    
    @objc func endSlider() {
        croper?.hideRotateGrid(animated: true)
    }
}

// MARK: - 监听Button（旋转）
extension JPCropViewController {
    @objc func rotateLeft() {
        imageresizerView?.isClockwiseRotation = false
        imageresizerView?.rotation()
    }
    
    @objc func rotateRight() {
        imageresizerView?.isClockwiseRotation = true
        imageresizerView?.rotation()
    }
}

// MARK: - 监听返回/恢复/裁剪事件
extension JPCropViewController {
    @IBAction func goBack() {
        guard let navCtr = navigationController else { return }
        
        let transition = CATransition()
        transition.type = .init(rawValue: "cube")
        transition.subtype = .fromLeft
        transition.duration = 0.45
        transition.timingFunction = .init(name: .easeInEaseOut)
        navCtr.view.layer.add(transition, forKey: "cube")
        
        if navCtr.viewControllers.count <= 1 {
            dismiss(animated: false, completion: nil)
        } else {
            navCtr.popViewController(animated: false)
        }
    }
    
    @IBAction func recover() {
        if let imageresizerView = self.imageresizerView {
            imageresizerView.recovery()
            return
        }
        
        guard let croper = croper else { return }
        croper.recover(animated: true)
        slider.setValue(0, animated: true)
    }
    
    @IBAction func crop() {
        if !isCroper {
            let alertCtr = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertCtr.addAction(.init(title: "直接裁剪", style: .default, handler: { [weak self] _ in
                guard let self = self, let imageresizerView = self.imageresizerView else { return }
                
                JPProgressHUD.show()
                imageresizerView.cropPicture(withCacheURL: nil) { _, _ in
                    JPProgressHUD.showError(withStatus: "裁剪失败",
                                            userInteractionEnabled: true)
                } complete: { [weak self] in
                    guard let self = self else { return }
                    guard let result = $0 else {
                        JPProgressHUD.showError(withStatus: "裁剪失败",
                                                userInteractionEnabled: true)
                        return
                    }
                    JPProgressHUD.dismiss()
                    self.jumpToPreviewViewController(result)
                }
                
            }))
            alertCtr.addAction(.init(title: "裁剪九宫格", style: .default, handler: { [weak self] _ in
                guard let self = self, let imageresizerView = self.imageresizerView else { return }
                
                JPProgressHUD.show()
                imageresizerView.cropNineGirdPictures(withCompressScale: 1, bgColor: nil, cacheURL: nil) { _, _ in
                    JPProgressHUD.showError(withStatus: "裁剪失败",
                                            userInteractionEnabled: true)
                } complete: { [weak self] originResult, fragmentResults, cols, rows in
                    guard let self = self else { return }
                    guard let originResult = originResult,
                          let fragmentResults = fragmentResults else {
                        JPProgressHUD.showError(withStatus: "裁剪失败",
                                                userInteractionEnabled: true)
                        return
                    }
                    JPProgressHUD.dismiss()
                    self.jumpToPreviewViewController(originResult,
                                                     fragmentResults: fragmentResults,
                                                     columnCount: cols,
                                                     rowCount: rows)
                }
                
            }))
            alertCtr.addAction(.init(title: "取消", style: .cancel, handler: nil))
            present(alertCtr, animated: true, completion: nil)
            return
        }
        
        guard let croper = croper else { return }
        
        JPProgressHUD.show()
        croper.asyncCrop { [weak self] in
            guard let self = self else { return }
            guard let image = $0 else {
                JPProgressHUD.showError(withStatus: "裁剪失败",
                                        userInteractionEnabled: true)
                return
            }
            JPProgressHUD.dismiss()
            self.jumpToPreviewViewController(JPImageresizerResult(image: image, cacheURL: nil))
        }
    }
}

// MARK: - 监听比例切换事件
extension JPCropViewController {
    @IBAction func originWHRatio() {
        imageresizerView?.resizeWHScale = 0
        croper?.updateCropWHRatio(0, rotateGridCount: (5, 5), animated: true)
    }
    
    @IBAction func three2four() {
        imageresizerView?.resizeWHScale = 3.0 / 4.0
        croper?.updateCropWHRatio(3.0 / 4.0, rotateGridCount: (6, 5), animated: true)
    }
    
    @IBAction func one2one() {
        imageresizerView?.resizeWHScale = 1
        croper?.updateCropWHRatio(1, rotateGridCount: (4, 4), animated: true)
    }
    
    @IBAction func four2three() {
        imageresizerView?.resizeWHScale = 4.0 / 3.0
        croper?.updateCropWHRatio(4.0 / 3.0, rotateGridCount: (4, 5), animated: true)
    }
}
