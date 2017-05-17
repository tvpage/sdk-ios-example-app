//
//  Helper.swift
//  CommonClass
//
//  Created by    on 5/2/16.
//  Copyright © 2016   . All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//MARK: - Device Type
enum UIUserInterfaceIdiom : Int {
    
    case Unspecified
    case Phone
    case Pad
}
struct DeviceType {
    
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6PLUS         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

//MARK: - AppDelagate Object
var appDelegateShared = UIApplication.shared.delegate as! AppDelegate

//MARK: - Screen Size
struct ScreenSize {
    
    static let WIDTH         = UIScreen.main.bounds.size.width
    static let HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.WIDTH, ScreenSize.HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.WIDTH, ScreenSize.HEIGHT)
}
//MARK: - Font Layout
struct FontName {
    
    //Font Name List
    static let HelveticaNeueBoldItalic = "HelveticaNeue-BoldItalic"
    static let HelveticaNeueLight = "HelveticaNeue-Light"
    static let HelveticaNeueUltraLightItalic = "HelveticaNeue-UltraLightItalic"
    static let HelveticaNeueCondensedBold = "HelveticaNeue-CondensedBold"
    static let HelveticaNeueMediumItalic = "HelveticaNeue-MediumItalic"
    static let HelveticaNeueThin = "HelveticaNeue-Thin"
    static let HelveticaNeueMedium = "HelveticaNeue-Medium"
    static let HelveticaNeueThinItalic = "HelveticaNeue-ThinItalic"
    static let HelveticaNeueLightItalic = "HelveticaNeue-LightItalic"
    static let HelveticaNeueUltraLight = "HelveticaNeue-UltraLight"
    static let HelveticaNeueBold = "HelveticaNeue-Bold"
    static let HelveticaNeue = "HelveticaNeue"
    static let HelveticaNeueCondensedBlack = "HelveticaNeue-CondensedBlack"
    static let SatteliteRegular = "Satellite"
    static let SatteliteOblique = "Satellite-Oblique"
    
    static let DosisRegular = "Dosis-Regular"
    static let DosisBold = "Dosis-Bold"
    static let DosisMedium = "Dosis-Medium"
    static let DosisSemiBold = "Dosis-SemiBold"
    static let DosisLight = "Dosis-ExtraLight"
    static let DosisExtraLight = "Dosis-ExtraLight"
    static let DosisExtraBold = "Dosis-ExtraBold"
}
func setFontLayout(strFontName:String,fontSize:CGFloat) -> UIFont {
    //Set auto font size in different devices.
    return UIFont(name: strFontName, size: (ScreenSize.WIDTH / 375) * fontSize)!
}
//MARK: - Set Color Method
func setColor(r: Float, g: Float, b: Float, aplha: Float)-> UIColor {
    
  return UIColor(red: CGFloat(Float(r / 255.0)), green: CGFloat(Float(g / 255.0)) , blue: CGFloat(Float(b / 255.0)), alpha: CGFloat(aplha))
}
//MARK: - Scaling
struct Scale {
    
    static let x = ScreenSize.WIDTH / 375.0
    static let y = ScreenSize.HEIGHT / 667.0
    static let xy = ((Scale.x + Scale.y) / 2.0)
}

//MARK: - Helper Class
class Helper {
//MARK: - Shared Instance
    static let sharedInstance : Helper = {
        
        let instance = Helper()
        return instance
    }()

    static let isDevelopmentBuild:Bool = true
//MARK: - Convert Second TO Hours,Minutes and Seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
//MARK: - Add zero before single digit
    func addZeroBeforeDigit(number: Int) -> String {
        
        return ((number > 9) ? (String.init(format: "%d", number)) : (String.init(format: "0%d", number)))
    }
}

extension UIColor {
    
    class var LoadmoreColor: UIColor {
        
        return UIColor(red: 31.0 / 255.0, green: 29.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
    }
    class var HeaderColor: UIColor {
        
        return UIColor(red: 44.0 / 255.0, green: 99.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
    }
}
//MARK: - UILabel Extension
extension UILabel {
    //Set line spacing between two lines.
    func setLineHeight(lineHeight: CGFloat) {
        
        let text = self.text
        if let text = text {
            
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
            self.attributedText = attributeString
        }
    }
    //Set notification counter with dynamic width calculate
    func setNotificationCounter(counter: String) {
        
        if counter.length == 0 {
            
            self.isHidden = true
            
        } else {
            
            self.isHidden = false
            let strCounter:String = ":\(counter)|"
            
            self.clipsToBounds = true
            self.layer.cornerRadius = self.frame.size.height / 2.0
            
            let string_to_color1 = ":"
            let range1 = (strCounter as NSString).range(of: string_to_color1)
            let attributedString1 = NSMutableAttributedString(string:strCounter)
            attributedString1.addAttribute(NSForegroundColorAttributeName, value: UIColor.clear , range: range1)
            
            let string_to_color2 = "|"
            let range2 = (strCounter as NSString).range(of: string_to_color2)
            attributedString1.addAttribute(NSForegroundColorAttributeName, value: UIColor.clear , range: range2)
            self.attributedText = attributedString1
        }
    }
    //Get notification counter
    func getNotificationCounter() -> String {
        
        if self.text?.length == 0 {
            
            return ""
            
        } else {
            
            var strCounter = self.text
            strCounter = strCounter?.replacingOccurrences(of: ":", with: "")
            strCounter = strCounter?.replacingOccurrences(of: "|", with: "")
            return strCounter!
        }
    }
    //Get dynamic height
    func requiredHeight() -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.frame.width, height : CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
    //Get dynamic width
    func requiredWidth() -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.frame.width,height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.width
    }
}
//Get dynamic label width
func widthForLabel(label:UILabel,text:String) ->CGFloat {
    
    let fontName = label.font.fontName;
    let fontSize = label.font.pointSize;
    
    let attributedText = NSMutableAttributedString(string: text,attributes: [NSFontAttributeName:UIFont(name: fontName,size: fontSize)!])
    let rect: CGRect = attributedText.boundingRect(with: CGSize(width: label.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    
    return ceil(rect.size.width)
}
//MARK: - UIApplication Extension
extension UIApplication {
    
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = viewController as? UINavigationController {
            
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            
            if let selected = tab.selectedViewController {
                
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
//MARK: - String Extension
extension String {
    //Get string length
    var length: Int { return characters.count    }  // Swift 2.0
    
    //Remove white space in string
    func removeWhiteSpace() -> String {
        
        return self.trimmingCharacters(in: .whitespaces)
    }
}
//MARK: - NSString Extension
extension NSString {
    //Remove white space in string
    func removeWhiteSpace() -> NSString {
        
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces) as NSString
    }
}
//MARK: - UISearchBar Class Modify
extension UISearchBar {
    //UISearchBar Text Color
    func setTextColor(color: UIColor) {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    //UISearchBar Set Font
    func setFont(font: UIFont) {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.font = font
    }
    //UISearchBar Placeholder Text Color
    func setPlaceholderColor(color: UIColor) {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf .setValue(color, forKeyPath: "_placeholderLabel.textColor")
    }
}
//MARK: - Create thumbnail image
func smallImageWithImage(sourceImage: UIImage) -> UIImage {
    
    var width:Int = 0
    var height:Int = 0
    let y = sourceImage.size.height
    let x = sourceImage.size.width
    
    if sourceImage.size.height > 175 || sourceImage.size.width > 175 {
        
        if sourceImage.size.height > sourceImage.size.width {
            
            height = 175
            width = 0
            
        } else {
            
            height = 0
            width = 175
            
        }
    }
    
    var factor:Double = 1.0
    if width > 0 {
        
        factor = (Double(width) / Double(x) ) as Double
        
    } else if height > 0 {
        
        factor = Double(height) / Double(y)
    }
    
    let newHeight = Double(y) * factor
    let newWidth = Double(x) * factor
    
    UIGraphicsBeginImageContext(CGSize(width : CGFloat(newWidth),height :  CGFloat(newHeight)))
    sourceImage.draw(in: CGRect(x : 0,y : 0,width : CGFloat(newWidth),height : CGFloat(newHeight)))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
//MARK: - NSDate Extention for UTC date
extension NSDate {
    
    func getUTCFormateDate() -> String {
        
        let dateFormatter = DateFormatter()
        let timeZone = NSTimeZone(name: "UTC")
        dateFormatter.timeZone = timeZone as TimeZone!
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self as Date)
    }
    
    func getSystemFormateDate() -> String {
        
        let dateFormatter = DateFormatter()
        let timeZone = NSTimeZone.system
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "dd/MM/yy hh:mma"
        return dateFormatter.string(from: self as Date)
    }
}
//MARK: - UIView Extension
extension UIView {

//MARK: - IBInspectable
    //Set Corner Radious
    @IBInspectable var cornerRadiushelper:CGFloat {
        
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    //Set Round
    @IBInspectable var Round:Bool {
        
        set {
            self.layer.cornerRadius = self.frame.size.height / 2.0
        }
        get {
            return self.layer.cornerRadius == self.frame.size.height / 2.0
        }
    }
    //Set Border Color 
    @IBInspectable var borderColor:UIColor {
        
        set {
            self.layer.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
    }
    //Set Border Width
    @IBInspectable var borderWidth:CGFloat {
        
        set {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    //Set Shadow in View
    func addShadowView(width:CGFloat=0.2, height:CGFloat=0.2, Opacidade:Float=0.7, maskToBounds:Bool=false, radius:CGFloat=0.5) {
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Opacidade
        self.layer.masksToBounds = maskToBounds
    }
    struct NLInnerShadowDirection: OptionSet {
        
        let rawValue: Int
        
        static let None = NLInnerShadowDirection(rawValue: 0)
        static let Left = NLInnerShadowDirection(rawValue: 1 << 0)
        static let Right = NLInnerShadowDirection(rawValue: 1 << 1)
        static let Top = NLInnerShadowDirection(rawValue: 1 << 2)
        static let Bottom = NLInnerShadowDirection(rawValue: 1 << 3)
        static let All = NLInnerShadowDirection(rawValue: 15)
    }
    
    func removeInnerShadow() {
        
        for view in self.subviews {
            
            if (view.tag == 2639) {
                
                view.removeFromSuperview()
                break
            }
        }
    }
    
    func addInnerShadow() {
        
        let c = UIColor()
        let color = c.withAlphaComponent(0.5)
        self.addInnerShadowWithRadius(radius: 3.0, color: color, inDirection: NLInnerShadowDirection.All)
    }
    
    func addInnerShadowWithRadius(radius: CGFloat, andAlpha: CGFloat) {
        
        let c = UIColor()
        let color = c.withAlphaComponent(alpha)
        self.addInnerShadowWithRadius(radius: radius, color: color, inDirection: NLInnerShadowDirection.All)
    }
    
    func addInnerShadowWithRadius(radius: CGFloat, andColor: UIColor) {
        
        self.addInnerShadowWithRadius(radius: radius, color: andColor, inDirection: NLInnerShadowDirection.All)
    }
    
    func addInnerShadowWithRadius(radius: CGFloat, color: UIColor, inDirection: NLInnerShadowDirection) {
        
        self.removeInnerShadow()
        let shadowView = self.createShadowViewWithRadius(radius: radius, andColor: color, direction: inDirection)
        self.addSubview(shadowView)
    }

    func createShadowViewWithRadius(radius: CGFloat, andColor: UIColor, direction: NLInnerShadowDirection) -> UIView {
        
        let shadowView = UIView(frame: CGRect(x: 0,y: 0,width: self.bounds.size.width,height: self.bounds.size.height))
        shadowView.backgroundColor = UIColor.clear
        shadowView.tag = 2639
        
        let colorsArray: Array = [ andColor.cgColor, UIColor.clear.cgColor ]
        
        if direction.contains(.Top) {
            
            let xOffset: CGFloat = 0.0
            let topWidth = self.bounds.size.width
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.startPoint = CGPoint(x:0.5,y: 0.0)
            shadow.endPoint = CGPoint(x:0.5,y: 1.0)
            shadow.frame = CGRect(x: xOffset,y: 0,width: topWidth,height: radius)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        if direction.contains(.Bottom) {
            
            let xOffset: CGFloat = 0.0
            let bottomWidth = self.bounds.size.width
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.startPoint = CGPoint(x:0.5,y: 1.0)
            shadow.endPoint = CGPoint(x:0.5,y: 0.0)
            shadow.frame = CGRect(x:xOffset,y: self.bounds.size.height - radius, width: bottomWidth,height: radius)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        
        if direction.contains(.Left) {
            
            let yOffset: CGFloat = 0.0
            let leftHeight = self.bounds.size.height
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.frame = CGRect(x:0,y: yOffset,width: radius,height: leftHeight)
            shadow.startPoint = CGPoint(x:0.0,y: 0.5)
            shadow.endPoint = CGPoint(x:1.0,y: 0.5)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        
        if direction.contains(.Right) {
            
            let yOffset: CGFloat = 0.0
            let rightHeight = self.bounds.size.height
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.frame = CGRect(x:self.bounds.size.width - radius,y: yOffset,width: radius,height: rightHeight)
            shadow.startPoint = CGPoint(x:1.0,y: 0.5)
            shadow.endPoint = CGPoint(x:0.0,y: 0.5)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        return shadowView
    }
}
//MARK: - Bundle Information
extension Bundle {
    
    var releaseVersionNumber: String? {
        
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
//MARK: - MTViewController
class MTViewController : UIViewController {
    
    //Outlet for auto resizing constraint constant set in different devices
    @IBOutlet var arrConstraint : [NSLayoutConstraint]!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if arrConstraint != nil {
            
            //Auto resizing constraint constant set in different devices
            for const in arrConstraint {
                
                const.constant = const.constant * Scale.x
            }
        }
    }
}

//MARK: - MTCollectionCell
class MTCollectionCell: UICollectionViewCell {
    
    @IBOutlet var arrCellConstants: [NSLayoutConstraint]!
    override func awakeFromNib() {
     
        if arrCellConstants != nil {
            
            for const in arrCellConstants {
                const.constant = const.constant * Scale.x
            }
        }
    }
}

//MARK: - MTCollectionCell
class MTTableCell: UITableViewCell {
    
    @IBOutlet var arrTableCellConstants: [NSLayoutConstraint]!
    override func awakeFromNib() {
        
        if arrTableCellConstants != nil {
            
            for const in arrTableCellConstants {
                const.constant = const.constant * Scale.x
            }
        }
    }
}
//MARK: - MTButton
class MTButton : UIButton {
    
    override func awakeFromNib() {
        //Font size auto resizing in different devices
        self.titleLabel?.font = self.titleLabel?.font.withSize((self.titleLabel?.font.pointSize)! * Scale.x)
    }
}
//MARK: - MTLabel
class MTLabel : UILabel {
    
    override func awakeFromNib() {
        //Font size auto resizing in different devices
        self.font = self.font.withSize(self.font.pointSize * Scale.x)
    }
}

//MARK: - MTTextView
class MTTextView: UITextView {
    
    override open func awakeFromNib() {
        
        self.font = self.font?.withSize((self.font?.pointSize)! * Scale.x)
    }
}

//MARK: - MTTextField
class MTTextField: UITextField {
    
    override open func awakeFromNib() {
        
        self.font = self.font?.withSize((self.font?.pointSize)! * Scale.x)
    }
}

//MARK: - UITextfield Extension
extension UITextField {
    
    //Set placeholder font
    func setPlaceholderFont(font: UIFont) {
        
        let lblPlaceHolder:UILabel = self.value(forKey: "_placeholderLabel") as! UILabel
        lblPlaceHolder.font = font
    }
    //Set placeholder text color
    func setPlaceholderTextColor(color: UIColor) {
        
        let lblPlaceHolder:UILabel = self.value(forKey: "_placeholderLabel") as! UILabel
        lblPlaceHolder.textColor = color
    }
}
//MARK: - Protocol Oriented Programming Language
protocol Shakeable { }

extension Shakeable where Self: UIView {
    
    func shake() {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x:self.center.x - 4.0, y:self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x:self.center.x + 4.0, y:self.center.y))
        layer.add(animation, forKey: "position")
    }
}
class MTImageView: UIImageView, Shakeable {
    
}
//MARK: - NSMutableArray Extension
extension NSMutableArray {
    
    func shuffle () {
        
        for i in (0..<self.count).reversed() {
            
            let ix1 = i
            let ix2 = Int(arc4random_uniform(UInt32(i+1)))
            (self[ix1], self[ix2]) = (self[ix2], self[ix1])
        }
    }
}
//MARK: - UIColor Extension
extension UIColor {
    
    static var keyboardColor:UIColor {
        
        return UIColor(red: 26.0 / 255.0, green: 26.0 / 255.0, blue: 25.0 / 255.0, alpha: 1.0)
    }
}
//MARK: - Dictionary Extension
extension Dictionary {
    
    /// An immutable version of update. Returns a new dictionary containing self's values and the key/value passed in.
    func updatedValue(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        
        var result = self
        result[key] = value
        return result
    }
    
    var nullsRemoved: [Key: Value] {
        
        let tup = filter { !($0.1 is NSNull) }
        return tup.reduce([Key: Value]()) { $0.0.updatedValue($0.1.value, forKey: $0.1.key) }
    }
}
//MARK: - Check internet connection speed
func checkInternetConnectionSpeed(completion : ((CGFloat)->())?) {

    let url = URL(string: "")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    let startTime = Date()
    
    print("====================")
    let task =  session.dataTask(with: request) { (data, resp, error) in
        
        guard error == nil && data != nil else{
            
            print("connection error or data is nill")
            completion!(CGFloat(0))
            return
        }
        guard resp != nil else{
            
            completion!(CGFloat(0))
            print("respons is nill")
            return
        }
        let length  = CGFloat( (resp?.expectedContentLength)!) / 1000000.0
        print(length)
        
        let elapsed = CGFloat( Date().timeIntervalSince(startTime))
        let MBPS = CGFloat(length/elapsed)
        let KBPS = CGFloat(MBPS * 125)
        
        completion!(KBPS)
    }
    task.resume()
}

