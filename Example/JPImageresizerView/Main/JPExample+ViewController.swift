//
//  JPExample+ViewController.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/12.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import UIKit
import JPImageresizerView
import JPBasic
import Combine
import FunnyButton

var mainVC: JPExample.ViewController {
    (rootVC as! UINavigationController).viewControllers.first! as! JPExample.ViewController
}

@objcMembers class JPExampleListViewController: JPExample.ViewController {
    class func cacheConfigure(_ configure: JPImageresizerConfigure, statusBarStyle: UIStatusBarStyle) {
        mainVC.cacheModel = .init(statusBarStyle, configure)
    }
    
    class func cleanConfigure(_ configure: JPImageresizerConfigure) {
        guard let cacheModel = mainVC.cacheModel, cacheModel.configure == configure else { return }
        mainVC.cacheModel = nil
    }
}

extension JPExample {
    class ViewController: UITableViewController {
        private weak var exporterSession: AVAssetExportSession?
        private weak var progressTimer: Timer?
        private var progressBlock: JPExportVideoProgressBlock?
        
        var tmpVideoURL: URL?
        var isExporting = false {
            didSet {
                guard isExporting != oldValue else { return }
                toggleExporting()
            }
        }
        
        let cacheBtn = UIButton(type: .system)
        @objc dynamic var cacheModel: ConfigureModel? = nil
        var cacheCanceler: AnyCancellable?
        
        // MARK: - Life cycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigationBar()
            
//            if #available(iOS 26.0, *) {
//                tableView.topEdgeEffect.isHidden = true
//            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            removeTmpFile()
        }
        
        deinit {
            removeProgressTimer()
            cacheCanceler?.cancel()
        }
        
        // MARK: - Setup
        
        private func setupNavigationBar() {
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.topItem?.title = "Examples 🌰"
            
            let cameraBtn = UIButton(type: .system)
            cameraBtn.setImage(UIImage(systemName: "camera"), for: .normal)
            cameraBtn.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
            
            cacheBtn.isHidden = true
            cacheBtn.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
            cacheBtn.addTarget(self, action: #selector(backCacheAction), for: .touchUpInside)
            cacheCanceler = publisher(for: \.cacheModel, options: .new).sink { [weak self] newValue in
                self?.cacheBtn.isHidden = newValue == nil
            }
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cacheBtn)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cameraBtn)
        }
    }
}

extension JPExample.ViewController {
    // MARK: - Photograph
    
    @objc func cameraAction() {
        JPPhotoTool.sharedInstance().cameraAuthority { [weak self] in
            self?.photograph()
        } refuseAccessAuthorityHandler: { [weak self] in
            self?.photograph()
        } alreadyRefuseAccessAuthorityHandler: { [weak self] in
            self?.photograph()
        } canNotAccessAuthorityHandler: { [weak self] in
            self?.photograph()
        }
    }
    
    func photograph() {
        Task {
            do {
                let image = try await ImagePicker.photograph()
                let model = JPExample.ConfigureModel(.lightContent, .defaultConfigure(with: image))
                await MainActor.run {
                    pushImageresizerVC(with: model)
                }
            } catch let error as ErrorHUD {
                error.showErrorHUD()
            } catch {
                JPProgressHUD.showError(withStatus: "系统错误：\(error)", userInteractionEnabled: true)
            }
        }
    }
    
    // MARK: - Cache crop
    
    @objc func backCacheAction() {
        guard let cacheModel = self.cacheModel else { return }
        pushImageresizerVC(with: cacheModel)
    }
}

extension JPExample.ViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return JPExample.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = JPExample.sections[section]
        return section.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = JPExample.sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = item.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = JPExample.sections[section]
        return section.self.title
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = JPExample.sections[indexPath.section]
        let item = section.items[indexPath.row]
        item.doExecute()
    }
}

// MARK: - Router
extension JPExample.ViewController {
    func pushImageresizerVC(with model: JPExample.ConfigureModel) {
        guard let navCtr = navigationController else { return }
        let vc = JPImageresizerViewController.build(with: model.statusBarStyle, configure: model.configure)
        navCtr.addCubeAnimation()
        navCtr.pushViewController(vc, animated: false)
    }
    
    func pushCropVC(isJPCroper: Bool) {
        guard let navCtr = navigationController else { return }
        let vc = JPCropViewController.build(forCroper: isJPCroper, image: nil)
        navCtr.addCubeAnimation()
        navCtr.pushViewController(vc, animated: false)
    }
    
    func pushOneDayCropVC() {
        if #available(iOS 15.0, *) {
            guard let navCtr = navigationController else { return }
            let vc = UIViewController.createCropViewController { oneDayImage in
                guard let image = oneDayImage else {
                    JPProgressHUD.showError(withStatus: "保存失败", userInteractionEnabled: true)
                    return
                }
                
                JPProgressHUD.show()
                JPPhotoTool.sharedInstance().savePhoto(with: image) { _ in
                    JPProgressHUD.showSuccess(withStatus: "保存成功", userInteractionEnabled: true)
                } failHandle: {
                    JPProgressHUD.showError(withStatus: "保存失败", userInteractionEnabled: true)
                }
            }
            navCtr.addCubeAnimation()
            navCtr.pushViewController(vc, animated: false)
            
        } else {
            JPProgressHUD.showInfo(withStatus: "请更新到iOS15以上版本", userInteractionEnabled: true)
        }
    }
    
    func pushChooseFaceVC() {
        JPPhotoTool.sharedInstance().albumAccessAuthority(allowAccessAuthorityHandler: { [weak self] in
            guard let self = self, let navCtr = self.navigationController else { return }
            let vc = JPPhotoViewController()
            vc.isReplaceFace = true
            navCtr.pushViewController(vc, animated: true)
        }, refuseAccessAuthorityHandler: nil, alreadyRefuseAccessAuthorityHandler: nil, canNotAccessAuthorityHandler: nil, isRegisterChange: false)
    }
    
    func pushPreviewVC(_ results: [JPImageresizerResult], columnCount: Int = 1, rowCount: Int = 1) {
        guard let navCtr = navigationController else { return }
        let vc = JPPreviewViewController.build(with: results, columnCount: columnCount, rowCount: rowCount)
        navCtr.pushViewController(vc, animated: true)
    }
    
    func pushColorMeasurementVC(_ image: UIImage) {
        guard let navCtr = navigationController else { return }
        let vc = JPColorMeasurementViewController(image: image)
        navCtr.pushViewController(vc, animated: true)
    }
    
    func pushGlassEffectVC() {
        guard let navCtr = navigationController else { return }
        let vc = JPGlassEffectViewController()
        navCtr.pushViewController(vc, animated: true)
    }
}

// MARK: - Export video
extension JPExample.ViewController {
    private func toggleExporting() {
        guard isExporting else {
            JPExportCancelView.hide()
            removeProgressTimer()
            return
        }
        
        JPExportCancelView.show { [weak self] in
            self?.exporterSession?.cancelExport()
        }
    }
    
    private func removeTmpFile() {
        guard let tmpURL = self.tmpVideoURL else { return }
        self.tmpVideoURL = nil
        try? FileManager.default.removeItem(at: tmpURL)
    }
    
    // MARK: Progress timer
    
    func addProgressTimer(progressBlock: @escaping JPExportVideoProgressBlock,
                          exporterSession: AVAssetExportSession) {
        removeProgressTimer()
        
        self.exporterSession = exporterSession
        self.progressBlock = progressBlock
        
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let progressBlock = self?.progressBlock,
                  let exporterSession = self?.exporterSession else { return }
            progressBlock(exporterSession.progress)
        }
        RunLoop.main.add(progressTimer, forMode: .common)
        self.progressTimer = progressTimer
    }

    func removeProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressBlock = nil
        exporterSession = nil
    }
}
