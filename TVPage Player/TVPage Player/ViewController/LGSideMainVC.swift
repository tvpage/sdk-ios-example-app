//
//  LGSideMainVC.swift
//  BigCondoNew
//
//  Created by   on 08/12/16.
//  Copyright © 2016  . All rights reserved.
//

import Foundation

class LGSideMainVC: LGSideMenuController {
    var type:NSInteger?
    var sideMenu:SideMenu?
    
    func setupWithPresentationStyle(style : LGSideMenuPresentationStyle, type : NSInteger) -> Void {
        
        sideMenu = self.storyboard?.instantiateViewController(withIdentifier: "SideMenu") as! SideMenu?
        
        if type == 0 {
            
            self.setLeftViewEnabledWithWidth(SCREEN_WIDTH, presentationStyle: .slideBelow, alwaysVisibleOptions: .init(rawValue: 0))
            self.leftViewStatusBarStyle = .default
            self.leftViewStatusBarVisibleOptions = .init(rawValue: 0)
        }
        self.leftView().addSubview((sideMenu?.view)!)
    }
    override func leftViewWillLayoutSubviews(with size: CGSize) {
        
        super.leftViewWillLayoutSubviews(with: size)
        sideMenu?.view.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(size.width), height: CGFloat(size.height))
    }
}
