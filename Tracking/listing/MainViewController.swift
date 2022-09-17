//
//  MainViewController.swift
//  Tracking
//
//  Created by anthonioez on 02/06/2019.
//  Copyright © 2019 anthonioez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate //,CLLocationManagerDelegate
{
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labelCount: UILabel!
    
    var overlay: MKOverlay!
    var locations = [Entry]();
    
    var appDelagete = {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static func instance() -> MainViewController
    {
        let vc = MainViewController(nibName: "MainViewController", bundle: nil)
        return vc;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setupMap()
        setupList()
        
        if(Prefs.active)
        {
            stopUI()
        }
        else
        {
            startUI()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventHandler), name: NSNotification.Name.init(rawValue: "LOCATION"), object: nil);
    
        if let manager = appDelagete().manager
        {
            if CLLocationManager.authorizationStatus() == .authorizedAlways
            {
            }
            else
            {
                manager.requestAlwaysAuthorization()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        reload()
    }

    @objc func eventHandler(_ notification: Notification)
    {
        if let entry = notification.object as? Entry
        {
            locations.append(entry);
            tableList.reloadData()
            tableList.scrollToRow(at: IndexPath.init(row: locations.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true);
            
            reloadMap();
            
            labelCount.text = "\(Store.list.count)"
        }
        else
        {
            reload()
        }
    }
    
    func setupMap()
    {
        mapView.delegate = self;
    }
    
    func setupList()
    {
        mapView.delegate = self

        tableList.delegate = self
        tableList.dataSource = self
        
        tableList.separatorColor = UIColor.clear
        tableList.register(UINib(nibName: MainCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: MainCell.cellIdentifier)
    }
    
    //MARK:- Actions
    @IBAction func onButtonReload(_ sender: Any)
    {
        reload()
    }
    
    @IBAction func onButtonClear(_ sender: Any)
    {
        BackgroundDebug().clear()
        Store.clear()
        
        reload()
    }
    
    @IBAction func onButtonStart(_ sender: Any)
    {
        if !CLLocationManager.locationServicesEnabled()
        {
            return
        }
        
        if let manager = appDelagete().manager
        {
            if manager.isRunning
            {
                startUI()

                manager.stopUpdatingLocation()
            }
            else
            {
                if CLLocationManager.authorizationStatus() == .authorizedAlways
                {
                    stopUI()
                    
                    manager.startUpdatingLocation(interval: 30, acceptableLocationAccuracy: 500)
                }
                else
                {
                    manager.requestAlwaysAuthorization()
                }
            }
        }
    }
    
    //MARK:- MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if let polyline = overlay as? MKPolyline
        {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return MainCell.cellHeight;
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return locations.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = locations[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: MainCell.cellIdentifier, for: indexPath as IndexPath) as!MainCell
        cell.setData(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let item = locations[indexPath.row];
        let coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
        zoomToPoint(coordinate)

        tableView.deselectRow(at: indexPath, animated: false);
    }
    
    func startUI()
    {
        buttonStart.setTitle("Start", for: .normal)
    }

    func stopUI()
    {
        buttonStart.setTitle("Stop", for: .normal)
    }
    
    func reload()
    {
        let list = Store.list;
        
        locations.removeAll()
        locations.append(contentsOf: list);
        tableList.reloadData()
        
        labelCount.text = "\(list.count)"
        
        reloadMap()
        
        if let last = locations.last
        {
            zoomToPoint(CLLocationCoordinate2D(latitude: last.latitude, longitude: last.longitude))
        }
    }
    
    func reloadMap()
    {
        if(overlay != nil)
        {
            mapView.removeOverlay(overlay!)
        }

        var routeCoordinates = [CLLocationCoordinate2D]()
        locations.forEach { (entry) in
            let coordinate = CLLocationCoordinate2D(latitude: entry.latitude, longitude: entry.longitude)
            
            routeCoordinates.append(coordinate)
        }
        
        let routeLine = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.setVisibleMapRect(routeLine.boundingMapRect.insetBy(dx: -100, dy: -100), animated: false)
        mapView.addOverlay(routeLine)
        
        overlay = routeLine;
    }
    
    func zoomToPoint(_ coordinate: CLLocationCoordinate2D)
    {
        let regionRadius: CLLocationDistance = 100
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
    }
}
