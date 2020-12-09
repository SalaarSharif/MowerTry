//
//  MowerDetailsViewController.swift
//  Try
//
//  Created by Hazem Tariq on 12/8/20.
//

import UIKit
import MapKit
import CoreLocation
import AWSAppSync
import AWSMobileClient
import Contacts
class MowerDetailsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblName: UILabel!
    
    var appUser : AppUser?
//    var watcher : AWSAppSyncSubscriptionWatcher<OnUpdateSvcReqSubscription>?
//    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = appUser{
            let ann = MKPointAnnotation()
            ann.coordinate = CLLocationCoordinate2D(latitude: user.locLat, longitude: user.locLng)
            mapView.addAnnotation(ann)
            mapView.showAnnotations(mapView.annotations, animated: true)
            
        }
//        if let user = appUser {
//            mapView.showsUserLocation = true
//            annotation.coordinate = CLLocationCoordinate2D(latitude: user.locLat, longitude: user.locLng)
//            mapView.addAnnotation(annotation)
//            mapView.showAnnotations(mapView.annotations, animated: true)
//        }
        
       lblName.text = appUser?.userName ?? "(No Name)"
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doBtnMow(_ sender: Any) {
        guard let userLoc = ViewController.userLoc else { return }
        
        CLGeocoder().reverseGeocodeLocation(userLoc) { (placemarks, error) in
            guard error == nil else { return }

            guard let pm = placemarks?.first else { return }
            
            let addrFormatter = CNPostalAddressFormatter()
            addrFormatter.style = .mailingAddress
            guard let pa = pm.postalAddress else { return }
            let addr = addrFormatter.string(from: pa)
            
            let input = CreateSvcReqInput.init( custUName:AWSMobileClient.default().username ?? "no name" , provUName: self.appUser?.userName ?? "no name", svcLat: userLoc.coordinate.latitude, svcLng: userLoc.coordinate.longitude, svcAddr: addr, accepted: false)
            let mut = CreateSvcReqMutation(input: input)
            (UIApplication.shared.delegate as! AppDelegate).appSyncClient?.perform(mutation: mut, resultHandler: { (result, error) in
                print (error?.localizedDescription)
                print (result)
               // self.startSub()
            })
        }
    }
}
