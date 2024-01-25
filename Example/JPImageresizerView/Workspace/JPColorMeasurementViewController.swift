//
//  JPColorMeasurementViewController.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2024/1/25.
//  Copyright © 2024 ZhouJianPing. All rights reserved.
//

import UIKit
import JPImageresizerView
import JPBasic
import pop

class JPColorMeasurementViewController: UIViewController {
    let image: UIImage
    
    private let dp = JPDynamicPage()
    private let infoView = UIView()
    private let colorView = UIView()
    private let imageView = ColorMeasurementView()
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Color Measurement"
        
        view.backgroundColor = UIColor(red: CGFloat.random(in: 0...1),
                                       green: CGFloat.random(in: 0...1),
                                       blue: CGFloat.random(in: 0...1),
                                       alpha: 1)
        
        view.addSubview(dp)
        
        setupInfoView()
        setupImageView()
        didChangeStatusBarOrientation()
        changBgColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatusBarOrientation), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        dp.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dp.stopAnimation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension JPColorMeasurementViewController {
    enum RGBA: Int {
        case R = 111
        case G = 222
        case B = 333
        case A = 444
        
        var title: String {
            switch self {
            case .R: return "R:"
            case .G: return "G:"
            case .B: return "B:"
            case .A: return "A:"
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .R: return .systemRed
            case .G: return .systemGreen
            case .B: return .systemBlue
            case .A: return UIColor(white: 0, alpha: 0.6)
            }
        }
        
        var initialValueStr: String {
            switch self {
            case .R, .G, .B: return "0"
            case .A: return "0%"
            }
        }
    }
    
    func setupInfoView() {
        infoView.frame = CGRect(x: 0, y: 0, width: 190, height: 124)
        infoView.layer.shadowOpacity = 0.3
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOffset = CGSize(width: 1, height: 1)
        infoView.layer.shadowRadius = 5
        infoView.layer.shadowPath = UIBezierPath(roundedRect: infoView.bounds, cornerRadius: 5).cgPath
        view.addSubview(infoView)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurView.frame = infoView.bounds
        blurView.layer.cornerRadius = 5
        blurView.layer.masksToBounds = true
        infoView.addSubview(blurView)
        
        let bgImgView = UIImageView(image: UIImage.getStretchBorderImage())
        bgImgView.frame = infoView.bounds
        infoView.addSubview(bgImgView)
        
        let infoTitleLabel = UILabel()
        infoTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        infoTitleLabel.textColor = UIColor(white: 0, alpha: 0.8)
        infoTitleLabel.textAlignment = .center
        infoTitleLabel.text = "触碰图片获取颜色值"
        infoTitleLabel.frame = CGRect(x: 0, y: 5, width: infoView.bounds.width, height: 25)
        infoView.addSubview(infoTitleLabel)
        
        let fontSize: CGFloat = 13
        let labX: CGFloat = 15
        let labW1: CGFloat = 18
        let labW2: CGFloat = 100
        let labH: CGFloat = 15
        func createLabels(_ y: CGFloat, _ rgba: RGBA) -> CGFloat {
            let label1 = UILabel()
            label1.font = .systemFont(ofSize: fontSize, weight: .bold)
            label1.textAlignment = .center
            label1.textColor = rgba.titleColor
            label1.text = rgba.title
            label1.frame = CGRect(x: labX, y: y, width: labW1, height: labH)
            infoView.addSubview(label1)
            
            let label2 = UILabel()
            label2.tag = rgba.rawValue
            label2.font = .systemFont(ofSize: fontSize, weight: .regular)
            label2.textAlignment = .left
            label2.textColor = .darkGray
            label2.text = rgba.initialValueStr
            label2.frame = CGRect(x: label1.frame.maxX + 5, y: label1.frame.origin.y, width: labW2, height: labH)
            infoView.addSubview(label2)
            
            return label1.frame.maxY
        }
        let beginLabY = infoTitleLabel.frame.maxY + 5
        var maxLabY = beginLabY
        maxLabY = createLabels(maxLabY, .R) + 5
        maxLabY = createLabels(maxLabY, .G) + 5
        maxLabY = createLabels(maxLabY, .B) + 5
        maxLabY = createLabels(maxLabY, .A)
        
        let colorBgView = UIImageView(image: UIImage.bundleImage("transparentBG.png"))
        colorBgView.contentMode = .scaleAspectFill
        colorBgView.layer.cornerRadius = 5
        colorBgView.layer.masksToBounds = true
        let wh = maxLabY - beginLabY
        colorBgView.frame = CGRect(x: infoView.bounds.width - wh - 18, y: beginLabY, width: wh, height: wh)
        infoView.addSubview(colorBgView)
        
        colorView.frame = colorBgView.bounds
        colorView.backgroundColor = .clear
        colorBgView.addSubview(colorView)
    }
    
    func setupImageView() {
        imageView.image = image
        imageView.gettedColorValues = { [weak self] r, g, b, a in
            guard let self else { return }
            if let redLabel = self.infoView.viewWithTag(RGBA.R.rawValue) as? UILabel {
                redLabel.text = String(format: "%.0lf", r)
            }
            if let greenLabel = self.infoView.viewWithTag(RGBA.G.rawValue) as? UILabel {
                greenLabel.text = String(format: "%.0lf", g)
            }
            if let blueLabel = self.infoView.viewWithTag(RGBA.B.rawValue) as? UILabel {
                blueLabel.text = String(format: "%.0lf", b)
            }
            if let alphaLabel = self.infoView.viewWithTag(RGBA.A.rawValue) as? UILabel {
                alphaLabel.text = String(format: "%.0lf%%", a * 100)
            }
            self.colorView.backgroundColor = UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
        }
        imageView.isUserInteractionEnabled = true
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        imageView.layer.shadowRadius = 5
        view.addSubview(imageView)
    }
}

extension JPColorMeasurementViewController {
    func changBgColor() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
            guard let self else { return }
            guard let anim = POPBasicAnimation(propertyNamed: kPOPViewBackgroundColor) else { return }
            anim.duration = 2
            anim.toValue = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
            anim.completionBlock = {[weak self]  _, _ in
                self?.changBgColor()
            }
            self.view.pop_add(anim, forKey: kPOPViewBackgroundColor)
        }
    }
    
    @objc func didChangeStatusBarOrientation() {
        dp.frame = UIScreen.main.bounds
        
        let margin: CGFloat = 16
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var contentInsets = UIEdgeInsets(top: JPConstant.navBarH() + margin, left: margin, bottom: JPConstant.diffTabBarH() + margin, right: margin)
        let isLandscape = screenWidth > screenHeight
        if isLandscape {
            if UIDevice.current.orientation == .landscapeLeft {
                contentInsets.left += JPConstant.statusBarH()
                contentInsets.right += JPConstant.diffTabBarH()
            } else {
                contentInsets.left += JPConstant.diffTabBarH()
                contentInsets.right += JPConstant.statusBarH()
            }
        } else {
            contentInsets.top += JPConstant.statusBarH()
        }
        
        let imgMinY = contentInsets.top + infoView.frame.height + margin
        let imgMaxW = screenWidth - contentInsets.left - contentInsets.right
        let imgMaxH = screenHeight - imgMinY - contentInsets.bottom
        var imgW = image.size.width
        var imgH = image.size.height
        if imgW > imgH {
            imgW = imgMaxW
            imgH = imgW * (image.size.height / image.size.width)
            if imgH > imgMaxH {
                imgH = imgMaxH
                imgW = imgH * (image.size.width / image.size.height)
            }
        } else {
            imgH = imgMaxH
            imgW = imgH * (image.size.width / image.size.height)
            if imgW > imgMaxW {
                imgW = imgMaxW
                imgH = imgW * (image.size.height / image.size.width)
            }
        }
        
        let maxH = screenHeight - contentInsets.top - contentInsets.bottom
        let conH = infoView.frame.height + margin + imgH
        infoView.frame.origin = CGPoint(x: (screenWidth - infoView.frame.width) * 0.5,
                                        y: contentInsets.top + (maxH - conH) * 0.5)
        imageView.frame = CGRect(x: (screenWidth - imgW) * 0.5,
                                 y: infoView.frame.maxY + margin,
                                 width: imgW, height: imgH)
    }
}

extension JPColorMeasurementViewController {
    class ColorMeasurementView: UIImageView {
        var gettedColorValues: ((_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> Void)?
        
        override var image: UIImage? {
            get { super.image }
            set {
                super.image = newValue
                if let image = newValue {
                    JPImageresizerTool.beginRetrievalImage(image)
                } else {
                    JPImageresizerTool.endRetrievalImage()
                }
            }
        }
        
        deinit {
            JPImageresizerTool.endRetrievalImage()
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchMe(touches)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchMe(touches)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchMe(touches)
        }
        
        func touchMe(_ touches: Set<UITouch>) {
            guard let image, let gettedColorValues, let touch = touches.first else { return }
            var point = touch.location(in: self)
            guard bounds.contains(point) else { return }
            
            let scale = (image.size.width * image.scale) / bounds.width
            point.x *= scale
            point.y *= scale
            
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 1
            guard JPImageresizerTool.getColorFromRetrievingImage(at: point, 
                                                                 red: &r,
                                                                 green: &g,
                                                                 blue: &b,
                                                                 alpha: &a) 
            else { return }
            gettedColorValues(r, g, b, a)
        }
    }
}
