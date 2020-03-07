//
//  SYZQRScanView.swift
//  SmartNongJi
//
//  Created by bsy on 2018/8/17.
//  Copyright © 2018年 bsy. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
protocol SYZQRScanViewDelegate {
    func scanSuccess(scanView:SYZQRScanView,message:String)
}

class SYZQRScanView: UIView,AVCaptureMetadataOutputObjectsDelegate {

    var delegate :SYZQRScanViewDelegate?
    
    /// 扫描区域的Frame，默认长宽为Frame的宽度3/4，位置为Frame中心
    var scanRect = CGRect.zero
    
    let scanLinewWidth :CGFloat = 42
    let scanTime = 3.0
    let scanLineAnimationName = "scanLineAnimation"
    let cornerLineWidth:CGFloat = 1.5
    //边框厚度
    let borderLineWidth :CGFloat = 0.5
    ///边框颜色
    var borderLineColor = UIColor.HexColor.themBackgroundColor
    var cornerLineColor = UIColor.HexColor.themBackgroundColor
    var scanLineColor = UIColor.HexColor.themBackgroundColor
    ///是否显示四角，默认为true
    var showCornerLine = true
    ///是否显示边框，默认为false
    var showBorderLine = false
    /// 是否显示上下移动的扫描线，默认为YES
    var showScanLine = true
    
    lazy var scanLine:UIView = {
        let lineView = UIView()
        lineView.frame = CGRect(x: 0, y: 0, width: scanRect.size.width, height: scanLinewWidth)
        lineView.isHidden = true
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = lineView.layer.bounds
        gradient.colors = [scanLineColor.withAlphaComponent(0).cgColor,scanLineColor.withAlphaComponent(0.4).cgColor,scanLineColor.cgColor]
        
        gradient.locations = [NSNumber(value: 0),NSNumber(value: 0.96),NSNumber(value: 0.97)]
        lineView.layer.addSublayer(gradient)
        return lineView
    }()
    
    lazy var middleView:UIView = {
       let middleView = UIView()
        middleView.frame = self.scanRect
        middleView.clipsToBounds = true
        return middleView
    }()
    
    lazy var masskView:UIView = {
        let mView = UIView()
        mView.frame = self.bounds
        mView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let fullbezierPath = UIBezierPath(rect: self.bounds)
        let scanBezierPath = UIBezierPath(rect: self.scanRect)
        fullbezierPath.append(scanBezierPath.reversing())
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = fullbezierPath.cgPath
        mView.layer.mask = shapeLayer
        return mView
    }()
    lazy var textLab: UILabel = {
        let textLab = UILabel(frame: CGRect(x: 0, y: self.scanRect.origin.y + scanRect.height + 50, width: kScreenWidth, height: 20))
        textLab.text = "请扫描主机监控器条形码"
        textLab.textColor = .white
        textLab.textAlignment = .center
        textLab.font = .systemFont(ofSize: 14)
        return textLab
    }()
    
    private var device:AVCaptureDevice!
    private var deviceInput:AVCaptureDeviceInput!
    private var dataOutput:AVCaptureMetadataOutput!
    private var session:AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let locationAlumButton = UIButton()
//    private let locationAlumLabel = UILabel()
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.black
        let width = kScreenWidth * 3 / 4
        scanRect = CGRect(x: (kScreenWidth - width) / 2, y: (kScreenHeight - width - 40) / 2, width: width, height: width)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startScanning() {
        
        if !self.statusCheck() {
            return
        }
        if self.session == nil {
            self.setupViews()
            self.configureCameraAndStart()
            return
        }
        
        
        if session.isRunning {
            return
        }
        session.startRunning()
        self.showScanLine(showScanLine: self.showScanLine)
        
    }
    
    func stopScanning() {
        guard self.session.isRunning else {
            return
        }
        self.session.stopRunning()
        self.showScanLine(showScanLine: false)
        
    }
    
    func setupViews() {
        self.addSubview(self.middleView)
        self.middleView.addSubview(self.scanLine)
        self.addSubview(self.masskView)
        masskView.addSubview(textLab)

        if self.showCornerLine {
            self.addCornerLines()
        }
        
        if self.showBorderLine {
            self.addScanBorderLine()
        }
        self.configuerLocationAlum()
    }
    
    func configuerLocationAlum() {
        
        let btnWidth:CGFloat = 56
//        self.addSubview(self.locationAlumButton)
////        self.addSubview(self.locationAlumLabel)
//        self.locationAlumButton.setImage(UIImage(named: "tupian"), for: .normal)
//        self.locationAlumButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//
//        self.locationAlumButton.snp.makeConstraints { (make) in
//            make.right.equalTo(self).offset(-30)
//            make.bottom.equalTo(self).offset(-30)
//            make.height.width.equalTo(btnWidth)
//        }
        
//        self.locationAlumButton.frame = CGRect(x: 0, y: self.scanRect.maxY + 46,  width: 56, height: 56)
//        self.locationAlumButton.center.x = self.center.x
//        self.locationAlumButton.layer.cornerRadius = btnWidth / 2
//        self.locationAlumButton.layer.masksToBounds = true
//        self.locationAlumButton.addTarget(self, action: #selector(alumButtonClick), for: .touchUpInside)
        
        let torchButton = UIButton()
        torchButton.setImage(UIImage(named: "close_Sanguang"), for: .normal)
        torchButton.setImage(UIImage(named: "sanguang"), for: .selected)
        torchButton.addTarget(self, action: #selector(torchButtonClick(sender:)), for: .touchUpInside)
        self.addSubview(torchButton)
        torchButton.snp.makeConstraints { (make) in
//            make.left.equalTo(self).offset(30)
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.middleView.snp.bottom).offset(15)
//            make.bottom.equalTo(self).offset(-30)
            make.width.height.equalTo(btnWidth)
        }
        
//        self.locationAlumLabel.text = "本地相册"
//        self.locationAlumLabel.textColor = UIColor.white
//        self.locationAlumLabel.font = UIFont.systemFont(ofSize: 14)
//        self.locationAlumLabel.frame = CGRect(x: 0, y: self.locationAlumButton.frame.maxY + 6, width: 65, height: 20)
//        self.locationAlumLabel.textAlignment = .center
//        self.locationAlumLabel.center.x = self.center.x
    }
    //打开或关闭闪光灯
    @objc func torchButtonClick(sender:UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            //打开闪光灯
            let captureDevice = AVCaptureDevice.default(for: .video)
            if captureDevice!.hasTorch{
                try? captureDevice?.lockForConfiguration()
                captureDevice?.torchMode = .on
                captureDevice?.unlockForConfiguration()
            }
        }else{
            //关闭闪光灯
            let device = AVCaptureDevice.default(for: .video)
            if device!.hasTorch{
                try? device?.lockForConfiguration()
                device?.torchMode = .off
                device?.unlockForConfiguration()
            }
            
            
        }
        
    }
    
    //从本地相册拾取
    @objc func alumButtonClick() {
        
//        delegate?.qrFromPhtoAlum()
        
    }
    //边框
    func addScanBorderLine() {
        
        let borderRect = CGRect(x: self.scanRect.origin.x + borderLineWidth, y: self.scanRect.origin.y + borderLineWidth, width: self.scanRect.size.width - 2*borderLineWidth, height: self.scanRect.size.height - 2*borderLineWidth)
        let scanBezierPath = UIBezierPath(rect: borderRect)
        let lineLayer = CAShapeLayer()
        lineLayer.path = scanBezierPath.cgPath
        lineLayer.lineWidth = borderLineWidth
        lineLayer.strokeColor = self.borderLineColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(lineLayer)
    }
    
    //四角
    func addCornerLines() {
        let lineLayer = CAShapeLayer()
        lineLayer.lineWidth = self.cornerLineWidth
        lineLayer.strokeColor = self.cornerLineColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        let halfLineLong = self.scanRect.size.width / 12
        let lineBezierPath = UIBezierPath()
        let spacing = cornerLineWidth / 2
        
        let leftUpPoint = CGPoint(x: self.scanRect.origin.x + spacing, y: self.scanRect.origin.y + spacing)
        
        lineBezierPath.move(to: CGPoint(x: leftUpPoint.x, y: leftUpPoint.y + halfLineLong))
        lineBezierPath.addLine(to: leftUpPoint)
        lineBezierPath.addLine(to: CGPoint(x: leftUpPoint.x + halfLineLong, y: leftUpPoint.y))
        lineLayer.path = lineBezierPath.cgPath
        self.layer.addSublayer(lineLayer)
        
        let leftDownPoint = CGPoint(x: self.scanRect.origin.x + spacing, y: self.scanRect.origin.y + self.scanRect.size.height - spacing)
        
        lineBezierPath.move(to: CGPoint(x: leftDownPoint.x, y: leftDownPoint.y - halfLineLong))
        lineBezierPath.addLine(to: leftDownPoint)
        lineBezierPath.addLine(to: CGPoint(x: leftDownPoint.x + halfLineLong, y: leftDownPoint.y))
        lineLayer.path = lineBezierPath.cgPath
        self.layer.addSublayer(lineLayer)
        
        
        let rightUpPoint = CGPoint(x: self.scanRect.origin.x + self.scanRect.size.width - spacing, y: self.scanRect.origin.y + spacing)
        
        lineBezierPath.move(to: CGPoint(x: rightUpPoint.x - halfLineLong, y: rightUpPoint.y))
        lineBezierPath.addLine(to: rightUpPoint)
        lineBezierPath.addLine(to: CGPoint(x: rightUpPoint.x, y: rightUpPoint.y + halfLineLong))
        lineLayer.path = lineBezierPath.cgPath
        self.layer.addSublayer(lineLayer)
        
        
        let rightDownPoint = CGPoint(x: self.scanRect.origin.x + self.scanRect.size.width - spacing, y: self.scanRect.origin.y + self.scanRect.size.height - spacing)
        lineBezierPath.move(to: CGPoint(x: rightDownPoint.x - halfLineLong, y: rightDownPoint.y))
        lineBezierPath.addLine(to: rightDownPoint)
        lineBezierPath.addLine(to: CGPoint(x: rightDownPoint.x, y: rightDownPoint.y - halfLineLong))
        lineLayer.path = lineBezierPath.cgPath
        self.layer.addSublayer(lineLayer)
        
    }
    
    
    func statusCheck() -> Bool {
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            XYProgressHUD.show(message: "设备无相机--设备无相机功能,无法进行扫描功能")
            return false
        }
        guard UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear) else {
            XYProgressHUD.show(message: "设备相机错误——无法启用相机，请检查")
            return false
        }
        guard UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.front) else {
            XYProgressHUD.show(message: "设备相机错误——无法启用相机，请检查")
            return false
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        guard authStatus == AVAuthorizationStatus.authorized || authStatus == AVAuthorizationStatus.notDetermined else {
            XYProgressHUD.show(message: "未打开相机权限 ——请在“设置-隐私-相机”选项中，允许农机二维码访问你的相机")
            return false
        }
        
        return true
        
    }
    
    func configureCameraAndStart() {
        
        DispatchQueue.global().async {
            
            self.device = AVCaptureDevice.default(for: .video)
            self.deviceInput = try! AVCaptureDeviceInput.init(device: self.device)
            self.dataOutput = AVCaptureMetadataOutput()
            self.dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.session = AVCaptureSession()
            self.session.sessionPreset = AVCaptureSession.Preset.high
            if self.session.canAddInput(self.deviceInput){
                self.session.addInput(self.deviceInput)
            }
            
            if self.session.canAddOutput(self.dataOutput){
                self.session.addOutput(self.dataOutput)
            }
            
//            if !self.dataOutput.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.qr){
//                print("当前相机不支持扫码")
//            }
            
            self.dataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,.ean13,.ean8,.code128,.code39,.code93]
            
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.previewLayer.frame = self.frame
                self.layer.insertSublayer(self.previewLayer, at: 0)
                self.session.startRunning()
                self.dataOutput.rectOfInterest = self.previewLayer.metadataOutputRectConverted(fromLayerRect: self.scanRect)
                self.showScanLine(showScanLine: self.showScanLine)
            }
        }
        
    }
    
    func showScanLine(showScanLine:Bool)  {
        if showScanLine {
            addScanLineAnimation()
        }else{
            removeScanLineAnimation()
        }
    }
    
    func addScanLineAnimation() {
        self.scanLine.isHidden = false
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -scanLinewWidth
        animation.toValue = self.scanRect.size.height - scanLinewWidth
        animation.duration = scanTime
        animation.repeatCount = 10240
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.scanLine.layer.add(animation, forKey: scanLineAnimationName)
        
    }
    
    func removeScanLineAnimation() {
        self.scanLine.layer.removeAnimation(forKey: scanLineAnimationName)
        self.scanLine.isHidden = true
    }
    
    //MARK:AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            return
        }
        let result = metadataObjects.first as! AVMetadataMachineReadableCodeObject
        
        self.delegate?.scanSuccess(scanView: self, message: result.stringValue ?? "")
        
    }

}
