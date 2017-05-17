//
//  CoffeRoastVC.swift
//  TVPage Player
//
//  Created by    on 12/04/17.
//
//

import UIKit
import TVP

//MARK: - UITable Cell
class cellCofee: MTTableCell {
    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var imgVideo: UIImageView!
    @IBOutlet var lblVideoDetail: MTLabel!
}

class CoffeRoastVC: MTViewController, UITableViewDelegate, UITableViewDataSource, DropDownViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var lblCoffeeRoast: MTLabel!
    @IBOutlet var lblVideoCount: MTLabel!
    @IBOutlet var lblSubscribeToChannel: MTLabel!
    @IBOutlet var viewProductCategory: UIView!
    @IBOutlet var lblProductCategory: MTLabel!
    @IBOutlet var viewTypeOfVideo: UIView!
    @IBOutlet var lblTypeOfVideo: MTLabel!
    @IBOutlet var tblCoffee: UITableView!
    @IBOutlet var viewTableFooter: UIView!
    
    @IBOutlet var viewReset: UIView!
    @IBOutlet var btnTypeOFVideo: UIControl!
    @IBOutlet var btnProductCategory: UIControl!
    @IBOutlet var constraintWidthBackButton: NSLayoutConstraint!
    var isChannelVideoListAPICalling = false
    
    //Variables
    var DictChannelData = NSDictionary()
    var arrData = NSMutableArray()
    var arrTempData = NSMutableArray()
    var arrFilters = NSMutableArray()
    var isFiltershow: Bool = false
    var varConstTableHight = NSLayoutConstraint()
    var dropDownView = DropDownView()
    var dataVideoLoadingPageNo = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tblCoffee.tableHeaderView = self.viewTableHeader
        self.viewProductCategory.layer.cornerRadius = 5.0
        self.viewTypeOfVideo.layer.cornerRadius = 5.0
        
        arrData = NSMutableArray.init()
        arrTempData = NSMutableArray.init()
        self.lblVideoCount.text = ""
        lblCoffeeRoast.text = DictChannelData.value(forKey:"title")! as? String
        arrFilters = ["Coffee",
                      "Beans",
                      "Vieos"]
        
        self.getChannelVideoList()
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        self.tblCoffee.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        self.tblCoffee.reloadData()
    }
    
    @IBAction func tappedOnBack(_ sender: Any) {
        
        SNavigataionVC.popViewController(animated: true)
    }
    @IBAction func btnMenuTap(_ sender: Any) {
        
        SMainRootVC.showLeftView(animated: true, completionHandler: nil)
    }
    @IBAction func btnLogoTap(_ sender: Any) {
        
    }
    @IBAction func btnSubcribeToChannelTap(_ sender: Any) {
        
    }
    @IBAction func btnResetTap(_ sender: Any) {
        
    }
    @IBAction func btnProductCategoryTap(_ sender: Any) {
        
        /*if isFiltershow {
            
            isFiltershow = false
            dropDownView.closeAnimation()
            
        } else {
            
            isFiltershow = true
            dropDownView = DropDownView.init(arrayData: arrFilters as [AnyObject] , cellHeight: 35, heightTableView: 140, paddingTop: self.viewReset.frame.origin.y + btnProductCategory.frame.minY + btnProductCategory.frame.size.height + 1, paddingLeft: btnTypeOFVideo.frame.minX, paddingRight: self.btnTypeOFVideo.frame.size.width, refView: view, animation: BOTH, openAnimationDuration: 0.1, closeAnimationDuration: 0.1)
            
            dropDownView.delegate = self
            self.tblCoffee.addSubview(dropDownView.view)
            dropDownView.openAnimation()
            
        }*/
    }
    @IBAction func btnTypeOFVideoTap(_ sender: Any) {
        
        /*if isFiltershow {
            
            isFiltershow = false
            dropDownView.closeAnimation()
            
        } else {
            
            isFiltershow = true
            dropDownView = DropDownView.init(arrayData: arrFilters as [AnyObject] , cellHeight: 35, heightTableView: 140, paddingTop: self.viewReset.frame.origin.y + btnTypeOFVideo.frame.minY + btnTypeOFVideo.frame.size.height + 1, paddingLeft: btnTypeOFVideo.frame.minX, paddingRight: self.btnTypeOFVideo.frame.size.width, refView: view, animation: BOTH, openAnimationDuration: 0.1, closeAnimationDuration: 0.1)
            
            dropDownView.delegate = self
            self.tblCoffee.addSubview(dropDownView.view)
            dropDownView.openAnimation()
        }*/
    }
    @IBAction func btnLoadMoreTap(_ sender: Any){
        
        self.getChannelVideoList()
    }
// MARK: - ScrollView View Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        dropDownView.closeAnimation()
    }
//MARK: - DropDown Delegate Method
    public func dropDownCellSelected(_ returnIndex: Int) {
        
        dropDownView.closeAnimation()
    }
// MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlaybackVC") as! videoPlaybackVC
        initVC.dictVideoData = arrData[indexPath.row] as! NSDictionary
        initVC.btnBackWidthConst = (Int(Scale.x * 44.0))
        SNavigataionVC.pushViewController(initVC, animated:true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tblCoffee {
            
            return arrData.count
            
        } else {
            
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCofee", for: indexPath) as! cellCofee
        
        if arrData.count > indexPath.row {
            
            let dic = arrData[indexPath.row] as! NSDictionary
            cell.lblVideoDetail.text = dic.object(forKey: "title") as? String
            let dict_asset = dic.value(forKey:"asset") as! NSDictionary
            let url_string = dict_asset.value(forKey:"thumbnailUrl") as! String
            let url =  URL(string:url_string)!
            cell.imgVideo.sd_setImage(with: url, placeholderImage:appDelegateShared.getIconimage(iconname: "placeholder"))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    //MARK: - Get Channel Video List
    func getChannelVideoList() {
        
        if isChannelVideoListAPICalling == false {
            
            isChannelVideoListAPICalling = true
            
            if self.arrData.count == 0 {
            
                appDelegateShared.showHud()
            }
            
            print("dataVideoLoadingPageNo : \(dataVideoLoadingPageNo)")
            
            TvpApiClass.ChannelVideoList(strLoginID: appDelegateShared.loginID, strChhanelID: (DictChannelData.value(forKey:"id")! as? String)!, searchString: "", pageNumber: dataVideoLoadingPageNo, numberOfVideo: 5) { (arrChannelVideolist:NSArray,strerror:String) in
                
                self.isChannelVideoListAPICalling = false
                print(strerror)
                appDelegateShared.dismissHud()
                
                if strerror == "" {
                    
                    for videoData in arrChannelVideolist {
                        
                        self.arrData.add(videoData)
                    }
                    
                    if self.dataVideoLoadingPageNo == 0 && self.arrData.count != 0 {
                    
                        self.tblCoffee.tableFooterView = self.viewTableFooter
                    }
                    
                    if arrChannelVideolist.count != 0 {
                    
                        self.dataVideoLoadingPageNo += 1
                        self.lblVideoCount.text = "\(self.arrTempData.count)"
                        self.tblCoffee.reloadData()
                    }
                } else {
                    
                    appDelegateShared.showToastMessage(message: strerror as NSString)
                }
            }
        }
    }
}
