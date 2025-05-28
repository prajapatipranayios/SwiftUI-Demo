//
//  HomeVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import GoogleMaps
import FloatingPanel

class HomeVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var lblNotificationCount: UILabel!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var cvEvents: UICollectionView!
    @IBOutlet weak var btnAdd: UIButton!
    
    var viewInfo: MarkerPopUp?

    var fpc: FloatingPanelController!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    var locationManager: CLLocationManager?
//    var currentlocation = CLLocation()
    
    var dictParams = Dictionary<String, Any>()

    var posts = Array<PostEventDetail>()
    
    var markerList = [GMSMarker]()
    var locationMarker: GMSMarker!
    var currentLocationMarker: GMSMarker?
    
    var selectedMarkerIndex = -1
    var selectedFilterIndex = 0
    var filterData = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UserDefaults.standard.set(false, forKey: "isZoomLevel")
        
        screenSize = 536.0
        
        lblNotificationCount.layer.cornerRadius = lblNotificationCount.frame.height / 2.0
        lblNotificationCount.layer.borderWidth = 1.0
        lblNotificationCount.layer.borderColor = UIColor.white.cgColor
        
        lblNotificationCount.isHidden = true
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 30.0
        fpc.isRemovalInteractionEnabled = true

        blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(blurView)
        blurView.isHidden = true
        
        DispatchQueue.main.async {
            self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        }

        layoutCells()
        cvEvents.register(UINib(nibName: "PostCVCell", bundle: nil), forCellWithReuseIdentifier: "PostCVCell")
        cvEvents.register(UINib(nibName: "EventCVCell", bundle: nil), forCellWithReuseIdentifier: "EventCVCell")

//        if APIManager.sharedManager.user?.isNewUser == 1 {
//            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "GuidelineVC") as! GuidelineVC
//            objVC.modalPresentationStyle = .fullScreen
//            self.present(objVC, animated: true, completion: nil)
//        }
        
        // For get current location
        showLocationPermisionPopUp()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        viewMap.delegate = self
//        viewMap.isMyLocationEnabled = false
//        UserDefaults.standard.set(false, forKey: "isZoomLevel")
        
        filterData["distance"] = Float(15.0)
        filterData["postType"] = [1,2,3]
        filterData["eventType"] = [1,2,3]
        filterData["sortBy"] = "distance"
        
        dictParams.updateValue(appDelegate.currentlocation?.latitude ?? 0.0, forKey: "latitude")
        dictParams.updateValue(appDelegate.currentlocation?.longitude ?? 0.0, forKey: "longitude")
        dictParams.updateValue(filterData["distance"]!, forKey: "distance")
        dictParams.updateValue(filterData["sortBy"]!, forKey: "sortOption")
        dictParams.updateValue(["post": filterData["postType"], "event": filterData["eventType"]], forKey: "filterOption")
        
        cvEvents.isHidden = true
        
        print("FCM :::: \(UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as! String)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if APIManager.sharedManager.notificationCount > 0 {
            lblNotificationCount.isHidden = false
        }else {
            lblNotificationCount.isHidden = true
        }
    }
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvEvents.frame.size.width, height: cvEvents.frame.size.height)
        layout.scrollDirection = .horizontal
        self.cvEvents.setCollectionViewLayout(layout, animated: true)
    }
    
    func showLocationPermisionPopUp() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
                return
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.checkForLocation()
                }
                
                return
            case .authorizedAlways, .authorizedWhenInUse:
                break
            default:
                break
        }
    }
    
//    func fitAllMarkers() {
//        var bounds = GMSCoordinateBounds()
//        for marker in self.markerList {
//            bounds = bounds.includingCoordinate(marker.position)
//        }
//        CATransaction.begin()
//        CATransaction.setValue(1.4, forKey: kCATransactionAnimationDuration)
//        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds))
//        CATransaction.commit()
//    }
    
    func checkForLocation() {
        let alert = UIAlertController(title: AppInfo.AppTitle.returnAppInfo(), message: "Turn on location services to allow \"Food Flocker\" to determine your location", preferredStyle: .alert)
        alert.view.tintColor = .black
        alert.addAction(UIAlertAction(title: "Settings", style: .default){
            UIAlertAction in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.view.ffTabVC.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Webservices

    func getNearByPostEvents() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getNearByPostEvents()
                }
            }
            return
        }
        
        dictParams.updateValue(appDelegate.currentlocation?.latitude ?? 0.0, forKey: "latitude")
        dictParams.updateValue(appDelegate.currentlocation?.longitude ?? 0.0, forKey: "longitude")
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_NEAR_BY_POST_EVENTS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.posts.removeAll()
                
                self.posts = (response?.result?.totalPost)!
                DispatchQueue.main.async {
                    self.cvEvents.dataSource = self
                    self.cvEvents.delegate = self
                    self.cvEvents.reloadData()
                    
                    self.viewMap.clear()
                    
                    
                    self.markerList.removeAll()
                    
                    for i in 0..<self.posts.count {
                        self.addMarker(index: i, post: self.posts[i])
                    }
                    
                    self.addCurrentLocationMarker()
                    
                    self.fitAllMarkers()
                    
                    self.cvEvents.isHidden = true
                    self.cvEvents.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func fitAllMarkers() {
        var bounds = GMSCoordinateBounds()
        for marker in self.markerList {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        CATransaction.begin()
        CATransaction.setValue(1.4, forKey: kCATransactionAnimationDuration)
        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds))
        CATransaction.commit()
    }

    // MARK: - Button Click Events
    @IBAction func onTapCurrentLocation(_ sender: UIButton) {
        if let location = appDelegate.currentlocation {
            self.viewMap.animate(to: GMSCameraPosition.camera(withTarget: location, zoom:16.0))
//                self.viewMap!.animate(with: GMSCameraUpdate.fit(self.tmpBound, with: UIEdgeInsets(top: (self.viewMap.frame.height - self.viewRoutImg.frame.height) / 2, left: 10, bottom: (self.viewMap.frame.height - self.viewRoutImg.frame.height) / 2, right: 10)))
        }
    }
    
    @IBAction func onTapFilter(_ sender: UIButton) {
//        let filterDialog = self.storyboard?.instantiateViewController(withIdentifier: "ApplyFilterVC") as! ApplyFilterVC
//        filterDialog.modalPresentationStyle = .overCurrentContext
//        filterDialog.modalTransitionStyle = .crossDissolve
//
//        self.view.ffTabVC.present(filterDialog, animated: true, completion: nil)
        
        screenSize = 526.0
        let filterDialog = self.storyboard?.instantiateViewController(withIdentifier: "ApplyFilterVC") as? ApplyFilterVC
        filterDialog?.filterData = self.filterData
//        filterDialog?.selectedFilterIndex = self.selectedFilterIndex
        filterDialog?.updateFrame = { selectedIndex, filterData in
            
//            self.filterData = filterData
//
//            self.dictParams.updateValue(filterData["distance"]!, forKey: "distance")
//            self.dictParams.updateValue(filterData["sortBy"]!, forKey: "sortOption")
//            self.dictParams.updateValue(["post": filterData["postType"], "event": filterData["eventType"]], forKey: "filterOption")
            
            if selectedIndex == 0 {
                screenSize = 526.0
            } else {
                screenSize = 431.0
            }
            
            self.fpc.set(contentViewController: filterDialog)
            
            self.fpc.addPanel(toParent: self.view.ffTabVC, animated: false)
            self.blurView.isHidden = false
            
//            self.blurView.isHidden = false
        }
        
        filterDialog?.ontapApply = { filterData in
            self.filterData = filterData
            
            self.dictParams.updateValue(filterData["distance"]!, forKey: "distance")
            self.dictParams.updateValue(filterData["sortBy"]!, forKey: "sortOption")
            self.dictParams.updateValue(["post": filterData["postType"], "event": filterData["eventType"]], forKey: "filterOption")
            self.blurView.isHidden = true
            
            
            self.getNearByPostEvents()
        }
        
        fpc.set(contentViewController: filterDialog)
        
        fpc.addPanel(toParent: self.view.ffTabVC, animated: true)
        blurView.isHidden = false

    }
    
    @IBAction func onTapNotifications(_ sender: UIButton) {
        let notifications = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        self.view.ffTabVC.navigationController?.pushViewController(notifications, animated: true)
    }
    
    @IBAction func onTapAddPosts(_ sender: UIButton) {
        
        self.btnAdd.isHidden = true
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddButtonVC") as! AddButtonVC
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        objVC.onTappedDismiss = {
            self.btnAdd.isHidden = false
        }
        
        objVC.onTappedAddPost = {
            self.btnAdd.isHidden = false
            let addPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
            addPostVC.ontapUpdate = {
                self.getNearByPostEvents()
            }
            
            self.view.ffTabVC.navigationController?.pushViewController(addPostVC, animated: true)
        }
        
        objVC.onTappedCreateEvent = {
            self.btnAdd.isHidden = false
            let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
            self.view.ffTabVC.navigationController?.pushViewController(addEventVC, animated: true)
        }
        
        self.view.ffTabVC.navigationController?.present(objVC, animated: false, completion: nil)
        
//        let addPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
//        self.view.ffTabVC.navigationController?.pushViewController(addPostVC, animated: true)
        
//        let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
//        self.view.ffTabVC.navigationController?.pushViewController(addEventVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - MapView Methods
    
    // Add Marker in map
    func addMarker(index:Int, post:PostEventDetail) {
        let position = CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)
        self.locationMarker = GMSMarker(position: position)
        self.locationMarker.accessibilityLabel = "\(index)"
        self.locationMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
        
        var pinIcon = UIImage(named: "")
        
        if post.module == "Post" {
            pinIcon = UIImage(named: "post_pin")

        }else {
            pinIcon = UIImage(named: "event_pin")
        }
        
        self.locationMarker.zIndex = Int32(index)
        
        let pin = MarkerView(frame: CGRect(x: 0, y: 0, width: 36, height: 56), image: pinIcon!)
        self.locationMarker.iconView = pin
        self.locationMarker.map = self.viewMap
        self.markerList.append(self.locationMarker)
    }
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.item]
        
        if post.module == "Event" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCVCell", for: indexPath) as! EventCVCell
            cell.lblEventName.text = post.title
            cell.lblEventDateTime.text = post.startDate
            cell.lblLocation.text = post.address
            cell.ivEvent.setImage(imageUrl: post.mediaImage!)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCVCell", for: indexPath) as! PostCVCell
            cell.lblEventName.text = post.title
            cell.lblEventDesc.text = post.description
            cell.lblOwnerName.text = post.name
            cell.lblRatings.text = "\(post.rating ?? 0.0)"
            cell.lblVeg.text = post.categoryId == 1 ? "Veg." : "Non Veg."
            cell.lblExpire.text = post.expiringDate
            cell.lblReviews.text = "(\(post.reviewCount) reviews)"
            cell.lblReviews.setUnderLine(text: "\(post.reviewCount) reviews")

            if post.amount! == "" {
                cell.btnPrice.isHidden = true
            }else {
                cell.btnPrice.setTitle("  \(post.amount! == "$0" ? "Free" : post.amount!)  ", for: .normal)
                cell.btnPrice.titleLabel?.minimumScaleFactor = 0.2
            }
            
            cell.ivEvent.setImage(imageUrl: post.mediaImage!)
            cell.ivEventOwner.setImage(imageUrl: post.profilePic)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cvEvents.frame.size.width - 32, height: self.cvEvents.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        
        if post.module == "Event" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
            vc.eventId = posts[indexPath.item].id
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
            vc.postId = posts[indexPath.item].id
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let center = CGPoint(x: (scrollView.contentOffset.x) + ((scrollView.frame.width - 32) / 2), y: (scrollView.frame.height / 2))

        if let ip = self.cvEvents.indexPathForItem(at: center) {
            print(ip)
            
            self.cvEvents.isPagingEnabled = false
            self.cvEvents.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
            self.cvEvents.isPagingEnabled = true
            
            if selectedMarkerIndex > -1 || selectedMarkerIndex != ip.item {
                var pinIcon = UIImage(named: "")
                if posts[selectedMarkerIndex].module == "Post" {
                    pinIcon = UIImage(named: "post_pin")
                }else {
                    pinIcon = UIImage(named: "event_pin")
                }
                
                let pin = MarkerView(frame: CGRect(x: 0, y: 0, width: 36, height: 56), image: pinIcon!)
                markerList[selectedMarkerIndex].iconView = pin
            }
            
            selectedMarkerIndex = ip.item
            
            viewInfo = Bundle.main.loadNibNamed("MarkerPopUp", owner: self, options: nil)?[0] as? MarkerPopUp
    //            viewInfo?.viewMain.layer.cornerRadius = 10.0
            viewInfo?.index = ip.item
            viewInfo?.delegate = self
            
            viewInfo?.imgMarker.setImage(imageUrl: posts[ip.item].mediaImage!)
            
            markerList[selectedMarkerIndex].iconView = viewInfo
            
    //            markerList[selectedMarkerIndex].icon = viewInfo?.asImage()
            
            let cameraPosition = GMSCameraPosition.camera(withLatitude: posts[ip.item].latitude, longitude: posts[ip.item].longitude, zoom: 16.0)
            viewMap.animate(to: cameraPosition)
        }
   }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        cvEvents.layoutIfNeeded()
//    }
}

extension HomeVC: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpc.surfaceView.borderWidth = 0.0
        fpc.surfaceView.borderColor = nil
        return FilterLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
    
}

public class FilterLayout: FloatingPanelLayout {
    
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .half: return screenSize
            default: return nil
        }
    }
    
//    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
//        if #available(iOS 11.0, *) {
//            return [
//                surfaceView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 50.0)
//            ]
//        } else {
//            // Fallback on earlier versions
//            return [
//                surfaceView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50.0)
//            ]
//        }
//    }
}

extension HomeVC: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        appDelegate.currentlocation = manager.location!.coordinate
        let latitude = appDelegate.currentlocation?.latitude
        let longitude = appDelegate.currentlocation?.longitude
//        currentlocation = CLLocation(latitude: latitude!, longitude: longitude!)
//        self.viewMap.animate(to: GMSCameraPosition.camera(withTarget: appDelegate.currentlocation!, zoom:16.0))
        if UserDefaults.standard.bool(forKey: "isZoomLevel") == false {
            UserDefaults.standard.set(true, forKey: "isZoomLevel")
            self.viewMap.animate(to: GMSCameraPosition.camera(withTarget: locations[0].coordinate, zoom:16.0))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        default:
            addCurrentLocationMarker()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.fitAllMarkers()
                self.getNearByPostEvents()
            }
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error.localizedDescription)")
    }
    
    func addCurrentLocationMarker() {
        currentLocationMarker?.map = nil
        currentLocationMarker = nil
        currentLocationMarker?.isTappable = true
        if let location = locationManager?.location {
            currentLocationMarker = GMSMarker(position: location.coordinate)
            currentLocationMarker?.accessibilityLabel = "-2"
            currentLocationMarker?.icon = UIImage(named: "Current_location")
            currentLocationMarker?.map = viewMap
            currentLocationMarker?.rotation = locationManager?.location?.course ?? 0
            self.markerList.append(self.currentLocationMarker!)
        }
        
        
    }
    
}

extension HomeVC: GMSMapViewDelegate, MarkerPopUpDelegate {
    
    func didPressMarker(index: Int) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = Int(marker.accessibilityLabel!)!
        
        if index == -2 {
            return false
        }
        
        cvEvents.isHidden = false
        
        if selectedMarkerIndex == index {
            if posts[selectedMarkerIndex].module == "Event" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
                vc.eventId = posts[selectedMarkerIndex].id
                self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
                vc.postId = posts[selectedMarkerIndex].id
                self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
            }
        }else {
            
            if selectedMarkerIndex > -1 {
                var pinIcon = UIImage(named: "")
                if posts[selectedMarkerIndex].module == "Post" {
                    pinIcon = UIImage(named: "post_pin")
                }else {
                    pinIcon = UIImage(named: "event_pin")
                }
                
                let pin = MarkerView(frame: CGRect(x: 0, y: 0, width: 36, height: 56), image: pinIcon!)
                markerList[selectedMarkerIndex].iconView = pin
            }
            
            selectedMarkerIndex = index
            
            viewInfo = Bundle.main.loadNibNamed("MarkerPopUp", owner: self, options: nil)?[0] as? MarkerPopUp
            viewInfo?.index = index
            viewInfo?.delegate = self
            
            viewInfo?.imgMarker.setImage(imageUrl: posts[index].mediaImage!)
            
            markerList[selectedMarkerIndex].iconView = viewInfo
            
//            markerList[selectedMarkerIndex].icon = viewInfo?.asImage()

            print(index)
            self.cvEvents.isPagingEnabled = false
            cvEvents.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            self.cvEvents.isPagingEnabled = true
            
        }
        
        return true
    }
}
