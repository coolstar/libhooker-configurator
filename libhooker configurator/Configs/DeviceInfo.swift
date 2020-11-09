//
//  DeviceInfo.swift
//  libhooker configurator
//
//  Created by CoolStar on 10/20/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import Foundation
import UIKit

public class DeviceInfo {
    static let shared = DeviceInfo()
    
    func iOSVersion() -> String {
        UIDevice.current.systemVersion
    }
}
