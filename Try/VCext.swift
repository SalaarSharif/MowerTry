//
//  VCext.swift
//  Try
//
//  Created by Hazem Tariq on 12/8/20.
//

import Foundation
import CoreLocation

extension ViewController : CLLocationManagerDelegate {
    static let locMgr = CLLocationManager()
    static var userLoc : CLLocation?
    
    func startLocationUpdates() {
        ViewController.locMgr.delegate = self
        ViewController.locMgr.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            ViewController.locMgr.distanceFilter = 100
            ViewController.locMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            ViewController.locMgr.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ViewController.userLoc = locations.last
    }
}
