//
//  ProductDetailVC.swift
//  TVPage Player
//
//  Created by   on 25/04/17.
//
//

import UIKit

class ProductDetailVC: MTViewController {
    
    @IBOutlet var WebViewobj: UIWebView!
    @IBOutlet var btnBack: UIControl!
    var detailUrl:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebViewobj.loadRequest(URLRequest(url: URL(string: detailUrl)!))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btnBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnSlideMenuClick(_ sender: Any) {
    
    }
}
