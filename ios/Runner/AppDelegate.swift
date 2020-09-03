import UIKit
import Flutter
import AVKit
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, AVAssetDownloadDelegate {
    
    private var channel: FlutterMethodChannel? = nil
    var configuration: URLSessionConfiguration?
    var downloadSession: AVAssetDownloadURLSession?
    var downloadIdentifier = "\(Bundle.main.bundleIdentifier!).background"
    var orientation: UIInterfaceOrientationMask = .portrait
   
    
    // MARK: - DID FINISH LAUNCHING
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        let controller = window?.rootViewController as! FlutterViewController
        
        channel = FlutterMethodChannel(name: "playerChannel", binaryMessenger: controller.binaryMessenger)
        channel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            // Handle Method Calls From Flutter
            
            if call.method == "play" {
                
                let data = call.arguments as! [String: String]
                self.play(url: data["url"], controller: controller)
                
            } else if call.method == "download" {
                
                let data = call.arguments as! [String: String]
                self.setupAssetDownload(videoUrl: data["url"], name: data["name"])
                
            } else if call.method == "delete" {
                let data = call.arguments as! [String: String]
                self.deleteAsset(location: data["location"])
            } else {
                let data = call.arguments as! [String: String]
                self.playOfflineAsset(location: data["location"], controller: controller)
                
            }
            
        })
       
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Supported Interface Orientations

    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientation
    }
    
    // MARK: - DOWNLOAD VIDEO
    
    func setupAssetDownload(videoUrl: String?, name: String?) {

        // Create new background session configuration.
        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
        
        // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
        downloadSession = AVAssetDownloadURLSession(configuration: configuration!,
                                                    assetDownloadDelegate: self,
                                                    delegateQueue: OperationQueue.main)
        
        if let url = URL(string: videoUrl!){
            let asset = AVURLAsset(url: url)
            
            // Create new AVAssetDownloadTask for the desired asset
            let downloadTask = downloadSession?.makeAssetDownloadTask(asset: asset,
                                                                      assetTitle: name!,
                                                                      assetArtworkData: nil,
                                                                      options: nil)
            // Start task and begin download
            downloadTask?.resume()
        }
    }//end method
    
func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        let baseUrl = URL(fileURLWithPath: NSHomeDirectory()) //app's home directory
        let assetUrl = baseUrl.appendingPathComponent(location.relativePath)
        print(assetUrl.path)
        self.channel?.invokeMethod("offlineDownloadLocation", arguments: assetUrl.path)
        downloadSession?.finishTasksAndInvalidate()
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange = value.timeRangeValue
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        self.channel?.invokeMethod("downloadProgress", arguments: percentComplete)
    }
    
    // MARK: - PLAY ONLINE
    
    func play(url: String?, controller: UIViewController) {
        
        let asset = AVURLAsset(url: URL(string:url ?? "")!)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)  // video path coming from above function
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        controller.present(playerViewController, animated: true, completion: nil)
        player.play()
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")

    }
    
    // MARK: - PLAY OFFLINE
    
    func playOfflineAsset(location: String?, controller: UIViewController) {
        let savedLink = location
        let baseUrl = URL(fileURLWithPath: NSHomeDirectory()) //app's home directory
        let assetUrl = baseUrl.appendingPathComponent(savedLink!)
      
        let avAssest = AVAsset(url: assetUrl)
        let playerItem = AVPlayerItem(asset: avAssest)
        let player = AVPlayer(playerItem: playerItem)  // video path coming from above function
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        controller.present(playerViewController, animated: true, completion: nil)
        player.play()
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    // MARK: - DELETE FILE
    
    func deleteAsset(location: String?) {
        
        let savedLink = location
        let baseUrl = URL(fileURLWithPath: NSHomeDirectory()) //app's home directory
        let assetUrl = baseUrl.appendingPathComponent(savedLink!)
        
        do {
            try FileManager.default.removeItem(at: assetUrl)
            self.channel?.invokeMethod("videoDeleted", arguments: nil)
        } catch {
            print("An error occured deleting the file: \(error)")
        }
    }
}
