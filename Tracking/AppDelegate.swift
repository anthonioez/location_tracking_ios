//
//  AppDelegate.swift
//  Tracking
//
//  Created by anthonioez on 01/06/2019.
//  Copyright © 2019 anthonioez. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LocationServiceDelegate
{
    var window: UIWindow?
    var navController: UINavigationController?

    var manager: LocationService?
    var lastLocation: CLLocation?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        manager = LocationService(delegate: self)
        
        if let _ = launchOptions?[UIApplication.LaunchOptionsKey.location]
        {
            BackgroundDebug().write(string: "UIApplicationLaunchOptionsLocationKey")

            let entry = Entry([:])
            entry.latitude = 1;
            entry.longitude = 1;
            Store.addEntry(entry: entry)
            
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "LOCATION"), object: entry);
        }
        else
        {
            BackgroundDebug().write(string: "UIApplicationLaunchOptions")

            navController = UINavigationController();
            navController?.isNavigationBarHidden = true
            navController?.view.backgroundColor = .black;
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window!.rootViewController = navController
            self.window!.backgroundColor = UIColor.black
            self.window!.makeKeyAndVisible()
            
            navController?.pushViewController(MainViewController.instance(), animated: true)
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK:- LocationManagerDelegate
    func locationService(_ manager: LocationService, didFailWithError error: Error)
    {
    }
    
    func locationService(_ manager: LocationService, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else
        {
            return
        }
        
        BackgroundDebug().write(string: "Scheduled Update")

        updateLocation(location)
    }
    
    func locationService(_ manager: LocationService, didChangeAuthorization status: CLAuthorizationStatus)
    {
        
    }
    
    
    //MARK:- Funcs
    func updateLocation(_ location: CLLocation)
    {
        let entry = Entry([:])
        entry.latitude = location.coordinate.latitude
        entry.longitude = location.coordinate.longitude
        entry.speed = location.speed < 0 ? 0 : location.speed
        entry.stamp = Date().timeIntervalSince1970;
        
        Store.addEntry(entry: entry);
        
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "LOCATION"), object: entry);
        
        //self.lastLocation = location
        
        BackgroundDebug().write(string: "(\(entry.latitude), \(entry.longitude)) \(AppDelegate.date(entry.stamp))")
    
        uploadData(entry)
    }
    
    func uploadData(_ entry: Entry)
    {
        let headers = [
            "Content-Type": "application/json",
        ]

        var params = [String:Any]()
        params["device"]    = "\(DeviceUID.uid()!)";
        params["lat"]       = String(format: "%.6f", entry.latitude);
        params["lng"]       = String(format: "%.6f", entry.longitude);
        params["speed"]     = String(format: "%.2f", entry.speed);
        
        #if DEBUG
        params["lat"]       = "51.343536"
        params["lng"]       = "-0.131415"
        #endif
        
        let url = URL(string: "https://www.google.com") // TODO
        
        //create the session object
        let session = URLSession.shared
        
        do
        {
            let postData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            //var request = URLRequest(url: url)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 30.0)
            request.httpMethod = "POST"
            request.httpBody = postData as Data
            request.allHTTPHeaderFields = headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                if (error != nil)
                {
                    print(error?.localizedDescription ?? "")
                }
                else
                {
                    guard let data = data else
                    {
                        return
                    }
                    
                    print(String.init(data: data, encoding: String.Encoding.utf8) ?? "")
                }
            })
            task.resume()
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    static func date(_ stamp: Double) -> String
    {
        let date = Date(timeIntervalSince1970: stamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss a"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent;
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
    }

}

