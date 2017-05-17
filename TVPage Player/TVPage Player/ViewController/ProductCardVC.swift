//
//  ProductCardVC.swift
//  TVPage Player
//
//  Created by   on 27/03/17.
//
//

import Foundation
import UIKit

class cellProductCard: MTCollectionCell {
    
    @IBOutlet var image_product_card: UIImageView!
}

class ProductCardVC: MTViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TPFloatRatingViewDelegate  {
    
    @IBOutlet var ctrlsideMenu: UIControl!
    @IBOutlet var imgsideMenu: UIImageView!
    var arr_collection_view  = NSMutableArray()
    var ViewDetailUrl : String!
    var selectedIndex = 0
    @IBOutlet var lbl_productTitle: UILabel!
    @IBOutlet var lbl_productPrice: UILabel!
     @IBOutlet var RattingView: TPFloatRatingView!
    @IBOutlet var Collecton_view_prdt: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.RattingView.delegate = self;
        self.RattingView.emptySelectedImage = UIImage.init(named: "StarEmpty")
        self.RattingView.fullSelectedImage = UIImage.init(named: "StarFull")
        self.RattingView.contentMode = .scaleAspectFill
        self.RattingView.maxRating = 5;
        self.RattingView.minRating = 0;
        self.RattingView.rating = 2.6;
        self.RattingView.editable = false;
        self.RattingView.halfRatings = true;
        self.RattingView.floatRatings = true;

    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //auto scroll to selected index
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        Collecton_view_prdt.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
        let dictionorydata = (self.arr_collection_view.object(at: 0) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary
        
        lbl_productTitle.text = dictionorydata.value(forKey:"title") as? String
        lbl_productPrice.text = dictionorydata.value(forKey:"price") as? String
        ViewDetailUrl = dictionorydata.value(forKey:"linkUrl") as? String
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()
        
        visibleRect.origin = Collecton_view_prdt.contentOffset
        visibleRect.size = Collecton_view_prdt.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        let visibleIndexPath: IndexPath = Collecton_view_prdt.indexPathForItem(at: visiblePoint)!
        
        let dictionorydata = (self.arr_collection_view.object(at: 0) as! NSMutableArray).object(at: visibleIndexPath.row) as! NSDictionary
        
        lbl_productTitle.text = dictionorydata.value(forKey:"title") as? String
        lbl_productPrice.text = dictionorydata.value(forKey:"price") as? String
        ViewDetailUrl = dictionorydata.value(forKey:"linkUrl") as? String
    }
//MARK: - Action Event
    @IBAction func btnBackClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnViewDetailTap(_ sender: Any) {
        
        if (ViewDetailUrl != nil) {
            
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            initVC.detailUrl = ViewDetailUrl
            self.present(initVC, animated: true, completion: nil)

        } else {
            
            let alert = UIAlertController(title: "", message: "Detail not found.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func sideMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.Collecton_view_prdt.frame.size.width, height: self.Collecton_view_prdt.frame.size.height)
    }
//MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       let count = (arr_collection_view.object(at: 0) as! NSMutableArray).count
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cellProductCard = collectionView.dequeueReusableCell(withReuseIdentifier: "cellProductCard", for: indexPath) as! cellProductCard
        let dictionorydata = (self.arr_collection_view.object(at: 0) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary
        let url_string = dictionorydata.value(forKey:"imageUrl") as! String
        let url =  URL(string:url_string)!
        
        cellProductCard.image_product_card.sd_setImage(with: url, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
        return cellProductCard
    }
}
