//
//  ThemeManager.swift
//  libhooker configurator
//
//  Created by Andromeda on 30/03/2021.
//  Copyright © 2021 coolstar. All rights reserved.
//

import UIKit

class ThemeManager {
    
    static var labelColour: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    static var backgroundColour: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return .systemGray6
                } else {
                    return UIColor(red: 242.0, green: 242.0, blue: 247.0, alpha: 1.0)
                }
            })
        } else {
            return UIColor(red: 242.0, green: 242.0, blue: 247.0, alpha: 1.0)
        }
    }
}
