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
                    return .white
                }
            })
        } else {
            return .white
        }
    }
}
