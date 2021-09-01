//
//  DpkgWrapper.swift
//  Anemone
//
//  Created by CoolStar on 6/23/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

enum pkgwant: Int {
    case unknown,
    install,
    hold,
    deinstall,
    purge,
    sentinel
}

enum pkgeflag: Int {
    case ok,
    reinstreq
}

enum pkgstatus: Int {
    case notinstalled,
    configfiles,
    halfinstalled,
    unpacked,
    halfconfigured,
    triggersawaited,
    triggerspending,
    installed
}

enum pkgpriority: Int {
    case required,
    important,
    standard,
    optional,
    extra,
    other,
    unknown,
    unset = -1
}

class DpkgWrapper {
    private static let priorityinfos: [String: pkgpriority] = ["required": .required,
                                                        "important": .important,
                                                        "standard": .standard,
                                                        "optional": .optional,
                                                        "extra": .extra,
                                                        "unknown": .unknown]
    private static let wantinfos: [String: pkgwant] = ["unknown": .unknown,
                                                "install": .install,
                                                "hold": .hold,
                                                "deinstall": .deinstall,
                                                "purge": .purge]
    private static let eflaginfos: [String: pkgeflag] = ["ok": .ok,
                                                  "reinstreq": .reinstreq]
    
    private static let statusinfos: [String: pkgstatus] = ["not-installed": .notinstalled,
                                                    "config-files": .configfiles,
                                                    "half-installed": .halfinstalled,
                                                    "unpackad": .unpacked,
                                                    "half-configured": .halfconfigured,
                                                    "triggers-awaited": .triggersawaited,
                                                    "triggers-pending": .triggerspending,
                                                    "installed": .installed]
    
    class func getValues(statusField: String?, wantInfo : inout pkgwant, eFlag : inout pkgeflag, pkgStatus : inout pkgstatus) -> Bool {
        guard let statusParts = statusField?.components(separatedBy: CharacterSet(charactersIn: " ")) else {
            return false
        }
        if statusParts.count < 3 {
            return false
        }
        wantInfo = .unknown
        
        for (name, wantValue) in wantinfos where name == statusParts[0] {
            wantInfo = wantValue
        }
        
        for (name, eflagValue) in eflaginfos where name == statusParts[1] {
            eFlag = eflagValue
        }
        
        for (name, statusValue) in statusinfos where name == statusParts[2] {
            pkgStatus = statusValue
        }
        return true
    }
}
