//
//  String+LocalizedHelpers.swift
//  Sileo
//
//  Created by Jamie Bishop on 30/07/2019.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

enum LocalizedStringType {
    case general
    
    /// The table name this string type can be found in.
    var tableName: String? {
        switch self {
        case .general: return nil
        }
    }
}

extension String {
    /// Creates a localized string from the provided key.
    init(localizationKey: String, type: LocalizedStringType = .general) {
        self = NSLocalizedString(localizationKey, tableName: type.tableName, comment: "")
    }
}
