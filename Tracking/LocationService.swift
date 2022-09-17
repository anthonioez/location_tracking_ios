//
//  LocationService.swift
//  Tracking
//
//  Created by Anthony Ezeh on 02/06/2019.
//  Copyright © 2019 Anthony Ezeh. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public class LocationService: NSObject, CLLocationManagerDelegate
{
    var locationManager: CLLocationManager?
    private let delegate: LocationServiceDelegate

    public init(delegate: LocationServiceDelegate)
    {
        self.delegate = delegate
        
        super.init()
        
        setup()
    }

    func setup()
    {
        removeNotifications()
        
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    private func removeNotifications()
    {        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationDidEnterBackground()
    {
        startMonitoring()
    }
    
    @objc func applicationDidBecomeActive()
    {
        stopMonitoring()
    }
    
    func startMonitoring()
    {
        locationManager = CLLocationManager()
        locationManager?.delegate = self;
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false;
        //locationManager?.activityType = CLActivityTypeOtherNavigation;
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways
        {
            // User has not authorized access to location information.
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable()
        {
            // The service is not available.
            return
        }

        locationManager?.startMonitoringSignificantLocationChanges();
    }
    
    func stopMonitoring()
    {
        locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    //MARK:- CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        delegate.locationService(self, didUpdateLocations: locations);
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if let error = error as? CLError, error.code == .denied
        {
            // Location updates are not authorized.
            //manager.stopMonitoringSignificantLocationChanges()
            return
        }
        
        delegate.locationService(self, didFailWithError: error);
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        delegate.locationService(self, didChangeAuthorization: status);
    }
}

public protocol LocationServiceDelegate
{    
    func locationService(_ manager: LocationService, didFailWithError error: Error)
    func locationService(_ manager: LocationService, didUpdateLocations locations: [CLLocation])
    func locationService(_ manager: LocationService, didChangeAuthorization status: CLAuthorizationStatus)
}


