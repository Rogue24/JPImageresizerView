//
//  JPCropViewController.swift
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2021/4/17.
//  Copyright © 2021 ZhouJianPing. All rights reserved.
//

import UIKit
import JPCrop

@objcMembers class JPCropViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    private var croper: Croper? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageName = "Girl\(1 + arc4random_uniform(8)).jpg"
        guard let path = Bundle.main.path(forResource: imageName, ofType: nil),
              let image = UIImage(contentsOfFile: path)
        else {
            JPProgressHUD.showError(withStatus: "图片不存在", userInteractionEnabled: true)
            return
        }
        
        let croperFrame = CGRect(x: 0, y: JPConstant.statusBarH(),
                                 width: JPConstant.portraitScreenWidth(),
                                 height: JPConstant.portraitScreenHeight() - JPConstant.statusBarH() - JPConstant.diffTabBarH() - 100)
        let configure = Configure(image)
        let croper = Croper(frame: croperFrame, configure)
        view.insertSubview(croper, at: 0)
        self.croper = croper
        croper.cropWHRatioRangeOverstep = { isUpper, _ in
            JPProgressHUD.showInfo(withStatus: isUpper ? "最大裁剪宽高比是 2 : 1" : "最小裁剪宽高比是 3 : 4",
                                   userInteractionEnabled: true)
        }
        
        slider.value = Float(configure.radian / Croper.radianRange.upperBound)
        slider.addTarget(self, action: #selector(beginSlider), for: .touchDown)
        slider.addTarget(self, action: #selector(sliding), for: .valueChanged)
        slider.addTarget(self, action: #selector(endSlider), for: .touchCancel)
        slider.addTarget(self, action: #selector(endSlider), for: .touchUpInside)
        slider.addTarget(self, action: #selector(endSlider), for: .touchUpOutside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

// MARK:- 监听Slider（旋转）
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

// MARK:- 监听裁剪/恢复/裁剪事件
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
        guard let croper = croper else { return }
        croper.recover(animated: true)
        slider.setValue(0, animated: true)
    }
    
    @IBAction func crop() {
        guard let croper = croper else { return }
        JPProgressHUD.show()
        croper.asyncCrop { [weak self] in
            guard let image = $0 else {
                JPProgressHUD.showError(withStatus: "裁剪失败",
                                        userInteractionEnabled: true)
                return
            }
            JPProgressHUD.dismiss()
            guard let navCtr = self?.navigationController,
                  let previewVC = JPPreviewViewController.build(with: JPImageresizerResult(image: image, cacheURL: nil)) else { return }
            navCtr.pushViewController(previewVC, animated: true)
        }
    }
}

// MARK:- 监听比例切换事件
extension JPCropViewController {
    @IBAction func originWHRatio() {
        croper?.updateCropWHRatio(0, rotateGridCount: (5, 5), animated: true)
    }
    
    @IBAction func three2four() {
        croper?.updateCropWHRatio(3.0 / 4.0, rotateGridCount: (6, 5), animated: true)
    }
    
    @IBAction func one2one() {
        croper?.updateCropWHRatio(1, rotateGridCount: (4, 4), animated: true)
    }
    
    @IBAction func four2three() {
        croper?.updateCropWHRatio(4.0 / 3.0, rotateGridCount: (4, 5), animated: true)
    }
}
