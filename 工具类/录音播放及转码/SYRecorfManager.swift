//
//  SYRecorfManager.swift
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/6/18.
//  Copyright © 2019 bsy. All rights reserved.
//

import Foundation
import AVFoundation

protocol SYRecordPlayEndDelegate {
    func sy_audioPlayerDidFinishPlaying(_ player: SYRecorfManager, successfully flag: Bool)
}
class SYRecorfManager :NSObject {
    static let singleton = SYRecorfManager()
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var file_path = ""
    //控制录音数，超出被覆盖
    static var page = 0 
    var isCancelRecorder : Bool = false
    var delegate : SYRecordPlayEndDelegate!
    var transMp3 : SYTransMp3Tool = SYTransMp3Tool()
    
    
    //录音
    func beginRecord() {
        let session = AVAudioSession.sharedInstance()
        //设置session类型
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
        //录音设置，注意，后面需要转换成NSNumber，如果不转换，无法录制音频文件
        let recordSetting: [String: Any] = [AVSampleRateKey: NSNumber(value: 8000),//采样率
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
            AVNumberOfChannelsKey: NSNumber(value: 1),//通道数
            //            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
        ];
        //开始录音
        do {
            isCancelRecorder = false
            if SYRecorfManager.page < 5 {
                SYRecorfManager.page += 1
            }else {
                SYRecorfManager.page = 0
            }
            file_path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/record\(SYRecorfManager.page).wav"))!
            let url = URL(fileURLWithPath: file_path)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            recorder!.record()
            print("开始录音")
        } catch let err {
            isCancelRecorder = true
            print("录音失败:\(err.localizedDescription)")
        }
    }
    //结束录音
    func stopRecord() {
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("正在录音，马上结束它，文件保存到了：\(file_path)")
            }else {
                print("没有录音，但是依然结束它")
            }
            recorder.stop()
            self.recorder = nil
            
        }else {
            isCancelRecorder = true
            print("没有初始化")
        }
        
    }
    
    //获取音频时长
    func getVudioDuration(urlStr:String,durationBlock: @escaping (Int,String)->()) {
        XYRequestConfigure.downLoad(url: urlStr) { (path) in
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                DispatchQueue.main.async {
            
                    let newUrl = self.transCodingWithAMR(url: path)
                    DispatchQueue.main.async {
                        do{
                            print(path)
                            self.player = try AVAudioPlayer(contentsOf: URL(string: newUrl)!)
                            if let duration = self.player?.duration{
                                print("语音时长-----\(duration)")
                                durationBlock(Int(duration),newUrl)
                            }else{
                                XYProgressHUD.show(message: "未获取到音频时长")
                            }
                            
                        }catch{
                            self.player = try? AVAudioPlayer(contentsOf: URL(string: path)!)
                            if let duration = self.player?.duration{
                                print("语音时长-----\(duration)")
                                durationBlock(Int(duration),path)
                            }else{
                                XYProgressHUD.show(message: "未获取到音频时长")
                            }
                        }
                    }
                }
               
            })
        }
    }
    //播放
    func play(urlStr:String) {
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlStr))
            
            print("歌曲长度：\(player!.duration)")
            player!.play()
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
    
    func playUrl(url:String?,transformUrl: String?) {
        if let localUrl = transformUrl {
            do {
                //
                self.player = try AVAudioPlayer(contentsOf: URL(string: localUrl)!)
                self.player!.delegate = self
                print("歌曲长度：\(self.player!.duration)")
                self.player!.play()
            } catch let err {
                print("播放失败:\(err.localizedDescription)")
            }
        }else{
            guard let url = url else {
                XYProgressHUD.show(message: "未获取到语音路径")
                return
            }
            XYRequestConfigure.downLoad(url: url) { (path) in
                do {
                    let newUrl = self.transCodingWithAMR(url: path)
                    do {
                        //
                        self.player = try AVAudioPlayer(contentsOf: URL(string: newUrl)!)
                        self.player!.delegate = self
                        print("歌曲长度：\(self.player!.duration)")
                        self.player!.play()
                    } catch let err {
                        print("播放失败:\(err.localizedDescription)")
                        self.player = try AVAudioPlayer(contentsOf: URL(string: path)!)
                        self.player!.delegate = self
                        print("歌曲长度：\(self.player!.duration)")
                        self.player!.play()
                    }
                } catch let err {
                    print("播放失败:\(err.localizedDescription)")
                    
                }
            }
            
        }
        
    }
    func endPlay() {
        if self.player != nil {
            if self.player?.rate == 1 {
                player?.stop()
            }
        }
    }
    //转码wav->amr
    func transCoding(urls:[String]) -> [String] {
        var newUrls = [String]()
        for url in urls {
            
            do {
                let wavData = try Data(contentsOf: URL(fileURLWithPath: url))
                let amrData = convert16khzWaveToAmr(waveData: wavData)
                let file_path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/record\(SYRecorfManager.page).amr"))!
                try amrData?.write(to: URL(fileURLWithPath: file_path))
                newUrls.append(file_path)
            }catch let err {
                print("转amr文件异常：\(err.localizedDescription)")
            }
        }
        return newUrls
    }
    func transWavToMp3(urls:[String]) -> [String] {
        var newUrls = [String]()
        for url in urls {
            let mp3FilePath = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/record\(SYRecorfManager.page).mp3"))!
            let b = transMp3.convertMp3from(url, topath: mp3FilePath)
            if b {
                newUrls.append(mp3FilePath)
            }else {
                print("转mp3文件异常")
            }
        }
        
        return newUrls
    }
    
    
    //转码amr->wav
    func transCodingWithAMR(url:String) -> String {
        var newUrls = ""
        do {
            let amrData = try Data(contentsOf: URL(fileURLWithPath: url))
            var wavData = convertAmrWBToWave(data: amrData)
            //安卓上传的语音需要amr-nb data
            if wavData == nil {
                wavData = convertAmrNBToWave(data: amrData)
            }
            
            let file_path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/down\(arc4random()%10000).wav"))!
            try wavData?.write(to: URL(fileURLWithPath: file_path))
            newUrls = file_path
        }catch let err {
            print("转amr文件异常：\(err.localizedDescription)")
        }
        return newUrls
    }
    
}
extension SYRecorfManager : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.sy_audioPlayerDidFinishPlaying(self, successfully: flag)
    }
}
