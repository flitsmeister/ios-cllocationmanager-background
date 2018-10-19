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
import os.log

class LocationController : NSObject {
    
    static let sharedInstance = LocationController()
    
    private let manager = CLLocationManager.init()
    private let date = Date()
    private var timer : Timer?
    private var running: Bool = false
    private var lastLocation: CLLocation?
    
    private override init() {
    }
    
    func start() {
        
        if running == false {

            manager.requestAlwaysAuthorization()
            manager.delegate = self
            manager.distanceFilter = kCLDistanceFilterNone
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
            manager.startUpdatingLocation()
            os_log("701781652.LocationController.start CLLocationManager started")
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (t:Timer) in
                let minutes = round(abs(self.date.timeIntervalSinceNow) / 60)
                let secondsOld = round(abs(self.lastLocation?.timestamp.timeIntervalSinceNow ?? 999))
                DDLogInfo("[TIMER] [\(minutes) MIN] [LOCATION-TIMESTAMP:\(secondsOld) SEC OLD]")
                
                os_log("701781652.LocationController.timer(block) %ld minutes running, last CLLocation is %ld seconds old", minutes, secondsOld)
            }
            running = true
        }
    }
}

extension LocationController : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lastLocation = locations.last
        guard let newLocation = locations.last else {
            os_log("701781652.LocationController.manager.didUpdateLocations no.location")
            DDLogVerbose("[NO LOCATION]")
            return
        }
        os_log("701781652.LocationController.manager.didUpdateLocations")
        DDLogVerbose("[LOC:\(newLocation.timestamp)/ACCURACY:\(round(newLocation.horizontalAccuracy))]")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("701781652.LocationController.manager.didFailWithError")
        DDLogError("[ERROR:\(error)]")
    }
}
