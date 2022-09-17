//
//  Entry.swift
//  Tracking
//
//  Created by anthonioez on 03/06/2019.
//  Copyright © 2019 anthonioez. All rights reserved.
//

import UIKit

class Entry: NSObject, NSCoding
{
    public var latitude = Double(0)
    public var longitude = Double(0)
    public var speed = Double(0)
    public var stamp = Double(0)

    init(_ json: [String: Any])
    {
        self.latitude = (json["latitude"] as? Double) ?? 0
        self.longitude = (json["longitude"] as? Double) ?? 0

    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.speed, forKey: "speed")
        aCoder.encode(self.stamp, forKey: "stamp")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.speed = aDecoder.decodeDouble(forKey: "speed")
        self.stamp = aDecoder.decodeDouble(forKey: "stamp")
    }
}
