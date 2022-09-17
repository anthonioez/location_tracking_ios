//
//  Prefs.swift
//  Tracking
//
//  Created by anthonioez on 03/06/2019.
//  Copyright © 2019 anthonioez. All rights reserved.
//

import UIKit

class Prefs: NSObject
{
    static let KEY_ACTIVE   = "key_active";
    
    static public func getBool(_ key: String, defValue: Bool) -> Bool
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.bool(forKey: key);
        }
    }
    static public func setBool(_ key: String, value: Bool)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getString(_ key: String, defValue: String) -> String
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.string(forKey: key)!;
        }
    }
    
    static public func setString(_ key: String, value: String)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    //MARK:- Vars
    static var active: Bool
    {
        get
        {
            return getBool(KEY_ACTIVE, defValue: false);
        }
        set(value)
        {
            setBool(KEY_ACTIVE, value: value)
        }
    }
    }
