//
//  Prefs.swift
//  Tracking
//
//  Created by anthonioez on 03/06/2019.
//  Copyright © 2019 anthonioez. All rights reserved.
//

import UIKit

class Store: NSObject
{
    private static let kNSUserDefaultsWatchlistKey: String = "store"
    
    static var fileUrl = { () -> URL in
        let dir: URL = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        
        return dir.appendingPathComponent("location.log")
    }()
    

    static var list: [Entry]
    {        
        get
        {
            var lst = [Entry]();
            
            if let data = UserDefaults.standard.object(forKey: "entries") as? Data
            {
                //if let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Entry]
                if let dic = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Entry]
                {
                    dic.forEach({ (item) in
                        if(item.latitude != 0 && item.longitude != 0)
                        {
                            lst.append(item);
                        }
                    })
                }
            }
            return lst
        }
        
        set(items)
        {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false)
            {
                //let encodedData = NSKeyedArchiver.archivedData(withRootObject: items)
                UserDefaults.standard.set(data, forKey: "entries")
            }
        }
    }
    
    static func addEntry(entry: Entry)
    {
        var lst = self.list
        lst.append(entry)
        self.list = lst
    }
    
    static func clear()
    {
        var lst = self.list
        lst.removeAll()
        self.list = lst;
    }
    
    static func remove(entry: Entry)
    {
        /*
        var lst = self.list
        if let index = find(lst, entry)
        {
            lst.removeAtIndex(index)
            self.list = lst
        }
         */
    }

}
