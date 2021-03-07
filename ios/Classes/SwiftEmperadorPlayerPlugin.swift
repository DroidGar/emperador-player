import Flutter
import UIKit
import AVKit

public class SwiftEmperadorPlayerPlugin: NSObject, FlutterPlugin {
    
    var player: AVPlayer?
    var _channel: FlutterMethodChannel
    var isPlaying = false
    var playerItem: AVPlayerItem?
    var metadataSplittPattern = "-"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.emperador.player/channel", binaryMessenger: registrar.messenger())
        let instance = SwiftEmperadorPlayerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel: FlutterMethodChannel) {
        _channel = channel
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "sync-state": print("sync-state")
        case "config":
            let data: Dictionary = call.arguments as! [String: Any]
            metadataSplittPattern = data["metaDivider"] as! String
            config(url: data["url"] as! String)
        case "play":
            play()
        case "pause":
            pause()
        case "stop":
            stop()
            
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
        _channel.invokeMethod("playing", arguments: nil)
        
    }
    
    func stop() {
        if isPlaying {
            pause()
        }
        playerItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
        _channel.invokeMethod("idle", arguments: nil)
    }
    
    func pause() {
        player!.pause()
        isPlaying = false
        _channel.invokeMethod("ready", arguments: nil)
    }
    
    func config(url : String) {
        _channel.invokeMethod("idle", arguments: nil)
        _channel.invokeMethod("loading", arguments: nil)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            NSLog("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            NSLog("Session is Active")
        } catch {
            NSLog("ERROR: CANNOT PLAY MUSIC IN BACKGROUND. Message from code: \"\(error)\"")
        }
        
        playerItem = AVPlayerItem(url: URL(string: url)!)
        
        if player != nil {
            player!.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
            playerItem!.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)
        }
        _channel.invokeMethod("ready", arguments: nil)
        
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?, of object: Any?,
        change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?
    ) {
        if keyPath != "timedMetadata" { return }
        
        let data: AVPlayerItem = object as! AVPlayerItem
        
        for item in data.timedMetadata! {
            print(item)
            let array = (item.value as! String).components(separatedBy: metadataSplittPattern)
            let artist = array[0]
            let song = array[1]
            _channel.invokeMethod("metadata", arguments: "{\"artist\":\"\(artist)\",\"song\":\"\(song)\",\"genre\":\"\"}")
        }
    }
    
    
}
