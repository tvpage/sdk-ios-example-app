//
//  videoPlaybackVC.swift
//  TVPage Player
//
//  Created by   on 22/03/17.
//
//

import Foundation
import UIKit
import TVP

class cellVideoPlayback: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
}

class videoPlaybackVC:MTViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout ,TVPlayerDelegate {
    
    @IBOutlet var ctrlsideMenu: UIControl!
    @IBOutlet var imgsideMenu: UIImageView!
    @IBOutlet var collectVideoPlayback: UICollectionView!
    @IBOutlet var lblPublishDate: UILabel!
    @IBOutlet var lblDuration: UILabel!
    @IBOutlet var imgDown: UIImageView!
    @IBOutlet var lblDiscription: UILabel!
    @IBOutlet var lblVideoTitle: UILabel!
    @IBOutlet var lblDiscriptHeight: NSLayoutConstraint!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblNoRelatedProduct: UILabel!
    @IBOutlet var btnBackWidth: NSLayoutConstraint!
    @IBOutlet var viewTVP: UIView!
    var btnBackWidthConst = 0
    var TVPView:TVPagePlayerView!
    var isDownTapCall:Bool!
    var dictVideoData = NSDictionary()
    var arryCollect = NSMutableArray()
    var forloopIndex = 0
    var isGetProductsOnVideoAPICalling:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(isInternetConnectionAvailable), name: NSNotification.Name(rawValue: "isInternetConnectionAvailable"), object: nil)
        
        btnBackWidth.constant = CGFloat(btnBackWidthConst)
        lblNoRelatedProduct.isHidden = false
        self.collectVideoPlayback.isHidden = true
        isDownTapCall = false
        
        TVPView = TVPagePlayerView.init(frame: CGRect(x: 50, y: 200, width: 350, height: 200))
        self.viewTVP.addSubview(TVPView)
        TVPView.delegate = self
        viewTVP.layoutIfNeeded()
        TVPView.show(frame: CGRect(x:0,y:0,width:viewTVP.frame.size.width,height:viewTVP.frame.size.height), view: self.viewTVP)
        TVPView.getDATAandALLCheck(dict: dictVideoData as! [String : Any])
        let dict_asset = dictVideoData.value(forKey:"asset") as! NSDictionary
        lblDuration.text = ("Duration : \((dict_asset.value(forKey:"prettyDuration") as! String))")
        lblVideoTitle.text = ("\( (dictVideoData.value(forKey:"title") as! String))")
        
        let dou_str = (dictVideoData.value(forKey:"date_created") as! String)
        let date = NSDate(timeIntervalSince1970: Double(dou_str)!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from:date as Date)
        lblPublishDate.text = ("PublishDate : \(dateString)")
        scrollView.delaysContentTouches = false
        
        self.getProductsOnVideoAPICalling()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.lblDiscriptHeight.constant = 0
        
        TVPView.resumePlayer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "isInternetConnectionAvailable"), object: nil)
        
        TVPView.stopPlayer()
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func callanalytics()  {
        print(arryCollect)
        self.forloopIndex += 1
        
        if forloopIndex < arryCollect.count+1 {
            
            let dict : NSDictionary = arryCollect.object(at: forloopIndex-1) as! NSDictionary
            
            if  dict["loginId"] != nil {
                
                if dict["entityIdParent"] != nil {
                    
                    if dict["entityIdChild"] != nil {
                        
                        if dict["id"] != nil {
                            
                            let loginID = dict.value(forKey: "loginId")
                            let ChannelID = dict.value(forKey: "entityIdParent")
                            let VideoID = dict.value(forKey: "entityIdChild")
                            let prodID = dict.value(forKey: "id")
                            TVPView.analyticsProductImpression(loginID: loginID as! String, channelID: ChannelID as! String, videoID: VideoID as! String, productID: prodID as! String) { (str:String) in
                                
                                self.callanalytics()
                            }
                        } else {
                            
                            self.callanalytics()
                        }
                        
                    } else {
                        
                        self.callanalytics()
                    }
                } else {
                    
                    self.callanalytics()
                }
            } else {
                
                self.callanalytics()
            }
        } else {
            
        }
    }
    //MARK: - CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arryCollect.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellVideoPlayback", for: indexPath) as! cellVideoPlayback
        let dictionorydata = arryCollect[indexPath.row] as! NSDictionary
        let url_string = dictionorydata.value(forKey:"imageUrl") as! String
        let url =  URL(string:url_string)!
        cell.imgName.sd_setImage(with: url, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectVideoPlayback.frame.size.height, height: self.collectVideoPlayback.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.callProductClickAnalytics(dict: arryCollect.object(at: indexPath.row) as! NSDictionary)
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductCardVC") as! ProductCardVC
        SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
        initVC.arr_collection_view.addObjects(from: [arryCollect])
        initVC.selectedIndex = indexPath.row
        self.present(initVC, animated: true, completion: nil)
    }
//MARK: - Action Event
    
    func callProductClickAnalytics(dict : NSDictionary) {
        
        if  dict["loginId"] != nil {
            
            if dict["entityIdParent"] != nil {
                
                if dict["entityIdChild"] != nil {
                    
                    if dict["id"] != nil {
                        
                        let loginID = dict.value(forKey: "loginId")
                        let ChannelID = dict.value(forKey: "entityIdParent")
                        let VideoID = dict.value(forKey: "entityIdChild")
                        let prodID = dict.value(forKey: "id")
                        TVPView.analyticsProductClick(loginID: loginID as! String, channelID: ChannelID as! String, videoID: VideoID as! String, productID: prodID as! String) { (str:String) in
                            print(str)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sideMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
        TVPView.stopPlayer()
    }
    
    @IBAction func TagTap(_ sender: Any) {
        
        if arryCollect.count > 0 {
            
            self.callProductClickAnalytics(dict: arryCollect.object(at: 0) as! NSDictionary)
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductCardVC") as! ProductCardVC
            SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
            initVC.arr_collection_view.addObjects(from: [arryCollect])
            initVC.selectedIndex = 0
            self.present(initVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        
        SNavigataionVC.popViewController(animated: true)
    }
    @IBAction func downTap(_ sender: Any) {
        
        let labelHeight = rectForText(text: lblDiscription.text! , font: UIFont(name: FontName.DosisRegular, size: CGFloat(14))!)
        if !isDownTapCall {
            
            self.lblDiscriptHeight.constant = labelHeight
            self.isDownTapCall = true
            self.imgDown.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            
            UIView.animate(withDuration: 0.3, animations:{
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            
            self.lblDiscriptHeight.constant = 0
            self.isDownTapCall = false
            self.imgDown.transform = CGAffineTransform(rotationAngle: 0)
            
            UIView.animate(withDuration: 0.3, animations:{
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
//MARK: - calculate Label Height
    func rectForText(text: String, font: UIFont) -> CGFloat {
        
        let maxSize = CGSize(width: (self.view.frame.size.width) - 20, height:500.0)
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size.height
    }
    func tvPlayerError(error: Error) {
        
        print("delegate_TvPlayerError :\(error)")
    }
    func tvPlayerMediaReady(flag: Bool) {
        
        print("delegate_TvPlayerMediaReady :\(flag)")
    }
    func tvPlayerMediaError(error: Error) {
        
        print("delegate_TvPlayerMediaError :\(error)")
    }
    func tvPlayerErrorForbidden(error: Error) {
        
        print("delegate_TvPlayerErrorForbidden:\(error)")
    }
    func tvPlayerErrorHTML5Forbidden(error: Error) {
        
        print("delegate_TvPlayerErrorHTML5Forbidden:\(error)")
    }
    func tvPlayerMediaComplete(flag: Bool) {
        
        print("delegate_TvPlayerMediaComplete :\(flag)")
    }
    func tvPlayerCued(flag: Bool) {
        
        print("delegate_TvPlayerCued :\(flag)")
    }
    func tvPlayerMediaVideoended(flag: Bool) {
        
        print("delegate_TvPlayerMediaVideoended :\(flag)")
    }
    func tvPlayerMediaVideoplaying(flag: Bool) {
        
        print("delegate_playing:\(flag)")
    }
    func tvPlayerMediaVideopaused(flag: Bool) {
        
        print("delegate_paused:\(flag)")
    }
    func tvPlayerMediaVideobuffering(flag: Bool) {
        
        print("delegate_TvPlayerMediaVideobuffering:\(flag)")
    }
    func tvPlayerPlaybackQualityChange(flag: String) {
        
        print("delegate_TvPlayerPlaybackQualityChange:\(flag)")
    }
    func tvPlayerMediaProviderChange(flag: String) {
        
        print("delegate_TvPlayerMediaProviderChange:\(flag)")
    }
    func tvPlayerSeek(flag: String) {
        
        print("delegate_TvPlayerSeek:\(flag)")
    }
    func tvPlayerVideoLoad(flag: Bool) {
        
        print("delegate_TvPlayerVideoLoad:\(flag)")
    }
    func tvPlayerVideoCued(flag: Bool) {
        
        print("delegate_TvPlayerVideoCued:\(flag)")
    }
//MARK: - Check Internet Connection 
    func isInternetConnectionAvailable(_ notification: Notification) {
        
        let dictNetworkStatus = notification.object as! NSDictionary
        let networkStatus = dictNetworkStatus["networkStatus"] as! String
        
        if networkStatus == "YES" {
            
            print("Network Available")
            self.getProductsOnVideoAPICalling()
            
        } else {
        
            print("Network Not Available")
        }
    }
//MARK: - GetproductsOnVideo API Calling
    func getProductsOnVideoAPICalling() {
    
        if isGetProductsOnVideoAPICalling == false {
        
            isGetProductsOnVideoAPICalling = true
            
            let videoid = dictVideoData.value(forKey:"id") as! String
            TvpApiClass.GetproductsOnVideo(LoginID:appDelegateShared.loginID, VideoID: videoid) { (arrproductlist:NSArray,strerror:String) in
                
                self.isGetProductsOnVideoAPICalling = false
                
                if strerror == "" {
                    
                    self.arryCollect =  NSMutableArray(array: arrproductlist)
                    self.collectVideoPlayback.isHidden = false
                    
                    if self.arryCollect.count <= 0 {
                        
                        self.lblNoRelatedProduct.isHidden = false
                        self.collectVideoPlayback.isHidden = true
                        
                    } else {
                        
                        self.forloopIndex = 0
                        self.callanalytics()
                    }
                    self.collectVideoPlayback.reloadData()
                    
                } else {
                    
                    self.collectVideoPlayback.isHidden = true
                    self.lblNoRelatedProduct.isHidden = false
                    appDelegateShared.showToastMessage(message: strerror as NSString)
                    
                }
            }
        }
    }
}
