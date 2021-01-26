//
//  LHUserDefaults.swift
//  libhooker configurator
//
//  Created by CoolStar on 1/26/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

import Foundation
import os

class LHUserDefaults {
    static let standard = LHUserDefaults()
    
    #if targetEnvironment(simulator)
    let userDefaults = UserDefaults.standard
    #endif
    var plist: [String: Any] = [:]
    var plistLoaded = false
    
    init() {
        _ = self.synchronize()
    }
    
    func register(defaults: [String: Any]) {
        #if targetEnvironment(simulator)
        userDefaults.register(defaults: defaults)
        #else
        for (key, value) in defaults {
            if !plist.keys.contains(key) {
                plist[key] = value
            }
        }
        #endif
    }
    
    func bool(forKey: String) -> Bool {
        #if targetEnvironment(simulator)
        return userDefaults.bool(forKey: forKey)
        #else
        return (plist[forKey] as? Bool) ?? false
        #endif
    }
    
    func dictionary(forKey: String) -> [String: Any]? {
        #if targetEnvironment(simulator)
        return userDefaults.dictionary(forKey: forKey)
        #else
        return plist[forKey] as? [String: Any]
        #endif
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        #if targetEnvironment(simulator)
        userDefaults.set(value, forKey: defaultName)
        #else
        if let val = value {
            plist[defaultName] = val
        } else {
            plist.removeValue(forKey: defaultName)
        }
        #endif
    }
    
    func set(_ value: Bool, forKey defaultName: String) {
        #if targetEnvironment(simulator)
        userDefaults.set(value, forKey: defaultName)
        #else
        plist[defaultName] = value
        #endif
    }
    
    @discardableResult func synchronize() -> Bool {
        #if targetEnvironment(simulator)
        return userDefaults.synchronize()
        #else
        var success = true
        let url = URL(fileURLWithPath: "/var/mobile/Library/Preferences/\(Bundle.main.bundleIdentifier ?? "").plist")
        if plistLoaded {
            if let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0) {
                try? data.write(to: url)
            } else {
                success = false
            }
        }
        if let data = try? Data(contentsOf: url),
            let plist = (try? PropertyListSerialization.propertyList(from: data,
                                                                     options: .mutableContainersAndLeaves,
                                                                     format: nil)) as? [String: Any] {
            self.plist = plist
            plistLoaded = true
        } else {
            self.plist = [:]
            plistLoaded = true
        }
        return success
        #endif
    }
}
