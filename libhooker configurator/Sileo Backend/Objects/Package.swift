//
//  Package.swift
//  Anemone
//
//  Created by CoolStar on 6/23/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

class Package {
    var package: String?
    var name: String?
    var version: String?
    var architecture: String?
    var author: String?
    var maintainer: String?
    var section: String?
    var rawControl: [String: String] = Dictionary()
    
    var wantInfo: pkgwant = .install
    var eFlag: pkgeflag = .ok
    var status: pkgstatus = .installed
}
