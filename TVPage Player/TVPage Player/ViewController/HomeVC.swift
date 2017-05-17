//
//  HomeVC.swift
//  TVPage Player
//

import UIKit
import TVP


class cellCollectHome501: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
}

class cellCollectHome502: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: MTLabel!
}

class cellCollectHome503: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblTitle: MTLabel!
    @IBOutlet var txtViewSubTitle: MTTextView!
    @IBOutlet var ctrlDown: UIControl!
    @IBOutlet var constSubTitleHeight:NSLayoutConstraint!
}

class cellCollectHome504: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
}

class cellTblHome: MTTableCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: MTLabel!
}

class HomeVC: MTViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var ctrlsideMenu: UIControl!
    @IBOutlet var imgsideMenu: UIImageView!
    
    @IBOutlet var collectHome501: UICollectionView!
    @IBOutlet var collectHome502: UICollectionView!
    @IBOutlet var collectHome503: UICollectionView!
    @IBOutlet var collectHome504: UICollectionView!
    
    @IBOutlet var tblHome: UITableView!
    
    var arryTbl = NSMutableArray()
    var arrycollect501 = NSMutableArray()
    var arrycollect503 = NSMutableArray()
    var arrycollect504 = NSMutableArray()
    var boolSubTitle:Bool!
    var heightValue:CGFloat!
    
    var isChannelVideoListAPICalling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrycollect501 = ["Home_Hero",
                          "BG_channel",
                          "Vid Thumb6"]
        arrycollect503 = [["Name":"p1",
                           "Title":"The Perfect efert The Perfect efert The Perfect efert The Perfect efert, EveryTime",
                           "Description":"Lorem Ipsum is simply dummy text of the printing and         typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."],
                          ["Name":"p2",
                           "Title":"The perception Value The perception Value The perception Value The perception Value",
                           "Description":"The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham."],
                          ["Name":"p3",
                           "Title":"Holes are Everything Holes are Everything Holes are Everything Holes are Everything",
                           "Description":"Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."],
                          ["Name":"p4",
                           "Title":"Hello The Perfect efert, EveryTime The perception Value Hello The Perfect efert, EveryTime The perception Value",
                           "Description":"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."]
        ]
        
        arrycollect504 = ["brandLogo_NinjaCoffeeBar",
                          "brandLogo_Keurig",
                          "brandLogo_Cuisinart"]
        
        arryTbl = ["coffee",
                   "equipment",
                   "drinkware"]
        
        self.getChannelVideoList()
        self.getProductsList()
        
        boolSubTitle = false
        heightValue = 140.0
        
    }
//MARK: - Get Channel Video List
    func getChannelVideoList() {
        
        if isChannelVideoListAPICalling == false {
           
            isChannelVideoListAPICalling = true
            
            if appDelegateShared.videoPageNumber == 0 {
                
                appDelegateShared.showHud()
            }
            
            TvpApiClass.ChannelVideoList(strLoginID: appDelegateShared.loginID, strChhanelID:appDelegateShared.ChannelID, searchString: "", pageNumber: appDelegateShared.videoPageNumber,numberOfVideo: 5) { (arrChannelVideolist:NSArray,strerror:String) in
                
                print(strerror)
                self.isChannelVideoListAPICalling = false
                appDelegateShared.dismissHud()
                
                if strerror == "" {
                    
                    //appDelegateShared.arrVideoList = NSMutableArray(array: arrChannelVideolist)
                    
                    for videoData in arrChannelVideolist {
                        
                        appDelegateShared.arrVideoList.add(videoData)
                    }
                    
                    if arrChannelVideolist.count > 0 {
                        
                        appDelegateShared.videoPageNumber = appDelegateShared.videoPageNumber + 1
                    }
                    self.collectHome502.reloadData()
                    
                } else {
                    
                    appDelegateShared.showToastMessage(message: strerror as NSString)
                }
            }
        }
    }
//MARK: - Get Product List
    func getProductsList() {
        
        TvpApiClass.ProductsList(loginID:appDelegateShared.loginID, pageNumber: "", Max: "", orderBy: "", Order_direction: "", searchString: "") { (arrProductslist:NSArray,strerror:String) in
             if strerror == ""{
                
            appDelegateShared.arrProductList = NSMutableArray(array: arrProductslist)
                
            } else {
                
                appDelegateShared.showToastMessage(message: strerror as NSString)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
//MARK: - Action Event
    @IBAction func sideMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
    }
//MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arryTbl.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTblHome", for: indexPath) as! cellTblHome
        
        cell.imgName.image = UIImage.init(named: self.arryTbl.object(at: indexPath.row) as! String)
        
        if (indexPath.row == 0) {
            
           cell.lblName.text = "COFFEE"
        }
        else if (indexPath.row == 1) {
            
            cell.lblName.text = "EQUIPMENT"
        }
        else if (indexPath.row == 2) {
            
            cell.lblName.text = "DRINKWARE"
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
        SNavigataionVC.pushViewController(initVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return (self.tblHome.frame.size.height/3)
    }
//MARK: - CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 501 {
            
            return arrycollect501.count
        }
        else if collectionView.tag == 502 {
            
            return appDelegateShared.arrVideoList.count
        }
        else if collectionView.tag == 503 {
            
            return arrycollect503.count
        }
        else if collectionView.tag == 504 {
            
            return arrycollect504.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 501 {
            
            return CGSize(width: self.collectHome501.frame.size.width, height: self.collectHome501.frame.size.height)
        }
        else if collectionView.tag == 502 {
            
            return CGSize(width: self.collectHome502.frame.size.width, height: self.collectHome502.frame.size.height)
        }
        else if collectionView.tag == 503 {
            
            return CGSize(width: self.collectHome503.frame.size.width, height: self.collectHome503.frame.size.height)
        }
        else if collectionView.tag == 504 {
            
            return CGSize(width: 125, height: self.collectHome504.frame.size.height)
        }
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 501 {
            
            let cell501 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectHome501", for: indexPath) as! cellCollectHome501
            cell501.imgName.image = UIImage.init(named: self.arrycollect501.object(at: indexPath.row) as! String)
            return cell501
            
        } else if collectionView.tag == 502 {
            
            let cell502 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectHome502", for: indexPath) as! cellCollectHome502
            let dictionorydata = appDelegateShared.arrVideoList[indexPath.row] as! NSDictionary
            let dict_asset = dictionorydata.value(forKey:"asset") as! NSDictionary
            let url_string = dict_asset.value(forKey:"thumbnailUrl") as! String
            let url =  URL(string:url_string)!
            cell502.imgName.sd_setImage(with: url, placeholderImage: appDelegateShared.getIconimage(iconname: "placeholder"))
            cell502.lblName.text = dictionorydata.value(forKey:"title") as? String
            return cell502
            
        } else if collectionView.tag == 503 {
            
            let cell503 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectHome503", for: indexPath) as! cellCollectHome503
            
            cell503.imgName.image = UIImage.init(named: (self.arrycollect503.object(at: indexPath.row) as! NSDictionary).value(forKey: "Name") as! String)
            cell503.lblTitle.text = NSString.init(format: "%@",(self.arrycollect503.object(at: indexPath.row) as! NSDictionary).value(forKey: "Title") as! CVarArg) as String
            cell503.txtViewSubTitle.text = NSString.init(format: "%@",(self.arrycollect503.object(at: indexPath.row) as! NSDictionary).value(forKey: "Description") as! CVarArg) as String
            
            cell503.constSubTitleHeight.constant = heightValue
            
            cell503.ctrlDown.isHidden = false
            cell503.txtViewSubTitle.isScrollEnabled = false
            
            if heightValue == 160.0 {
                
                cell503.txtViewSubTitle.isScrollEnabled = true
                cell503.ctrlDown.isHidden = true
            }
            return cell503
            
        } else if collectionView.tag == 504 {
            
            let cell504 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectHome504", for: indexPath) as! cellCollectHome504
            
            cell504.imgName.image = UIImage.init(named: self.arrycollect504.object(at: indexPath.row) as! String)
            return cell504
        }
        
        let cell = MTCollectionCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       if collectionView.tag == 502 {
        
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlaybackVC") as! videoPlaybackVC
            initVC.dictVideoData = appDelegateShared.arrVideoList[indexPath.row] as! NSDictionary
            initVC.btnBackWidthConst = (Int(Scale.x * 44.0))
            SNavigataionVC.pushViewController(initVC, animated:true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 502 {
            
            print(indexPath.row)
            if indexPath.row == appDelegateShared.arrVideoList.count {
                
                print("willDisplayCell")
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width

        print("=============")
        print("offsetX : \(offsetX)")
        print("contentWidth : \(contentWidth)")
        print("scrollView.frame.size.width : \(scrollView.frame.size.width)")
        if offsetX == contentWidth - (scrollView.frame.size.width * 3){
        
            print("scrollViewDidScroll")
            self.getChannelVideoList()
            
        }
    }
    @IBAction func txtChangeHeight(_ sender: Any) {
        
        if !boolSubTitle {
            
            boolSubTitle = true
            heightValue = 160.0
            
        } else {
            
            boolSubTitle = false
            heightValue = 140.0
        }
        collectHome503.reloadData()
    }
    @IBAction func viewMoreVideoTap(_ sender: Any) {
        
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "VideoGalleryVC") as! VideoGalleryVC
        SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
        SNavigataionVC.pushViewController(initVC, animated: false)
    }
    @IBAction func readMoreBlogTap(_ sender: Any) {
        
    }
    @IBAction func shopAllBrandsTap(_ sender: Any) {
        
    }
}
