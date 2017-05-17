//
//  AppDelegate.swift
//  TVPage Player
//
//  Created by   on 09/03/17.
//
//

import UIKit
import Fabric
import Crashlytics
import SystemConfiguration
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?
    var HUD: MBProgressHUD!
    var SVHUD: SVProgressHUD!
    var reachability:Reachability!
    var videoPageNumber = 0
    
    //var loginID = "1758929"
    //var ChannelID = "87486517"
    
    //Global Login id and Channel id
    var loginID = "1758799"
    var ChannelID = "66133905"
    
    var arrVideoList = NSMutableArray()
    var arrProductList = NSMutableArray()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        
        Fabric.with([Crashlytics.self])
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navController = storyBoard.instantiateViewController(withIdentifier: "NavigationVC") as! NavigationVC
        let mainVC = storyBoard.instantiateInitialViewController() as! LGSideMainVC
       
        mainVC.rootViewController = navController
        mainVC.setupWithPresentationStyle(style: .slideBelow, type: 0)
        appDelegateShared.window?.rootViewController! = mainVC
        
        //Check internet connection 
        if isInternetAvailable() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
        }
        
        let reachability = Reachability(hostname: "google.com")
        self.reachability = reachability
        
        startNotifier()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.    
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //MARK:- show Toast Message
    func getIconimage(iconname:String) -> UIImage {
        let  bundle = Bundle(url: Bundle.main.url(forResource: "TVPBundle", withExtension: "bundle")!)
        let  imagePath: String? = bundle?.path(forResource: iconname, ofType: "png")
        let  image = UIImage(contentsOfFile: imagePath!)
        return image!
        //return UIImage(named:iconname)!
    }
    func showToastMessage(message:NSString) -> Void{
        HUD = MBProgressHUD.showAdded(to: self.window, animated: true)
        HUD?.mode = MBProgressHUDModeText
        HUD?.labelText = message as String!
        HUD?.yOffset = 200.0
        HUD?.dimBackground = true
        HUD?.sizeToFit()
        HUD?.color = UIColor.init(colorLiteralRed:44.0/255.0, green:99.0/255.0, blue:115.0/255.0, alpha:1.0)
        HUD?.margin = 10.0
        HUD?.removeFromSuperViewOnHide = true
        HUD?.hide(true, afterDelay: 2.0)
    }
    
    //MARK:- Hudder Method
    
    func showHud(){
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.init(colorLiteralRed:44.0/255.0, green:99.0/255.0, blue:115.0/255.0, alpha:1.0))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
    }
    
    func showWithStatus(){
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.init(colorLiteralRed:44.0/255.0, green:99.0/255.0, blue:115.0/255.0, alpha:1.0))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.show(withStatus:"Please Wait...")
    }
    
    func showSuccessWithStatus(){
        SVProgressHUD.showSuccess(withStatus:"Completed.")
        self.perform(#selector(dismissHud), with: nil, afterDelay: 0.5)
    }
    
    func showErrorWithStatus(){
        SVProgressHUD.showError(withStatus: "Failed with Error")
        self.perform(#selector(dismissHud), with: nil, afterDelay: 0.5)
    }
    
    func dismissHud(){
        SVProgressHUD.dismiss()
    }
    
//MARK:- Remove WhiteSpace and New Line Space
    func TrimString(string:NSString) -> NSString{
        var trimmedString:NSString?
        trimmedString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString?
        return trimmedString!
    }
//MARK:- Network connection notification
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    func reachabilityChanged() {
        
        if isInternetAvailable() == true {
            
            print("Internet connection OK")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isInternetConnectionAvailable"), object: [ "networkStatus": "YES"]);
        } else {
            print("Internet connection FAILED")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isInternetConnectionAvailable"), object: [ "networkStatus": "NO"]);
        }
        
    }
}

