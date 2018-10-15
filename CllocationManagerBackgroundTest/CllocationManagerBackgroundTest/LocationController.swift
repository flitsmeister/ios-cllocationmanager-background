//
//  LocationController.swift
//  CllocationManagerBackgroundTest
//
//  Created by Sjoerd Perfors on 12/10/2018.
//  Copyright © 2018 Flitsmeister. All rights reserved.
//

import Foundation
import CoreLocation
import CocoaLumberjackSwift

class LocationController : NSObject {
    
    let manager = CLLocationManager.init()
    let date = Date()
    var timer : Timer?
    
    override init() {
    }

    
    func start() {
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (t:Timer) in
            let minutes = abs(self.date.timeIntervalSinceNow) / 60
            DDLogInfo("[TIMER] [\(round(minutes)) MIN]")
        }
    }
}

extension LocationController : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let newLocation = locations.last else {
            DDLogInfo("[NO LOCATION]")
            return
        }
        
        DDLogInfo("[LOC:\(newLocation.timestamp)/ACCURACY:\(round(newLocation.horizontalAccuracy))]")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DDLogError("[ERROR:\(error)]")
    }
}
