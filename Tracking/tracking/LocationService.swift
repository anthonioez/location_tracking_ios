import Foundation
import CoreLocation
import UIKit

public class LocationService: NSObject, CLLocationManagerDelegate
{    
    private let maxBGTime: TimeInterval = 170
    private let minBGTime: TimeInterval = 2
    
    private let minAcceptableLocationAccuracy: CLLocationAccuracy = 5
    private let waitForLocationsTime: TimeInterval = 3
    
    private let delegate: LocationServiceDelegate
    private let manager = CLLocationManager()
    
    private var isManagerRunning = false
    private var checkLocationTimer: Timer?
    private var waitTimer: Timer?
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var lastLocations = [CLLocation]()
    
    public private(set) var acceptableLocationAccuracy: CLLocationAccuracy = 100
    public private(set) var checkLocationInterval: TimeInterval = 10
    public private(set) var isRunning = false
    
    public init(delegate: LocationServiceDelegate)
    {
       
        self.delegate = delegate
        
        super.init()
        
        configureLocationService()
    }
    
    private func configureLocationService(){
        
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
    }
    
    public func requestAlwaysAuthorization() {
        
        manager.requestAlwaysAuthorization()
    }
    
    public func startUpdatingLocation(interval: TimeInterval, acceptableLocationAccuracy: CLLocationAccuracy = 100) {
        
        if isRunning {
            
            stopUpdatingLocation()
        }
        
        checkLocationInterval = interval > maxBGTime ? maxBGTime : interval
        checkLocationInterval = interval < minBGTime ? minBGTime : interval
        
        self.acceptableLocationAccuracy = acceptableLocationAccuracy < minAcceptableLocationAccuracy ? minAcceptableLocationAccuracy : acceptableLocationAccuracy
        
        isRunning = true
        
        addNotifications()
        startLocationService()
    }
    
    public func stopUpdatingLocation() {
        
        isRunning = false
        
        stopWaitTimer()
        stopLocationService()
        stopBackgroundTask()
        stopCheckLocationTimer()
        removeNotifications()
    }
    
    private func addNotifications() {
        
        removeNotifications()
        
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func removeNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startLocationService() {
        
        isManagerRunning = true
        manager.startUpdatingLocation()
    }
    
    private func stopLocationService()
    {
        isManagerRunning = false
        manager.stopUpdatingLocation()
    }
    
    @objc func applicationDidEnterBackground()
    {
        stopBackgroundTask()
        startBackgroundTask()
    }
    
    @objc func applicationDidBecomeActive()
    {
        stopBackgroundTask()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        delegate.locationService(self, didChangeAuthorization: status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        delegate.locationService(self, didFailWithError: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard isManagerRunning else { return }
        guard locations.count>0 else { return }
        
        lastLocations = locations
        
        if waitTimer == nil {
            startWaitTimer()
        }
    }
    
    private func startCheckLocationTimer()
    {
        
        stopCheckLocationTimer()
        
        checkLocationTimer = Timer.scheduledTimer(timeInterval: checkLocationInterval, target: self, selector: #selector(checkLocationTimerEvent), userInfo: nil, repeats: false)
    }
    
    private func stopCheckLocationTimer()
    {
        
        if let timer = checkLocationTimer
        {

            timer.invalidate()
            checkLocationTimer=nil
        }
    }
    
    @objc func checkLocationTimerEvent() {

        stopCheckLocationTimer()
        
        startLocationService()
        
        // starting from iOS 7 and above stop background task with delay, otherwise location service won't start
        self.perform(#selector(stopAndResetBgTaskIfNeeded), with: nil, afterDelay: 1)
    }
    
    private func startWaitTimer() {
        stopWaitTimer()
    
        waitTimer = Timer.scheduledTimer(timeInterval: waitForLocationsTime, target: self, selector: #selector(waitTimerEvent), userInfo: nil, repeats: false)
    }
    
    private func stopWaitTimer() {
        
        if let timer = waitTimer {
            
            timer.invalidate()
            waitTimer=nil
        }
    }
    
    @objc func waitTimerEvent()
    {
        stopWaitTimer()
        
        if acceptableLocationAccuracyRetrieved()
        {
            startBackgroundTask()
            startCheckLocationTimer()
            stopLocationService()
            
            delegate.locationService(self, didUpdateLocations: lastLocations)
        }
        else
        {
            
            startWaitTimer()
        }
    }
    
    private func acceptableLocationAccuracyRetrieved() -> Bool {
        
        let location = lastLocations.last!
        
        return location.horizontalAccuracy <= acceptableLocationAccuracy ? true : false
    }
   
    @objc func stopAndResetBgTaskIfNeeded()
    {
        
        if isManagerRunning
        {
            stopBackgroundTask()
        }
        else
        {
            stopBackgroundTask()
            startBackgroundTask()
        }
    }
    
    private func startBackgroundTask()
    {
        let state = UIApplication.shared.applicationState
        
        if ((state == .background || state == .inactive) && bgTask == UIBackgroundTaskIdentifier.invalid) {
            
            bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                
                self.checkLocationTimerEvent()
            })
        }
    }
    
    @objc private func stopBackgroundTask()
    {
        guard bgTask != UIBackgroundTaskIdentifier.invalid else { return }
        
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
}

public protocol LocationServiceDelegate {
    
    func locationService(_ manager: LocationService, didFailWithError error: Error)
    func locationService(_ manager: LocationService, didUpdateLocations locations: [CLLocation])
    func locationService(_ manager: LocationService, didChangeAuthorization status: CLAuthorizationStatus)
}


