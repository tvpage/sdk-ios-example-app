

import UIKit
import TVPFramework

//MARK: - Side Menu View Controller
class SideMenuVC: UIViewController {

    //MARK: - IBOutlet Declaration
    @IBOutlet var viewContent: UIView!
    @IBOutlet var lblTitleHeader: UILabel!
    
    //MARK: - Variable Declaration
    var widgetType = WidgetType.none
    
    //MARK : - UIViewController override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialization
        self.initialization()
        
        //Design Update
        self.designUpdate()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Change statusbar color
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - Initialization
    func initialization() {
        
        
    }
    //MARK: - Design Update
    func designUpdate() {
        
        if widgetType == .sidebar {
        
            //Set Title Header
            lblTitleHeader.text = "Sidebar Widget"
            
            //SidebarView
            let sidebarView = SidebarView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - viewContent.frame.origin.y - (DeviceType.IS_IPHONE_X ? 50.0 : 0.0)))
            viewContent.addSubview(sidebarView)
            
        } else if widgetType == .solo {
            
            //Set Title Header
            lblTitleHeader.text = "Solo Widget"
            
            //SoloView
            let soloView = SoloView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewContent.frame.size.height))
            viewContent.addSubview(soloView)
            
        } else if widgetType == .carousel {
            
            //Set Title Header
            lblTitleHeader.text = "Carousel Widget"
            
            //CarouselView
            let carouselView = CarouselView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewContent.frame.size.height))
            viewContent.addSubview(carouselView)
            
        } else if widgetType == .videoGallery {
            
            //Set Title Header
            lblTitleHeader.text = "Video Gallery"
            
            let frameworkBundle = Bundle(identifier: "com.manektech.TVPFramework")
            let storyboard = UIStoryboard(name: "VideoGallery", bundle: frameworkBundle)
            let videoGallery = storyboard.instantiateViewController(withIdentifier: "VideoGalleryVC") as! VideoGalleryVC
            videoGallery.isHiddenBackButton = false
            self.navigationController?.pushViewController(videoGallery, animated: false)
        }
    }
}
//MARK: - IBAction
extension SideMenuVC {
    
    //Tapped On Back
    @IBAction func tappedOnBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

