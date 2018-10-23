//
//  ViewController.swift
//  LoadingAVAsset
//
//  Created by Quinn on 2018/10/23.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    var touchNums = 0
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var videoExport:AVAssetExportSession?
    var audioExport:AVAssetExportSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // 加载AVAsset的方式
    func loadAsset() {
//        let path = Bundle.main.path(forResource: "任素汐 - 我要你", ofType: "mp3")
        ///第一种加载方式
        let path = Bundle.main.path(forResource: "3", ofType: "mp4")

        let asset = AVAsset.init(url: URL.init(fileURLWithPath: path!, isDirectory: true))
        
        ///第二种加载方式
        ///AVURLAssetPreferPreciseDurationAndTimingKey 获取精确时间 通常不会再播放时使用
//        let options = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
//        let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: path!, isDirectory: true), options: options)
        
        
        if touchNums == 0{
            //音轨
            // 获取音轨后通常用于导出、或者作出其他操作

            let audioTrack = asset.tracks(withMediaType: .audio)
            plackTrack(track: audioTrack.first)
        } else if touchNums == 1 {
            player?.pause()
            //视频track
            // 获取视频轨道后通常用于导出、或者作出其他操作

            let videoTrack = asset.tracks(withMediaType: .video)
            plackTrack(track: videoTrack.first)
            
        } else if touchNums == 2{
            player?.pause()
            getAssetAttribute()
        } else if touchNums == 3{
            asyncLoadInfo()
        }

    }
    //也可以从相册中加载 asset ，通常返回的数据都是asset的形式
    func loadAssetFromPhotos(){
        
    }
    
    //AVAsset 的相关属性
    func getAssetAttribute(){
        let path = Bundle.main.path(forResource: "3", ofType: "mp4")
        
        let asset = AVAsset.init(url: URL.init(fileURLWithPath: path!, isDirectory: true))
        //时长
        let duration = asset.duration.seconds
        //歌词
        let lyrics = asset.lyrics
        //创建时间 通常从相册加载时会有数据
        let creatDate = asset.creationDate?.dataValue
        //相关信息 如 iso
        let metadata = asset.metadata(forFormat: .isoUserData)
        
        print(duration,lyrics ?? "",creatDate ?? "",metadata)
        
    }
    
    //播放track中的数据
    func plackTrack(track:AVAssetTrack?){
        guard let asset = track?.asset else{
            return
        }
        playerItem = AVPlayerItem.init(asset: asset)
        player = AVPlayer.init(playerItem: playerItem!)
        let playerlayer = AVPlayerLayer.init(player: player!)
        playerlayer.frame = view.bounds
        self.view.layer.addSublayer(playerlayer)
        player?.play()
    }
    
    ///异步加载相关信息
    func asyncLoadInfo(){
        let path = Bundle.main.path(forResource: "3", ofType: "mp4")
        
        let asset = AVAsset.init(url: URL.init(fileURLWithPath: path!, isDirectory: true))
        ///当一个asset加载时，它的部分属性是未知的，因此需要 asset来完成指定的加载
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError?
            let keyStatus = asset.statusOfValue(forKey: "playable", error: &error)

            
        }
    }

    /// 从视频中获取视频帧
    func getImageByAsset(){
        let path = Bundle.main.path(forResource: "3", ofType: "mp4")
        let asset = AVAsset.init(url: URL.init(fileURLWithPath: path!, isDirectory: true))
        
        if asset.tracks(withMediaType: .video).count > 0 {
            let imgGen = AVAssetImageGenerator.init(asset: asset)
            //最大尺寸
            imgGen.maximumSize = CGSize.init(width: 100, height: 100)
            //光圈
            imgGen.apertureMode = AVAssetImageGenerator.ApertureMode.cleanAperture
            
            
            
            //异步加载多个
            imgGen.generateCGImagesAsynchronously(forTimes: [CMTime.zero as NSValue]) { (time1, cgimg, time2, result, error) in
                if let _cgimg = cgimg {
                    let img = UIImage.init(cgImage: _cgimg)
                    print("async get a img by asset")
                }
            }
            
            var actrueTime:CMTime = CMTime.zero
            //同步加载一个
            if let cgimg = try? imgGen.copyCGImage(at: CMTime.zero, actualTime: &actrueTime){
                let img = UIImage.init(cgImage: cgimg)
                print("sync get a img by asset")
            }
            
        }
    }
    
    /// 导出音频或者视频
    
    func exportAsset(){
        guard let path = Bundle.main.path(forResource: "3", ofType: "mp4") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let asset = AVAsset.init(url: url)
        let videoTracks = asset.tracks(withMediaType: .video)
        let audioTracks = asset.tracks(withMediaType: .audio)
        
        let firstVideoTrack = videoTracks.first
        let firstAudioTrack = audioTracks.first
        
        //视频
        let videocomposition = AVMutableComposition.init()
        if let compositionVideoTrack = videocomposition.addMutableTrack(withMediaType: .video, preferredTrackID: 0){
            if firstVideoTrack != nil{
                try? compositionVideoTrack.insertTimeRange(firstVideoTrack!.timeRange, of: firstVideoTrack!, at: .zero)
                videoExportSession(asset: videocomposition)
            }
        }
        
        //音频
        let audiocomposition = AVMutableComposition.init()
        if let compositionAudioTrack = audiocomposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0){
            if firstAudioTrack != nil{
                try? compositionAudioTrack.insertTimeRange(firstAudioTrack!.timeRange, of: firstAudioTrack!, at: .zero)
                audioExportSession(asset: audiocomposition)
            }
        }
        
        
        /// 可以调用 cancelExport 来取消 导出
        audioExport?.cancelExport()
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        loadAsset()
        print(#function,touchNums)
        touchNums = touchNums + 1
        
    }
    

}

extension ViewController{
    //导出
    func audioExportSession(asset:AVAsset){
        // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
        let presetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        if presetNames.contains(AVAssetExportPresetAppleM4A) {
            audioExport = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetAppleM4A)
            
        }else{
            audioExport = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetPassthrough)
        }
        audioExport?.outputURL = getAudioExportURL()
        audioExport?.outputFileType = AVFileType.m4a
        ///如果想要裁剪 设置相关参数
        //        audioExport?.timeRange = getTimeRange(asset:asset)
        audioExport?.shouldOptimizeForNetworkUse = true
        audioExport?.exportAsynchronously(completionHandler: {[weak self]in
            print(self?.audioExport?.error)
        })
    }
    //获取url
    func getAudioExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export" + ".m4a"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
}
/// 视频相关
extension ViewController{
    //导出
    func videoExportSession(asset:AVAsset){
        // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
        let presetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        //设置 AVAssetExportPreset640x480等可选参数，会导致视频压缩，但还需研究VideoTool,进一步做压缩处理
        videoExport = AVAssetExportSession.init(asset: asset, presetName: presetNames.first ?? AVAssetExportPresetPassthrough)
        
        videoExport?.outputURL = getVideoExportURL()
        videoExport?.outputFileType = AVFileType.mp4
         ///如果想要裁剪 设置相关参数
//        videoExport?.timeRange = getTimeRange(asset:asset)
        videoExport?.exportAsynchronously(completionHandler: {[weak self]in
            print(self?.audioExport?.error)
        })
    }
    //获取url
    func getVideoExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export" + ".mp4"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
    
}
extension ViewController{
    //公共函数
    //设置裁剪参数
    func getTimeRange(asset:AVAsset)->CMTimeRange{
        print(asset.duration.timescale)
        let start = CMTimeMake(value: Int64(asset.duration.timescale * 10), timescale: asset.duration.timescale)
        let end = CMTimeMake(value: Int64(asset.duration.timescale * 30), timescale: asset.duration.timescale)
        let range = CMTimeRange.init(start: start, end: end)
        return range
    }
}
