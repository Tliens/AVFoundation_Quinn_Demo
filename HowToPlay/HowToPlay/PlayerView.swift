//
//  PlayerView.swift
//  HowToPlay
//
//  Created by Quinn on 2018/10/24.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import AVFoundation
class PlayerView: UIView {    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

}
