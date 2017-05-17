//
//  PDPVC.swift
//  TVPage Player
//
//  Created by   on 21/03/17.
//
//

import Foundation
import UIKit
import TVP

class cellPDP: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: MTLabel!
}
class PDPVC: MTViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TPFloatRatingViewDelegate {
    
    @IBOutlet var ctrlsideMenu: UIControl!
    @IBOutlet var imgsideMenu: UIImageView!
    
    @IBOutlet var collectPDP: UICollectionView!
    @IBOutlet var ratingView: TPFloatRatingView!
    var dictProductData = NSDictionary()
    var arryCollect = NSMutableArray()
    
    @IBOutlet var lblProductTitle: MTLabel!
    @IBOutlet var lblProductRate: MTLabel!
    
    @IBOutlet var imgProduct: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.ratingView.delegate = self;
        self.ratingView.emptySelectedImage = UIImage.init(named: "StarEmpty")
        self.ratingView.fullSelectedImage = UIImage.init(named: "StarFull")
        self.ratingView.contentMode = .scaleAspectFill
        self.ratingView.maxRating = 5;
        self.ratingView.minRating = 0;
        self.ratingView.rating = 2.6;
        self.ratingView.editable = false;
        self.ratingView.halfRatings = true;
        self.ratingView.floatRatings = true;
        
        lblProductTitle.text = dictProductData.value(forKey:"title") as? String
        lblProductRate.text = dictProductData.value(forKey:"price") as? String
       
        let url_string = dictProductData.value(forKey:"imageUrl") as! String
        let url =  URL(string:url_string)!
        imgProduct.sd_setImage(with: url, placeholderImage: appDelegateShared.getIconimage(iconname: "placeholder"))
            serviceCall ()
    }
    func serviceCall() {
        
        appDelegateShared.showHud()
        TvpApiClass.Get_listOfVideo_SpecificProduct(LoginID:appDelegateShared.loginID, productsId: dictProductData.value(forKey:"id") as! String) { (arrvideolist:NSArray,strerror:String) in
            appDelegateShared.dismissHud()
            
            if strerror == ""{
            
                self.arryCollect = NSMutableArray(array: arrvideolist)
                self.collectPDP.reloadData()
                
            } else {
                
                appDelegateShared.showToastMessage(message: strerror as NSString)
                
            }
        }
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
//MARK: - CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return arryCollect.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPDP", for: indexPath) as! cellPDP
        let dictionorydata = arryCollect[indexPath.row] as! NSDictionary
        let dict_asset = dictionorydata.value(forKey:"asset") as! NSDictionary
        let url_string = dict_asset.value(forKey:"thumbnailUrl") as! String
        let url =  URL(string:url_string)!
        cell.imgName.sd_setImage(with: url, placeholderImage: appDelegateShared.getIconimage(iconname: "placeholder"))
        cell.lblName.text = dictionorydata.value(forKey:"title") as? String
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.collectPDP.frame.size.width, height: self.collectPDP.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlaybackVC") as! videoPlaybackVC
        initVC.dictVideoData = arryCollect[indexPath.row] as! NSDictionary
        initVC.btnBackWidthConst = (Int(Scale.x * 44.0))
        SNavigataionVC.pushViewController(initVC, animated:true)
    }
//MARK: - Action Event
    @IBAction func btnBackClick(_ sender: Any) {
        
        SNavigataionVC.popViewController(animated: true)
    }
    @IBAction func sideMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
    }
    @IBAction func addToBagTap(_ sender: Any) {
        
    }
    @IBAction func productInfoTap(_ sender: Any) {
        
    }
    @IBAction func reviewTap(_ sender: Any) {
       
    }
    @IBAction func shippingTap(_ sender: Any) {
        
    }
    @IBAction func productQATap(_ sender: Any) {
        
    }
    @IBAction func playVideoTap(_ sender: Any) {
        
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlaybackVC") as! videoPlaybackVC
        SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
        SNavigataionVC.pushViewController(initVC, animated: true)
    }
}
