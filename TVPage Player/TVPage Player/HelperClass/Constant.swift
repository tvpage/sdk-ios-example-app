//
//  Constant.swift
//
//  Created by Sazzad Iproliya.
//  Copyright © 2016  . All rights reserved.
//


import Foundation
import UIKit

var IS_IPAD = UI_USER_INTERFACE_IDIOM() == .pad
var IS_IPHONE = UI_USER_INTERFACE_IDIOM() == .phone
var IS_RETINA = UIScreen.main.scale >= 2.0

var SCREEN_WIDTH = UIScreen.main.bounds.size.width
var SCREEN_HEIGHT = UIScreen.main.bounds.size.height
var SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
var SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)

var IS_IPHONE_4 = IS_IPHONE && SCREEN_MAX_LENGTH <= 480.0
var IS_IPHONE_5 = IS_IPHONE && SCREEN_MAX_LENGTH == 568.0
var IS_IPHONE_6 = IS_IPHONE && SCREEN_MAX_LENGTH == 667.0
var IS_IPHONE_6P = IS_IPHONE && SCREEN_MAX_LENGTH == 736.0

var BaseURL = ""

var DEVICE_TYPES = "iphone"

var ImageURL = ""

var SMainRootVC = (UIApplication.shared.delegate!.window!?.rootViewController! as! LGSideMainVC)
var SNavigataionVC = ((UIApplication.shared.delegate!.window!?.rootViewController! as! LGSideMainVC).rootViewController! as! NavigationVC)

//var appDelegateShared = UIApplication.shared.delegate as! AppDelegate

class Constants: NSObject {
    
}
func interactivePopGestureRecognizer(nav : UINavigationController) {
 //nav.interactivePopGestureRecognizer?.isEnabled = false
}
func getUserDF(_ key:String) -> AnyObject? {
    return UserDefaults.standard.object(forKey: key) as AnyObject?
}

func setUserDF(_ value: AnyObject, forKey key:String) {
    UserDefaults.standard.set(value, forKey: key)
}

func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
    if let data = text.data(using: String.Encoding.utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}
