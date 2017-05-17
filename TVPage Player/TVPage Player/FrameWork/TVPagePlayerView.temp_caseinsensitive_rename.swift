//
//  TVPagePlayerView.swift
//  TvPagePlayer
//
//  Created by Dilip manek on 07/03/17.
//  Copyright © 2017 Dilip manek. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

//MARK: - Player Delegate
@objc public protocol TVPlayerDelegate {
    
    @objc optional func tvPlayerReady(flag: Bool)
    @objc optional func tvPlayerError(error: Error)
    @objc optional func tvPlayerMediaReady(flag:Bool)
    @objc optional func tvPlayerMediaError(error: Error)
    @objc optional func tvPlayerErrorForbidden(error: Error)
    @objc optional func tvPlayerErrorHTML5Forbidden(error: Error)
    @objc optional func tvPlayerMediaComplete(flag:Bool)
    @objc optional func tvPlayerCued(flag:Bool)
    @objc optional func tvPlayerMediaVideoended(flag:Bool)
    @objc optional func tvPlayerMediaVideoplaying(flag:Bool)
    @objc optional func tvPlayerMediaVideopaused(flag:Bool)
    @objc optional func tvPlayerMediaVideobuffering(flag:Bool)
    @objc optional func tvPlayerPlaybackQualityChange(flag:String)
    @objc optional func tvPlayerMediaProviderChange(flag:String)
    @objc optional func tvPlayerSeek(flag:String)
    @objc optional func tvPlayerVideoLoad(flag:Bool)
    @objc optional func tvPlayerVideoCued(flag:Bool)
}

enum TVPlayerState : Int {
    
    case tvPlayerUnstarted = -1
    case tvPlayerEnded = 0
    case tvPlayerPlaying = 1
    case tvPlayerPaused = 2
    case tvPlayerBuffering = 3
    case tvPlayerCued = 5
}

//MARK: - Player View
public class TVPagePlayerView: UIView {
    
    //Variable declaration
    var playerLayer: AVPlayerLayer! = AVPlayerLayer()
    public var player: AVPlayer? = AVPlayer()
    
    weak var delegate:TVPlayerDelegate?
    
    var lastScale: CGFloat = 0.0
    var arr_QualityID : NSMutableArray!
    var VideoEnded : Bool = false
    var played : Bool = false
    var isMuted : Bool = false
    var isCued : Bool = false
    var isfillscreen : Bool = false
   
    var totalTime : String!
    var dateFormatter : DateFormatter!
    var playerItem : AVPlayerItem!
    var playbackTimeObserver : Any!
    let QualityDropDown = DropDown()
    var arr_Qualitystring : NSMutableArray!
    var QualityIndex = 0
    var isVideoSliderChange = false
    
    var analiticsTimer: Timer!
    var IsVVanaliticsCall : Bool = false
    var UserLoginID = ""
    var UserChannelID = ""
    var UserVideoID = ""
    let playerViewController = AVPlayerViewController()
    
    //Outlet declaration
    @IBOutlet var constraintBottomPlayer: NSLayoutConstraint!
    @IBOutlet var ControllerbarView: UIView!
    @IBOutlet var videoViewConstraintsheight: NSLayoutConstraint!
    @IBOutlet var imgqualityHD: UIImageView!
    @IBOutlet var imgFullscreen: UIImageView!
    @IBOutlet var imgbtnQuality: UIImageView!
    @IBOutlet var imgVolumeSpeaker: UIImageView!
    @IBOutlet var imgPlayPause: UIImageView!
    @IBOutlet var viewMainPlayer: UIView!
    @IBOutlet var btn_play_paush: UIControl!
    @IBOutlet var videoSlider: UISlider!
    @IBOutlet var videoProgress: UIProgressView!
    @IBOutlet var lbl_Time: UILabel!
    @IBOutlet var lbl_Quality: UILabel!
    @IBOutlet var btn_Quality: UIControl!
    @IBOutlet var VollumeSlider: UISlider!
    @IBOutlet var btnVolume: UIControl!
    @IBOutlet var imgPoster: UIImageView!
    @IBOutlet var acti_Loderview: UIActivityIndicatorView!
    @IBOutlet var btn_FullScreen: UIControl!
    
    var isViewRemoved = false
    
    required public override init(frame: CGRect) {
        
        // 1. setup any properties here
        super.init(frame: frame)
        loadViewFromNib ()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TVPagePlayerView.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TVPagePlayerView.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        isViewRemoved = false
        UserDefaults.standard.setValue("YES", forKey: "isVideoPlayerOpen")
        UserDefaults.standard.synchronize()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TVPagePlayerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
    }
//MARK: - Tapped Event
    @IBAction func btn_FullScreenClicked(_ sender: UIControl) {
        
        playerViewController.player = self.player
        self.window?.rootViewController?.present(playerViewController, animated: true, completion: {
            
            if self.played {
                //play
                self.playerViewController.player!.play()
                
            } else {
                //pause
                self.playerViewController.player!.pause()
            }
            
            //Done button
            let doneButton = HelperObjC.findButton(on: self.playerViewController.view, withText: "Done")
            
            if doneButton != nil {
                
                doneButton?.addTarget(self, action: #selector(self.tappedOnDone), for: .touchUpInside)
            }
        })
    }
    func tappedOnDone() {
        
        print("RATE : \(String(describing: self.playerViewController.player?.rate))")
        
        if self.playerViewController.player?.rate == 0.0 {
        
           played = false
            
        } else {
        
            played = true
        }
        
        if played == true {
            //Play
            self.perform(#selector(play), with: nil, afterDelay: 0.1)
            
        } else {
            //Pause
            self.perform(#selector(pause), with: nil, afterDelay: 0.1)
        }
    }
    @IBAction func videoSliderChangeValue(_ sender: Any) {
        
        //video Slider Value Change
        let slider: UISlider? = (sender as? UISlider)
        isVideoSliderChange = true
        
        if slider?.value == 0.000000 {
            
            //slider value 0 then seek to 0
            player?.seek(to: kCMTimeZero, completionHandler: { (finished : Bool) in
                self.E_TvPlayerSeek()
                self.videoProgress.setProgress(0, animated: true)
            })
        }
        
        let changedTime: CMTime = CMTimeMakeWithSeconds(Float64((slider?.value)!), 1)
        isVideoSliderChange = true
        
        player?.seek(to: changedTime, completionHandler: {(finished: Bool) -> Void in
            self.E_TvPlayerSeek()
            self.videoProgress.setProgress((slider?.value)!, animated: true)
            
            print("videoSliderChangeValueEnd")
        })
    }
    @IBAction func videoSliderChangeValueEnd(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isVideoSliderChange = false
        }
    }
    @IBAction func btnVolumeClick(_ sender: UIControl) {
        
        if !isMuted {
            //Mute
            self.mute()
            
        } else {
            //Unmute
            self.unmute()
        }
    }
    @IBAction func VolumeSliderValueChange(_ sender: UISlider) {
        
        if !(self.player != nil) {
            
        } else {
            
            //set player volume
            if sender.value < 0.01 {
                
                isMuted = true
                imgVolumeSpeaker.image = getIconimage(iconname: "mute")
                
            } else {
                
                isMuted = false
                imgVolumeSpeaker.image = getIconimage(iconname: "speaker")
                
            }
            self.volume(vol: sender.value * 100)
        }
    }
    @IBAction func btn_QualityClick(_ sender: UIControl) {
        
        //quality button click
        QualityDropDown.show()
    }
    func setupQualityDropDown(arr:NSMutableArray , urlType: String) {
        
        //Quality dropdown setup
        var strqualityfull : String = ""
        
        //check video Type
        if urlType == "youtube" {
            
            for dict in arr {
                
                if let dic:NSDictionary = dict as? NSDictionary {
                    
                    if strqualityfull == "" {
                        
                        let str_QualityID = dic.value(forKey: "quality")as? String
                        let strQualityName = self.CheckQuality(str_QualityID: str_QualityID!)
                        strqualityfull = strQualityName
                        
                    } else {
                        
                        let str_QualityID = dic.value(forKey: "quality")as? String
                        let strQualityName = self.CheckQuality(str_QualityID: str_QualityID!)
                        strqualityfull =   "\(strqualityfull),\(strQualityName)"
                    }
                }
            }
        } else if urlType == "mp4" {
            
            for dict in arr {
                
                if let dic:NSDictionary = (dict as! NSDictionary) {
                    
                    if strqualityfull == "" {
                        
                        strqualityfull = (dic.value(forKey: "quality")as? String)!
                        
                    } else {
                        
                        strqualityfull =   "\(strqualityfull),\(dic.value(forKey: "quality")!)"
                    }
                }
            }
        }
        //set quality array
        var fullNameArr = strqualityfull.components(separatedBy: ",")
        fullNameArr = fullNameArr.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedDescending }
        fullNameArr.insert("Auto", at: fullNameArr.count)
        arr_Qualitystring = NSMutableArray.init(array: fullNameArr)
        
        //set Quality Dropdown
        QualityDropDown.anchorView = btn_Quality //set  quality dropdown position
        QualityDropDown.bottomOffset = CGPoint(x: 0, y: 0)
        QualityDropDown.direction = .top
        QualityDropDown.cellHeight = 40
        QualityDropDown.dataSource = fullNameArr
        QualityDropDown.selectRow(at: fullNameArr.count-1)
        imgqualityHD.isHidden = true
        
        //Action triggered on selection Dropdown
        QualityDropDown.selectionAction = { [unowned self] (index, item) in
            
            self.E_TvPlayerPlaybackQualityChange(Qname: item)
            
            if item == "144p" || item == "240p" || item == "360p" || item == "480p" || item == "Auto" {
                
                self.imgqualityHD.isHidden = true
                self.imgqualityHD.image = UIImage(named:"")
                
            } else {
                
                self.imgqualityHD.isHidden = false
                self.imgqualityHD.image = self.getIconimage(iconname: "qualityhd.png")
            }
            
            self.QualityIndex = index
            
            let dictSelectedData = NSMutableDictionary.init()
            dictSelectedData.setObject("\(index)", forKey: "index" as NSCopying)
            dictSelectedData.setObject("\(item)", forKey: "item" as NSCopying)
            
            self.perform(#selector(self.loadreplaceplayer(dictData:)), with: dictSelectedData, afterDelay: 0.5)  //Load selected Quality
        }
    }
    
    func loadreplaceplayer(dictData:NSDictionary) {
        
        //set selected quality URL
        let i:Index =  Index(dictData.value(forKey: "index") as! String)!
        let item = dictData.value(forKey: "item") as! String
        
        if item == "Auto" {
        
            self.QualityIndex = self.getAutoNetworkStreming()
            
            //check player in loded url type
            if self.player?.accessibilityHint == "mp4" {
                
                let videodic:NSDictionary = self.arr_QualityID.object(at: self.QualityIndex) as! NSDictionary
                let videoHD720URL:String = "https:\(videodic.value(forKey: "file")!)"
                let videoURL = NSURL(string: videoHD720URL )
                self.setTempplayervalue(videoURL: videoURL! as URL)
                
            } else {
                
                let videodic:NSDictionary = self.arr_QualityID.object(at: self.QualityIndex) as! NSDictionary
                let videoHD720URL:String = "\(videodic.value(forKey: "url")!)"
                let videoURL = NSURL(string: videoHD720URL )
                self.setTempplayervalue(videoURL: videoURL! as URL)
            }
        
        } else {
        
            //check player in loded url type
            if self.player?.accessibilityHint == "mp4" {
                
                let videodic:NSDictionary = self.arr_QualityID.object(at: i) as! NSDictionary
                let videoHD720URL:String = "https:\(videodic.value(forKey: "file")!)"
                let videoURL = NSURL(string: videoHD720URL )
                self.setTempplayervalue(videoURL: videoURL! as URL)
                
            } else {
                
                let videodic:NSDictionary = self.arr_QualityID.object(at: i) as! NSDictionary
                let videoHD720URL:String = "\(videodic.value(forKey: "url")!)"
                let videoURL = NSURL(string: videoHD720URL )
                self.setTempplayervalue(videoURL: videoURL! as URL)
            }
        }
    }
    @IBAction func btn_play_paush_click(_ sender: Any) {
        
        //play pause button click
        if !played {
            //play
            self.play()
        }
        else {
            //pause
            self.pause()
        }
        played = !played
    }
    func availableDuration() -> CMTime {
        
        if let range = self.player?.currentItem?.loadedTimeRanges.first {
            
            return CMTimeRangeGetEnd(range.timeRangeValue)
        }
        return kCMTimeZero
    }
    func customVideoSlider(duration :  CMTime)  {
        
        //set video slider
        videoSlider.maximumValue = Float(CMTimeGetSeconds(duration))
    }
    
    func monitoringPlayback(_ playerItem: AVPlayerItem) {
        
        //updated value slider and current time label
        weak var weakSelf = self
        
        self.playbackTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: nil, using: {(_ time: CMTime) -> Void in
            let currentSecond = self.player?.currentItem!.currentTime()
            let second11:Float = Float(CMTimeGetSeconds(currentSecond!))
            print("second11 : \(second11)")
            
            if second11 > 0.0 && self.isVideoSliderChange == false {
        
                if self.isViewRemoved == false {
                    
                    weakSelf?.videoSlider?.setValue(second11, animated: true)
                    let sssss : String = self.stringfromSeconds(value: Double(second11))
                    weakSelf?.lbl_Time?.text = "\(sssss)"
                }
            }
        })
    }
    func stringfromSeconds (value: Double) -> String {
        
        let ti = NSInteger(value)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
     
        if hours > 0 {
            
            return String(format: "%02ld:%02ld:%02ld", Int(hours), Int(minutes), Int(seconds))
            
        } else {
            
            return String(format: "%02ld:%02ld",  Int(minutes), Int(seconds))
            
        }
    }
    func dateFormatter1() -> DateFormatter {
        
        if !(dateFormatter != nil) {
            
            dateFormatter = DateFormatter()
        }
        return dateFormatter
    }
    
    func convertTime(second : CGFloat) -> String {
        
        let d : NSDate = NSDate(timeIntervalSince1970: TimeInterval(second))
        
        if second/3600 >= 1 {
            
            self.dateFormatter1().dateFormat = "HH:mm:ss"
            
        } else {
            
            self.dateFormatter1().dateFormat = "mm:ss"
        }
        let showtimeNew : String = self.dateFormatter1().string(from: d as Date)
        return showtimeNew
    }
    
    func moviePlayDidEnd(noti : NSNotification) {
        
        //event call
        played = false
        IsVVanaliticsCall = true
        stop()
        VideoEnded = true
        self.E_TvPlayerMediaComplete()
    }
    override public class var layerClass : AnyClass {
        
        return AVPlayerLayer.self
    }
    // Replace item to player
    func setTempplayervalue(videoURL : URL)  {
        
        let avpItem:AVPlayerItem  = AVPlayerItem.init(url: videoURL )
       
        if !(self.player != nil) {
            
            self.player = AVPlayer(playerItem: avpItem)
            self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            self.player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            self.player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
            self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: NSKeyValueObservingOptions.new, context: nil)
            
        } else {
            
            let currentSecond = self.player?.currentItem!.currentTime()
            self.player?.replaceCurrentItem(with: avpItem)
            player?.seek(to: currentSecond!)
            videoProgress.setProgress(Float(CMTimeGetSeconds(currentSecond!)), animated: false)
        }
    }
    public func getDATAandALLCheck(dict:[String : Any]) {
        
        do {
            
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error as NSError {
            
            print("error: \(error.localizedDescription)")
            
        }
        if  dict["entityIdParent"] != nil  {
            
            UserLoginID = dict["loginId"] as! String
            UserVideoID = dict["id"] as! String
            UserChannelID = dict["entityIdParent"] as! String
            
        } else {
            
            UserLoginID = ""
            UserVideoID = ""
            UserChannelID = ""
        }
        
        let dictasset:[String : Any] = dict["asset"] as! [String : Any]
        
        if dictasset["type"] != nil {
            
            let URLTYPE = dictasset["type"] as! String
            //check video type youtube or vimeo
            let thumb = dictasset["thumbnailUrl"] as! String
            
            if URLTYPE == "youtube" || URLTYPE == "vimeo" {
                
                let urlthumb = URL(string: thumb)!
                imgPoster.sd_setImage(with:urlthumb, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
                let videoID = dictasset["videoId"] as! String
                SetvideoUrl(StrURL: videoID, strType: URLTYPE, isplay: true)
                
            } else if URLTYPE == "mp4" {
                
                //check video type mp4
                let urlthumb = URL(string: thumb)!
                imgPoster.sd_setImage(with: urlthumb, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
                let arrassetsources:NSArray = dictasset["sources"] as! NSArray
                self.arr_QualityID = NSMutableArray()
                self.arr_QualityID = NSMutableArray.init(array: arrassetsources)
                
                setupQualityDropDown(arr: arr_QualityID!, urlType: URLTYPE)
                self.QualityIndex = 0
                let videodic:NSDictionary = arrassetsources[0] as! NSDictionary
                let str_QualityID = videodic.value(forKey: "quality")as? String
                
                if str_QualityID == "144p"||str_QualityID == "240p"||str_QualityID == "360p"||str_QualityID == "480p" {
                    
                    self.imgqualityHD.isHidden = true
                    self.imgqualityHD.image = UIImage(named:"")
                    
                } else {
                    
                    self.imgqualityHD.isHidden = false
                    self.imgqualityHD.image = self.getIconimage(iconname: "qualityhd.png")
                }
                
                //hlsUrl
                var DashorHlsURL:URL!
                if dictasset["hlsUrl"] != nil {
                    
                    DashorHlsURL = URL(string: "https:\(dictasset["hlsUrl"]!)")
                    
                } else if dictasset["dashUrl"] != nil {
                    
                    DashorHlsURL = URL(string: "https:\(dictasset["dashUrl"]!)")
                    
                } else {
                    
                    let videoHD720URL:String = "https:\(videodic.value(forKey: "file")!)"
                    DashorHlsURL = NSURL(string: videoHD720URL )! as URL
                }
                self.setplayervalue(videoURL:DashorHlsURL, Type: "mp4", isplay: true)
            }
        }
    }
    private func deallocObservers() {
        
        if ((self.player?.currentItem?.removeObserver(self, forKeyPath: "status")) != nil) {
            
        }
        if ((self.player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")) != nil) {
            
        }
        if ((self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")) != nil) {
            
        }
        if ((self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")) != nil) {
            
        }
        if ((self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")) != nil) {
            
        }
    }
    func setplayervalue(videoURL : URL , Type : String , isplay:Bool)  {
        
        VideoEnded = false
        hideControls(isAnimated: true)
        self.playerItem = AVPlayerItem.init(url: videoURL.absoluteURL )
        acti_Loderview.isHidden = false
        acti_Loderview.startAnimating()
        self.player = AVPlayer(playerItem: self.playerItem)
        //set player volume and volume slider ,Default System volume
        self.volume(vol: AVAudioSession.sharedInstance().outputVolume * 100)
        self.player?.accessibilityHint = Type
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: NSKeyValueObservingOptions.new, context: nil)
        self.btn_play_paush.isEnabled = false
        NotificationCenter.default.addObserver(self,selector: #selector(self.moviePlayDidEnd(noti:)),name: .AVPlayerItemDidPlayToEndTime,object: self.playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = viewMainPlayer.frame
        playerLayer.backgroundColor = UIColor.clear.cgColor
        self.E_TvPlayerReady()
        viewMainPlayer.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravityResize
        
        if isplay {
            
            IsVVanaliticsCall = true
            played = true
            play()
        }
    }
    func SetvideoUrl(StrURL : String , strType : String , isplay : Bool)  {
        
        arr_QualityID = NSMutableArray.init()
        if strType == "youtube" {
            
            TvPageExtractor.sharedInstance().extractVideo(forIdentifier: StrURL) { (dict:[AnyHashable : Any]?, error:Error?) in
                // print("\(dict)")
                if dict != nil {
                    
                    let d:NSDictionary = dict! as NSDictionary
                    let mutableArray : NSMutableArray = NSMutableArray.init(capacity:d.allKeys.count )
                    
                    for (key,val) in d {
                        
                        let str:String = "\(key)"
                        let dic1:NSDictionary = [
                            "quality" : str,
                            "url" : val,
                            ]
                        mutableArray.add(dic1)
                        self.arr_QualityID.add(dic1)
                    }
                    
                    let arrSorted = self.arr_QualityID.sortedArray(using: [NSSortDescriptor(key: "quality", ascending: false)])
                    
                    self.arr_QualityID.removeAllObjects()
                    self.arr_QualityID = NSMutableArray(array: arrSorted)
                    self.setupQualityDropDown(arr: self.arr_QualityID!, urlType: strType)
                    self.QualityIndex = self.getAutoNetworkStreming()
                    
                    let videodic:NSDictionary = self.arr_QualityID.object(at: self.QualityIndex) as! NSDictionary
                    let str_QualityID = videodic.value(forKey: "quality")as? String
                    let strQualityName = self.CheckQuality(str_QualityID: str_QualityID!)
                    
                    if strQualityName == "144p"||strQualityName == "240p"||strQualityName == "360p"||strQualityName == "480p" {
                        
                        self.imgqualityHD.image = UIImage(named:"")
                        
                    } else {
                        
                        self.imgqualityHD.image = self.getIconimage(iconname: "qualityhd")
                    }
                    
                    //self.btn_Quality.setTitle(strQualityName , for: .normal)
                    let videoHD720URL:String = "\(videodic.value(forKey: "url")!)"
                    let videoURL = NSURL(string: videoHD720URL )
                    // self.setplayervalue(videoURL: videoURL as! URL, Type: strType)
                    self.setplayervalue(videoURL: videoURL! as URL, Type: strType, isplay: isplay)
                }
            }
        } else if strType == "vimeo" {
            
            YTVimeoExtractor.shared().fetchVideo(withVimeoURL: StrURL, withReferer: nil, completionHandler: {(_ YTvideo: YTVimeoVideo?, _ error: Error?) in
                
                if YTvideo != nil {
                    
                    self.QualityIndex = 0
                    let highQualityURL = YTvideo?.highestQualityStreamURL()
                    // self.setplayervalue(videoURL: highQualityURL!, Type: strType)
                    self.setplayervalue(videoURL: highQualityURL!, Type: strType, isplay: isplay)
                }
            })
        }
    }
//MARK: - Convert Quality ID to Quality
    func CheckQuality(str_QualityID : String) -> String {
        
        var QualityTitle = ""
        
        if str_QualityID == "5" {
            
            QualityTitle = "240p"
            
        } else if str_QualityID == "18" {
            
            QualityTitle = "360p"
            
        } else if str_QualityID == "17" {
            
            QualityTitle = "144p"
            
        } else if str_QualityID == "22" {
            
            QualityTitle = "720p"
            
        } else if str_QualityID == "36" {
            
            QualityTitle = "240p"
            
        } else if str_QualityID == "43" {
            
            QualityTitle = "360p"
            
        } else if str_QualityID == "160" {
            
            QualityTitle = "144p"
            
        } else if str_QualityID == "133" {
            
            QualityTitle = "240p"
            
        } else if str_QualityID == "134" {
            
            QualityTitle = "360p"
            
        } else if str_QualityID == "135" {
            
            QualityTitle = "480p"
            
        } else if str_QualityID == "136" {
            
            QualityTitle = "720p"
            
        } else if str_QualityID == "137" {
            
            QualityTitle = "1080p"
            
        } else if str_QualityID == "264" {
            
            QualityTitle = "1440p"
            
        } else if str_QualityID == "266" {
            
            QualityTitle = "2160p"
            
        } else if str_QualityID == "298" {
            
            QualityTitle = "720p"
            
        } else if str_QualityID == "299" {
            
            QualityTitle = "1080p"
            
        } else if str_QualityID == "278" {
            
            QualityTitle = "144p"
            
        } else if str_QualityID == "242" {
            
            QualityTitle = "240p"
            
        } else if str_QualityID == "243" {
            
            QualityTitle = "360p"
            
        } else if str_QualityID == "244" {
            
            QualityTitle = "480p"
            
        } else if str_QualityID == "247" {
            
            QualityTitle = "720p"
            
        } else if str_QualityID == "248" {
            
            QualityTitle = "1080p"
            
        } else if str_QualityID == "271" {
            
            QualityTitle = "1440p"
            
        } else if str_QualityID == "313" {
            
            QualityTitle = "2060p"
            
        } else if str_QualityID == "302" {
            
            QualityTitle = "720p"
            
        } else if str_QualityID == "308" {
            
            QualityTitle = "1440p"
            
        } else if str_QualityID == "303" {
            
            QualityTitle = "1080p"
            
        } else if str_QualityID == "315" {
            
            QualityTitle = "2160p"
            
        }
        return QualityTitle
    }
    
//MARK: - AVPlayer observeValue , State
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if self.isViewRemoved == false {
         
            let avpItem : AVPlayerItem = object as! AVPlayerItem
            
            if keyPath == "status" {
                
                if  avpItem.status == .readyToPlay {
                    
                    IsVVanaliticsCall = true
                    self.Analytics_Channel_Impression(LoginID: UserLoginID)
                    isCued = true
                    showControls(isAnimated: true)
                    //default Event call
                    E_TvPlayerMediaReady()
                    E_TvPlayerCued()
                    acti_Loderview.isHidden = true
                    acti_Loderview.stopAnimating()
                    btn_play_paush.isEnabled = true
                    let duration : CMTime = (avpItem.duration)
                    self.customVideoSlider(duration: duration)
                    self.monitoringPlayback((player?.currentItem)!)
                    
                } else if  avpItem.status == .failed {
                    
                    self.E_TvPlayerMediaError()
                    hideControls(isAnimated: true)
                }
                
            } else if (keyPath == "loadedTimeRanges") {
                
                // let timeInterval: TimeInterval = self.availableDuration()
                // let timeInterval1: CMTime = player!.currentItem!.currentTime()
                let timeInterval1: CMTime = self.availableDuration()
                let duration: CMTime = player!.currentItem!.duration
                let totalDuration: Float = Float(CMTimeGetSeconds(duration))
                let abcd: Float = Float(Float(CMTimeGetSeconds(timeInterval1)) + Float(totalDuration))
                videoProgress.setProgress(abcd, animated: true)
                
            } else if (keyPath == "playbackBufferEmpty") {
                
                acti_Loderview.isHidden = false
                self.bringSubview(toFront: acti_Loderview)
                acti_Loderview.startAnimating()
                E_TvPlayerMediaVideobuffering()
                
            } else if (keyPath == "playbackLikelyToKeepUp") {
                
                E_TvPlayerMediaVideobuffering()
                acti_Loderview.isHidden = true
                acti_Loderview.stopAnimating()
                
            } else if (keyPath == "playbackBufferFull"){
                
                E_TvPlayerMediaVideobuffering()
                acti_Loderview.isHidden = true
                acti_Loderview.stopAnimating()
            }
            
        } else {
            
            print("View remove from super view")
        }
    }
//MARK: - Default
    public func show(frame:CGRect , view:UIView) {
       
        hideControls(isAnimated: false)
        self.frame = frame
        self.layoutIfNeeded()
        view.addSubview(self)
        
        self.videoSlider.setThumbImage(getIconimage(iconname: "circle@2x"), for: .normal)
        self.VollumeSlider.setThumbImage(getIconimage(iconname: "circle@2x"), for: .normal)
        
        videoViewConstraintsheight.constant = frame.size.height
        self.playerLayer.frame = CGRect(x: self.playerLayer.frame.origin.x, y: self.playerLayer.frame.origin.y, width: self.playerLayer.frame.size.width, height: self.videoViewConstraintsheight.constant)
        self.layoutIfNeeded()
        
        view.layoutIfNeeded()
        imgPlayPause.image = getIconimage(iconname: "play")
        imgVolumeSpeaker.image = getIconimage(iconname: "speaker")
        imgbtnQuality.image = getIconimage(iconname: "quality")
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        viewMainPlayer.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(pinchGestureRecognizer)
        self.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.taptovideoview(_:)))
        viewMainPlayer.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    func volumeChanged(notification: NSNotification) {
        
        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        print("volume:-\(volume)")
        self.volume(vol: volume * 100)
    }
    func taptovideoview(_ sender: UITapGestureRecognizer) {
        
        if self.constraintBottomPlayer.constant < 0 {
            
            self.showControls(isAnimated: true)
            
        } else {
            
            self.hideControls(isAnimated: true)
        }
    }
    func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
            //lastScale = gestureRecognizer.scale
            lastScale = (gestureRecognizer.view!.layer.value(forKeyPath: "transform.scale")! as! CGFloat)
        }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            // let currentScale: CGFloat = (gestureRecognizer.view!.layer.value(forKeyPath: "transform.scale")! as! CGFloat)
            let currentScale: CGFloat = (viewMainPlayer.layer.value(forKeyPath: "transform.scale")! as! CGFloat)
            // Constants to adjust the max/min values of zoom
            let kMaxScale: CGFloat = 2.0
            let kMinScale: CGFloat = 0.5
            var newScale: CGFloat = 1 - (lastScale - gestureRecognizer.scale)
            newScale = min(newScale, kMaxScale / currentScale)
            newScale = max(newScale, kMinScale / currentScale)
            let transform = viewMainPlayer.transform.scaledBy(x: newScale, y: newScale)
            viewMainPlayer.transform = transform
            lastScale = gestureRecognizer.scale
        }
    }
//MARK: - EVENTS
    public func  E_TvPlayerReady() {
        
        if(player != nil) {
            
            delegate?.tvPlayerReady?(flag: true)
            
        } else {
            
            delegate?.tvPlayerReady?(flag: false)
        }
    }
    public func E_TvPlayerError() {
        
        if (player?.currentItem?.error != nil) {
            
            //delegate?.TvPlayerError?(flag: (player?.currentItem?.error)!)
        }
        //delegate?.TvPlayerError?(flag:0 as! Error)
    }
    public func E_TvPlayerMediaReady()  {
        
        E_TvPlayerVideoLoad()
        if playerLayer.player?.status == .readyToPlay {
            
            delegate?.tvPlayerMediaReady?(flag: true)
            
        } else {
            
            delegate?.tvPlayerMediaReady?(flag: false)
        }
    }
    public  func E_TvPlayerMediaError()  {
        
        //delegate?.TvPlayerMediaError?(flag: (player?.currentItem?.error)!)
        
    }
    public func E_TvPlayerErrorForbidden() {
        
        //delegate?.TvPlayerErrorForbidden?(flag: (player?.currentItem?.error)!)
        
    }
    public func E_TvPlayerErrorHTML5Forbidden() {
        
        //delegate?.TvPlayerErrorHTML5Forbidden?(flag: (player?.currentItem?.error)!)
        
    }
    public func E_TvPlayerMediaComplete() {
        
        delegate?.tvPlayerMediaComplete?(flag: VideoEnded)
        
    }
    public  func E_TvPlayerCued() {
        
        delegate?.tvPlayerCued?(flag: isCued)
        
    }
    public func E_TvPlayerMediaVideoended() {
        
        delegate?.tvPlayerMediaVideoended?(flag: VideoEnded)
        
    }
    public func E_TvPlayerMediaVideoplaying() {
        
        if player?.rate != 0 {
            
            delegate?.tvPlayerMediaVideoplaying?(flag: true)
            
        } else {
            
           delegate?.tvPlayerMediaVideoplaying?(flag: false)
            
        }
    }
    public func E_TvPlayerMediaVideopaused() {
        
        if player?.rate == 0 {
            
            delegate?.tvPlayerMediaVideopaused?(flag: true)
            
        } else {
            
            delegate?.tvPlayerMediaVideopaused?(flag: false)
        }
    }
    public func E_TvPlayerMediaVideobuffering() {
        
         delegate?.tvPlayerMediaVideobuffering?(flag: (player?.currentItem?.isPlaybackBufferEmpty)!)
        
    }
    public func E_TvPlayerPlaybackQualityChange(Qname:String){
        
        delegate?.tvPlayerPlaybackQualityChange?(flag:Qname )
        
    }
    public func E_TvPlayerMediaProviderChange() {
        
        delegate?.tvPlayerMediaProviderChange?(flag:"CurrentProvider" )
        
    }
    public func E_TvPlayerSeek() {
        
        let currentSecond : CGFloat = CGFloat(playerItem.currentTime().value) / CGFloat(playerItem.currentTime().timescale)
        let timeString: String = self.convertTime(second: currentSecond)
        delegate?.tvPlayerSeek?(flag:timeString )
    }
    public func E_TvPlayerVideoLoad() {
        
        if playerLayer.player?.status == .readyToPlay {
            
            delegate?.tvPlayerVideoLoad?(flag: true)
            
        } else {
            
            delegate?.tvPlayerVideoLoad?(flag: false)
            
        }
    }
    public func E_TvPlayerVideoCued() {
        
        delegate?.tvPlayerVideoCued?(flag: isCued)
        
    }
//MARK: - Functions
    func analiticsMethod() {
        
        let uuid = UUID().uuidString
        let cTime:String = "\(getCurrentTime())"
        let druation:String = "\(getDuration())"
        self.Analytics_View_Time(LoginID: UserLoginID, ChannelID: UserChannelID, VideoID: UserVideoID, SessionID: uuid, CurrentVideoTime: cTime, VideoDuration: druation, ViewTime: "3")
    }
    public func loadVideo(StrURL : String , strType : String)  {
        
        UserLoginID = ""
        UserVideoID = ""
        UserChannelID = ""
        stop()
        SetvideoUrl(StrURL: StrURL, strType: strType, isplay: true)
    }
    public func cueVideo(StrURL : String , strType : String)  {
        
        // stop()
        stop()
        SetvideoUrl(StrURL: StrURL, strType: strType, isplay: false)
    }
    func call_vv_analitics_method() {
        
        self.Analytics_Video_View(LoginID: UserLoginID, ChannelID: UserChannelID, VideoID: UserVideoID)
    }
    public func play()  {
        
        isCued = false
        if IsVVanaliticsCall {
            
            IsVVanaliticsCall = false
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(call_vv_analitics_method), userInfo: nil, repeats: false)
            
        }
        self.player?.play()
        E_TvPlayerCued()
        E_TvPlayerMediaVideoplaying()
        
        if (analiticsTimer == nil) {
            
            analiticsTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(analiticsMethod), userInfo: nil, repeats: true)

        }
        imgPlayPause.image = getIconimage(iconname: "pause")
    }
    
    public func pause() {
        
        self.player?.pause()
        E_TvPlayerMediaVideopaused()
        // btn_play_paush.setFAIcon(icon: .FAPlay, forState: .normal)
        imgPlayPause.image = getIconimage(iconname: "play")
        DispatchQueue.main.async {
            if (self.analiticsTimer != nil) {
                self.analiticsTimer.invalidate()
                self.analiticsTimer = nil
                //  self.deallocObservers()
            }
        }
    }
    public func stop() {
        
        pause()
        videoProgress.setProgress(0.0, animated: true)
        seek(time: 0.0)
        //volume(vol: 0.0)
    }
    public func volume(vol : Float) {
        
        let volummmm = vol / 100
        self.VollumeSlider.value = volummmm
        
        if (self.player != nil) {
            
            self.player?.volume = volummmm
        }
        if volummmm <= 0 {
            
            imgVolumeSpeaker.image = getIconimage(iconname: "mute")
            
        } else {
            
            imgVolumeSpeaker.image = getIconimage(iconname: "speaker")
        }
    }
    public func mute() {
        
        isMuted = true
        self.volume(vol: 0)
        self.VollumeSlider.value = 0
        imgVolumeSpeaker.image = getIconimage(iconname: "mute")
    }
    public func unmute() {
        
        isMuted = false
        imgVolumeSpeaker.image = getIconimage(iconname: "speaker")
        self.volume(vol: AVAudioSession.sharedInstance().outputVolume * 100)
        //self.VollumeSlider.value = 0.5
    }
    public func seek(time : Double) {
        
        let preferredTimeScale : Int32 = 1
        let timeing1:CMTime = CMTimeMakeWithSeconds(time, preferredTimeScale)
        //CMTime targetTime = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
        player?.seek(to: timeing1)
    }
    public func setPoster(image : UIImage) {
        
        imgPoster.image = image
    }
    public func resize(width : Float, height : Float, X: Float,Y : Float, zoomRatio : Float) {
        
        btnVolume.isHidden = false
        btn_Quality.isHidden = false
        VollumeSlider.isHidden = false
        lbl_Time.isHidden = false
        btn_FullScreen.isHidden = false
        
        if width < 320 {
            
            fix_height_width()
        }
        self.frame = CGRect(x: CGFloat(X), y: CGFloat(Y), width:  CGFloat(width), height:  CGFloat(width))
        // self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.layoutIfNeeded()
        viewMainPlayer.frame = self.frame
        playerLayer.frame = self.frame
        let transform = viewMainPlayer.transform.scaledBy(x: CGFloat(zoomRatio), y: CGFloat(zoomRatio))
        viewMainPlayer.transform = transform
        playerLayer.videoGravity = AVLayerVideoGravityResize
    }
    public func fix_height_width() {
        
        btnVolume.isHidden = true
        btn_Quality.isHidden = true
        VollumeSlider.isHidden = true
        lbl_Time.isHidden = true
        btn_FullScreen.isHidden = true
    }
    public func getVolume() -> Int {
        
        let vol : Int = Int((self.player?.volume)!) * 100
        return vol
    }
    
    public func getState() -> Int {
        
        if playerLayer.player?.status != .readyToPlay {
            
            return TVPlayerState.tvPlayerUnstarted.rawValue
            
        } else if VideoEnded {
            
            return  TVPlayerState.tvPlayerEnded.rawValue
            
        } else if isCued {
            
            return  TVPlayerState.tvPlayerCued.rawValue
            
        } else if (player?.currentItem?.isPlaybackBufferEmpty)! {
            
            return TVPlayerState.tvPlayerBuffering.rawValue
            
        } else if self.player?.rate == 0.0 {
            
            return  TVPlayerState.tvPlayerPaused.rawValue
            
        } else {
            
            return  TVPlayerState.tvPlayerPlaying.rawValue
        }
    }
    public func getCurrentTime() -> Int {
        
        let cmTime = self.player?.currentItem?.currentTime()
        let time : Int = Int(CMTimeGetSeconds(cmTime!))
        return time
    }
    public func getDuration() -> Double {
        
        let cmTime = self.player?.currentItem?.duration
        let duration : Double = Double(CMTimeGetSeconds(cmTime!))
        return duration
    }
    public func getQuality() -> Int {
        
        //return current quality index of getQualityLevels()
        return self.QualityIndex
    }
    public func setQuality(index: Int) {
        
        let _ : String = arr_Qualitystring.object(at: index) as! String
        //self.btn_Quality.setTitle(titlestr, for: .normal)
        let videodic:NSDictionary = self.arr_QualityID.object(at: index) as! NSDictionary
        
        if self.player?.accessibilityHint == "mp4" {
            
            let videoHD720URL:String = "http:\(videodic.value(forKey: "file")!)"
            let videoURL = NSURL(string: videoHD720URL )
            self.setTempplayervalue(videoURL: videoURL! as URL)
            
        } else {
            
            let videoHD720URL:String = "\(videodic.value(forKey: "url")!)"
            let videoURL = NSURL(string: videoHD720URL )
            self.setTempplayervalue(videoURL: videoURL! as URL)
            
        }
    }
    public func getQualityLevels() -> NSMutableArray {
        //return quality array
        return arr_Qualitystring
    }
    public func getHeight() -> Float {
        
        let height : Float = Float(self.frame.size.height)
        return height
    }
    public func getWidth() -> Float {
        
        let width : Float = Float(self.frame.size.width)
        return width
    }
    public func disableControls()  {
        
        btnVolume.isEnabled = false
        btn_Quality.isEnabled = false
        videoSlider.isEnabled = false
        VollumeSlider.isEnabled = false
        btn_Quality.isEnabled = false
        btn_FullScreen.isEnabled = false
    }
    public  func enableControls()  {
        
        btnVolume.isEnabled = true
        btn_Quality.isEnabled = true
        videoSlider.isEnabled = true
        VollumeSlider.isEnabled = true
        btn_Quality.isEnabled = true
        btn_FullScreen.isEnabled = true
    }
    public func hideControls(isAnimated:Bool) {
        
        if isAnimated == true {
        
            self.constraintBottomPlayer.constant = -55
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.layoutIfNeeded()
                
            }, completion: {_ in
                print("hide control")
            })
        } else {
        
            self.constraintBottomPlayer.constant = -55
            self.layoutIfNeeded()
        }
    }
    public func showControls(isAnimated:Bool) {
        
        if isAnimated == true {
            
            self.constraintBottomPlayer.constant = 0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.layoutIfNeeded()
                
            }, completion: {_ in
                print("show control")
            })
            
        } else {
            
            self.constraintBottomPlayer.constant = 0
            self.layoutIfNeeded()
        }
    }
    func getIconimage(iconname:String) -> UIImage {
        
        return UIImage(named:iconname)!
    
    }
//MARK: -  Analytics
    func Analytics_Channel_Impression(LoginID:String){
        
        if LoginID != "" {
            
            // https://api.tvpage.com/v1/__tvpa.gif?li=1758929&X-login-id=1758929
            let strURL = ("https://api.tvpage.com/v1/__tvpa.gif?li=\(LoginID)&X-login-id=\(LoginID)&rt=ci")
            print("CI METHOD CALL")
            let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 180.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    
                } else {
                    
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse ?? "")
                }
            })
            dataTask.resume()
        }
    }
    func Analytics_Video_View(LoginID:String,ChannelID:String,VideoID:String) {
        
        // https://api.tvpage.com/v1/__tvpa.gif?li=1758381&X-login-id=1758381&pg= &vd=
        if LoginID != "" {
            
            let strURL = ("https://api.tvpage.com/v1/__tvpa.gif?li=\(LoginID)&X-login-id=\(LoginID)&pg=\(ChannelID)&vd=\(VideoID)&rt=vv")
            print("VV METHOD CALL")
            let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 180.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                if (error != nil) {
                    //print(error!)
                } else {
                    
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                }
            })
            dataTask.resume()
        }
    }
    func Analytics_View_Time(LoginID:String,ChannelID:String,VideoID:String,SessionID:String,CurrentVideoTime:String,VideoDuration:String,	ViewTime:String) {
        
        if LoginID != "" {
            
            // https://api.tvpage.com/v1/__tvpa.gif?li=1758381&X-login-id=1758381&pg=&vd=&vvs=&vct=&vdr=&vt=
            let strURL = ("https://api.tvpage.com/v1/__tvpa.gif?li=\(LoginID)&X-login-id=\(LoginID)&pg=\(ChannelID)&vd=\(VideoID)&vvs=\(SessionID)&vct=\(CurrentVideoTime)&vdr=\(VideoDuration)&vt=\(ViewTime)&rt=vt")
            print("VT METHOD CALL")
            isVideoSliderChange = false
            let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 180.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                if (error != nil) {
                    //print(error!)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                }
            })
            dataTask.resume()
        }
    }
    public func Analytics_Product_Impression(LoginID:String,ChannelID:String,VideoID:String,ProductID:String, completion : ((String)->())?){
        
        if LoginID != "" {
            
            // https://api.tvpage.com/v1/__tvpa.gif?li=1758381&X-login-id=1758381&pg=&vd=&vvs=&vct=&vdr=&vt=
            let strURL = ("https://api.tvpage.com/v1/__tvpa.gif?li=\(LoginID)&X-login-id=\(LoginID)&pg=\(ChannelID)&vd=\(VideoID)&ct=\(ProductID)&rt=pi")
            print("PI METHOD CALL")
            let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 180.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                 print("Analytics_Product_Impression")
                var errorStr = ""
                if (error != nil) {
                    
                    errorStr = (error?.localizedDescription)!
                    if completion != nil {
                        
                        let isVideoPlayerOpen = UserDefaults.standard.object(forKey: "isVideoPlayerOpen") as! String
                        UserDefaults.standard.synchronize()
                        
                        if isVideoPlayerOpen == "YES" {
                            
                            print("Application is back1")
                            completion!(errorStr)
                        } else {
                            
                            print("Application is back2")
                        }
                    }
                    //print(error!)
                } else {
                    
                    let httpResponse = response as? HTTPURLResponse
                    if completion != nil {
                        
                        let isVideoPlayerOpen = UserDefaults.standard.object(forKey: "isVideoPlayerOpen") as! String
                        UserDefaults.standard.synchronize()
                        
                        if isVideoPlayerOpen == "YES" {
                            
                            completion!(errorStr)
                            print(httpResponse!)
                            print("Application is back11")
                            
                        } else {
                        
                            print("Application is back22")
                        }
                    }
                }
            })
            dataTask.resume()
        }
    }
    public func Analytics_Product_Click(LoginID:String,ChannelID:String,VideoID:String,ProductID:String, completion : ((String)->())?) {
        
        self.played = false
        if LoginID != "" {
            
            // https://api.tvpage.com/v1/__tvpa.gif?li=1758381&X-login-id=1758381&pg=&vd=&vvs=&vct=&vdr=&vt=
            let strURL = ("https://api.tvpage.com/v1/__tvpa.gif?li=\(LoginID)&X-login-id=\(LoginID)&pg=\(ChannelID)&vd=\(VideoID)&ct=\(ProductID)&rt=pk")
            print("PK METHOD CALL")
            let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 180.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                var errorStr = ""
                print("Analytics_Product_Click")
                if (error != nil) {
                    
                    errorStr = (error?.localizedDescription)!
                    if completion != nil {
                        
                        completion!(errorStr)
                        
                    }
                } else {
                    
                    let httpResponse = response as? HTTPURLResponse
                    if completion != nil {
                        
                        completion!(errorStr)
                    }
                    print(httpResponse!)
                }
            })
            dataTask.resume()
        }
    }
    func getAutoNetworkStreming() -> Int {
        
        let strNetworkType = HelperObjC.getNewtworkType()
        
        var autoNetworkStreming = 0
        
        if self.arr_QualityID.count > 0 {
            
            if strNetworkType == "NoWifiOrCellular" || strNetworkType == "2G" || strNetworkType == "" {
                
                autoNetworkStreming = self.arr_QualityID.count - 1
                
            } else if strNetworkType == "3G" {
                
                if self.arr_QualityID.count > 1 {
                    
                    autoNetworkStreming = 1
                    
                } else {
                    
                    autoNetworkStreming = 0
                }
                
            } else if strNetworkType == "4G" || strNetworkType == "Wifi" || strNetworkType == "LTE" {
                
                autoNetworkStreming = 0
            }
        }
        print("strNetworkType : \(String(describing: strNetworkType))")
        print("autoNetworkStreming : \(autoNetworkStreming)")
        return autoNetworkStreming
    }
//MARK: - Application enter background / foreground
    func applicationDidEnterBackground() {
        
        self.pause()
    }
    func applicationWillEnterForeground() {
        
        if played == true {
            //Play
            self.play()
            
        } else {
            //Pause
            self.pause()
        }
    }
    override public func removeFromSuperview() {
        
        print("removeFromSuperview")
        
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil);
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil);
        
        isViewRemoved = true
        UserDefaults.standard.setValue("NO", forKey: "isVideoPlayerOpen")
        UserDefaults.standard.synchronize()
        self.pause()
    }
}
