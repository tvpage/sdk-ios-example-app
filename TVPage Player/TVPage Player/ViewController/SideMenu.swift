//
//  sideMenu.swift
//
//  Created by   on 08/12/16.
//  Copyright © 2016  . All rights reserved.
//

import Foundation
import UIKit

class cellMenu: MTTableCell {
    
    @IBOutlet var imgLogoName: UIImageView!
    @IBOutlet var viewSeparate: UIView!
    @IBOutlet var lblLogoName: MTLabel!
    @IBOutlet var lblMinXConst: NSLayoutConstraint!
}

class SideMenu: MTViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tblSideMenu: UITableView!
    @IBOutlet var ctrlCancel: UIControl!
    @IBOutlet var ctrlLogo: UIControl!
    @IBOutlet var imgCancel: UIImageView!
    @IBOutlet var imgLogo: UIImageView!

    var arryTitleName = [String]()
    
// MARK: - ViewDidLoad Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        arryTitleName = ["HOME","COFFEE","EQUIPMENT","DRINKWARE","OUR BLOG","VIDEO GALLERY"]
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
//MARK: - Tableview Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arryTitleName.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath) as! cellMenu
            
        cell.lblLogoName.text = self.arryTitleName[indexPath.row]
        cell.imgLogoName.image = UIImage.init(named: "")
        cell.lblMinXConst.constant = 10
        
        if (indexPath.row == 5) {
            
            cell.lblMinXConst.constant = 44
            cell.imgLogoName.image = UIImage.init(named: "ondemand_video")
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
            SNavigataionVC.pushViewController(initVC, animated: false)
        }
//        if indexPath.row == 1 {
        
//            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
//            SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
//            SNavigataionVC.pushViewController(initVC, animated: false)
//        }
//        if indexPath.row == 4 {
        
//            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "PDPVC") as! PDPVC
//            SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
//            SNavigataionVC.pushViewController(initVC, animated: false)
//        }
        else if indexPath.row == 5 {
            
            let initVC = self.storyboard?.instantiateViewController(withIdentifier: "VideoGalleryVC") as! VideoGalleryVC
            SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
            SNavigataionVC.pushViewController(initVC, animated: false)
        }
    }
// MARK: - Action Event
    @IBAction func cancelTap(_ sender: Any) {
        
        SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
    }
    
    @IBAction func logoTap(_ sender: Any) {
        
        SMainRootVC.hideLeftView(animated: true, completionHandler: nil)
    }
}
