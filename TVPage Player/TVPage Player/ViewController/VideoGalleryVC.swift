//
//  VideoGalleryVC.swift
//  TVPage Player
//
//  Created by   on 10/04/17.
//
//

import UIKit
import TVP

class cellCollectVideo504: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblTitle: MTLabel!
}
class cellCollectBrand: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
}

class cellTblChennelHome: MTTableCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: MTLabel!
}

class VideoGalleryVC: MTViewController ,  UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var ctrlsideMenu: UIControl!
    @IBOutlet var imgsideMenu: UIImageView!
    @IBOutlet var VideoHeightConst: NSLayoutConstraint!
    @IBOutlet var collectvideolist: UICollectionView!
    @IBOutlet var collectBrandlist: UICollectionView!
    @IBOutlet var tblHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tblHome: UITableView!
    
    var arryTbl = NSMutableArray()
    var arryBrand = NSMutableArray()
    var arryVideoList = NSMutableArray()
    var isChannelVideoListAPICalling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arryBrand = ["brandLogo_NinjaCoffeeBar",
                     "brandLogo_Keurig",
                     "brandLogo_Cuisinart"]
        
        arryVideoList = appDelegateShared.arrVideoList.mutableCopy() as! NSMutableArray
        
        VideoHeightConst.constant = CGFloat((arryVideoList.count * 250))
        collectvideolist.reloadData()
        
        serviceCall()
        
    }
    func serviceCall() {
        
        appDelegateShared.showHud()
        TvpApiClass.ChannelList(loginID: appDelegateShared.loginID, pageNumber: "", Max: "", orderBy: "", Order_direction: "", searchString: "") { (arrChannellist:NSArray,strerror:String) in
            print(strerror)
            appDelegateShared.dismissHud()
            
            if strerror == "" {
                
                self.arryTbl = NSMutableArray(array: arrChannellist)
                self.tblHeightConstraint.constant = CGFloat(150*self.arryTbl.count)
                self.view.layoutIfNeeded()
                self.tblHome.reloadData()
                
            } else {
                
                appDelegateShared.showToastMessage(message: strerror as NSString)
                
            }
        }
    }
//MARK: - Action Event
    @IBAction func sideMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
    }
    @IBAction func btnLoadMoreClicked(_ sender: Any) {
        
        self.getChannelVideoList()
        
    }
//MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arryTbl.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTblChennelHome", for: indexPath) as! cellTblChennelHome
        let dictionorydata = self.arryTbl[indexPath.row] as! NSDictionary
        let dict_asset = dictionorydata.value(forKey:"settings") as! NSDictionary
        
        if (dict_asset.value(forKey:"canvasUrl") != nil) {
            
            let url_string = dict_asset.value(forKey:"canvasUrl") as! String
            let urlWithHttps = "https:\(url_string)"
            let url =  URL(string:urlWithHttps)!
            cell.imgName.sd_setImage(with: url, placeholderImage: appDelegateShared.getIconimage(iconname: "placeholder"))
            
        } else {
            
            let url =  URL(string:"")
            cell.imgName.sd_setImage(with: url, placeholderImage: appDelegateShared.getIconimage(iconname: "placeholder"))
        }
        cell.lblName.text = dictionorydata.value(forKey:"title")! as? String
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CoffeRoastVC") as! CoffeRoastVC
        vc.DictChannelData = self.arryTbl[indexPath.row] as! NSDictionary
        SNavigataionVC.pushViewController(vc, animated: true)
    }
//MARK: - CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 504 {
            
            return arryVideoList.count
            
        } else if collectionView.tag == 503 {
            
            return arryBrand.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 504 {
            
            return CGSize(width: self.collectvideolist.frame.size.width, height: 250)
            
        } else if collectionView.tag == 503 {
            
            return CGSize(width: 125, height: collectBrandlist.frame.size.height)
            
        }
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 504 {
            
            let cell503 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectVideo504", for: indexPath) as! cellCollectVideo504
            let dictionorydata = arryVideoList[indexPath.row] as! NSDictionary
            let dict_asset = dictionorydata.value(forKey:"asset") as! NSDictionary
            let url_string = dict_asset.value(forKey:"thumbnailUrl") as! String
            let url =  URL(string:url_string)!
            cell503.imgName.sd_setImage(with: url, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
            cell503.lblTitle.text = dictionorydata.value(forKey:"title") as? String
            return cell503
            
        } else if collectionView.tag == 503 {
            
            let cell503 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectBrand", for: indexPath) as! cellCollectBrand
            cell503.imgName.image = UIImage.init(named: self.arryBrand.object(at: indexPath.row) as! String)
            return cell503
            
        }
        let cell = MTCollectionCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 504 {
            
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlaybackVC") as! videoPlaybackVC
            initVC.dictVideoData = arryVideoList[indexPath.row] as! NSDictionary
            initVC.btnBackWidthConst = (Int(Scale.x * 44.0))
            SNavigataionVC.pushViewController(initVC, animated:true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
//MARK: - Get Channel Video List
    func getChannelVideoList() {
        
        if isChannelVideoListAPICalling == false {
            
            isChannelVideoListAPICalling = true
            
            if appDelegateShared.arrVideoList.count == 0 {
            
                appDelegateShared.showHud()
            }
            
            TvpApiClass.ChannelVideoList(strLoginID: appDelegateShared.loginID, strChhanelID:appDelegateShared.ChannelID, searchString: "", pageNumber: appDelegateShared.videoPageNumber,numberOfVideo: 5) { (arrChannelVideolist:NSArray,strerror:String) in
                
                print(strerror)
                self.isChannelVideoListAPICalling = false
                appDelegateShared.dismissHud()
                
                if strerror == "" {
                    
                    for videoData in arrChannelVideolist {
                        
                        appDelegateShared.arrVideoList.add(videoData)
                    }
                    
                    if arrChannelVideolist.count > 0 {
                        
                        appDelegateShared.videoPageNumber = appDelegateShared.videoPageNumber + 1
                    }
                    
                    self.arryVideoList = appDelegateShared.arrVideoList.mutableCopy() as! NSMutableArray
                    
                    self.VideoHeightConst.constant = CGFloat((self.arryVideoList.count * 250))
                    self.collectvideolist.reloadData()
                    
                } else {
                    
                    appDelegateShared.showToastMessage(message: strerror as NSString)
                }
            }
        }
    }
}
