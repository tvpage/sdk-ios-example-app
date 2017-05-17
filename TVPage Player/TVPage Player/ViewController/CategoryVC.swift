//
//  CategoryVC.swift
//  TVPage Player
//
//  Created by   on 15/03/17.
//
//

import Foundation
import UIKit

class cellCategory501: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: MTLabel!
    @IBOutlet var ratingView: TPFloatRatingView!
    @IBOutlet var lblRate: MTLabel!
}

class cellCategory502: MTCollectionCell {
    
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: MTLabel!
}

class CategoryVC: MTViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TPFloatRatingViewDelegate  {
    
    @IBOutlet var ctrlsideMenu: UIControl!
    @IBOutlet var imgsideMenu: UIImageView!
    
    @IBOutlet var collectCategory501: UICollectionView!
    @IBOutlet var collectCategory502: UICollectionView!
    
    @IBOutlet var ProductListConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if appDelegateShared.arrProductList.count % 2 == 0 {
            
            ProductListConstraint.constant = CGFloat(appDelegateShared.arrProductList.count/2 * 282)
            
        } else {
            
            ProductListConstraint.constant = CGFloat((appDelegateShared.arrProductList.count+1)/2 * 282)

        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        
        SNavigataionVC.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
//MARK: - CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 501 {
            
            return appDelegateShared.arrProductList.count
            
        } else if collectionView.tag == 502 {
            
            return appDelegateShared.arrVideoList.count
            
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 501 {
            
            return CGSize(width: self.collectCategory501.frame.size.width/2, height:282)
            
        } else if collectionView.tag == 502 {
            
            return CGSize(width: (self.collectCategory502.frame.size.width - (8 * (Scale.x)))/2, height: (self.collectCategory502.frame.size.height - (16 * (Scale.y)))/3)
        }
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 501 {
            
            let cell501 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCategory501", for: indexPath) as! cellCategory501
            let dictionorydata = appDelegateShared.arrProductList[indexPath.row] as! NSDictionary
            let url_string = dictionorydata.value(forKey:"imageUrl") as! String
            let url =  URL(string:url_string)!
            
            cell501.imgName.sd_setImage(with: url, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
            cell501.lblName.text = dictionorydata.value(forKey:"title") as? String
            cell501.lblRate.text = dictionorydata.value(forKey:"price") as? String
            cell501.ratingView.delegate = self;
            cell501.ratingView.emptySelectedImage = UIImage.init(named: "StarEmpty")
            cell501.ratingView.fullSelectedImage = UIImage.init(named: "StarFull")
            cell501.ratingView.contentMode = .scaleAspectFill
            cell501.ratingView.maxRating = 5;
            cell501.ratingView.minRating = 0;
            cell501.ratingView.rating = 3.2;
            cell501.ratingView.editable = false;
            cell501.ratingView.halfRatings = true;
            cell501.ratingView.floatRatings = true;
            return cell501
            
        } else if collectionView.tag == 502 {
            
            let cell502 = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCategory502", for: indexPath) as! cellCategory502

            let dictionorydata = appDelegateShared.arrVideoList[indexPath.row] as! NSDictionary
            let dict_asset = dictionorydata.value(forKey:"asset") as! NSDictionary
            let url_string = dict_asset.value(forKey:"thumbnailUrl") as! String
            let url =  URL(string:url_string)!
            
            cell502.imgName.sd_setImage(with: url, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
            cell502.lblName.text = dictionorydata.value(forKey:"title") as? String
            
            return cell502
            
        } else {
            
            let cell = MTCollectionCell()
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 501 {
            
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "PDPVC") as! PDPVC
            SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
            initVC.dictProductData = appDelegateShared.arrProductList[indexPath.row] as! NSDictionary
            SNavigataionVC.pushViewController(initVC, animated: true)
            
        } else if collectionView.tag == 502 {
            
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlaybackVC") as! videoPlaybackVC
            initVC.dictVideoData = appDelegateShared.arrVideoList[indexPath.row] as! NSDictionary
            initVC.btnBackWidthConst = (Int(Scale.x * 44.0))
            SNavigataionVC.pushViewController(initVC, animated:true)
        }
    }
//MARK: - Action Event
    @IBAction func sideMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
    }
    @IBAction func viewMoreVideoTap(_ sender: Any) {
        
    }
}
