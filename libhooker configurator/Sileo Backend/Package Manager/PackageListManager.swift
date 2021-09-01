//
//  PackageListManager.swift
//  Anemone
//
//  Created by CoolStar on 6/23/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

class PackageListManager {
    static let shared = PackageListManager()
    
    func package(dictionary: [String: String]) -> Package {
        let package = Package()
        package.package = dictionary["package"]
        package.name = dictionary["name"]
        if package.name == nil {
            package.name = package.package
        }
        package.version = dictionary["version"]
        package.architecture = dictionary["architecture"]
        package.maintainer = dictionary["maintainer"]
        if package.maintainer != nil {
            if dictionary["author"] != nil {
                package.author = dictionary["author"]
            } else {
                package.author = dictionary["maintainer"]
            }
        }
        package.rawControl = dictionary
        return package
    }
    
    func dpkgDir() -> URL {
#if targetEnvironment(simulator)
        return Bundle.main.bundleURL.appendingPathComponent("Test Data")
#else
        return URL(fileURLWithPath: "/Library/dpkg")
#endif
    }
    
    func packagesList() -> [String: Package] {
        let packagesFile = self.dpkgDir().appendingPathComponent("status").resolvingSymlinksInPath()
        
        var packagesList = [String: Package]()
        
        do {
            let rawPackagesData = try Data(contentsOf: packagesFile)
            
            var index = 0
            var separator = "\n\n".data(using: .utf8)!
            
            guard let firstSeparator = rawPackagesData.range(of: "\n".data(using: .utf8)!, options: [], in: 0..<rawPackagesData.count) else {
                return packagesList
            }
            if firstSeparator.lowerBound != 0 {
                let subdata = rawPackagesData.subdata(in: firstSeparator.lowerBound-1..<firstSeparator.lowerBound)
                let character = subdata.first
                if character == 13 { // \r
                    // Found windows line endings
                    separator = "\r\n\r\n".data(using: .utf8)!
                }
            }
            
            var tempDictionary = [String: Any]()
            while index < rawPackagesData.count {
                let range = rawPackagesData.range(of: separator, options: [], in: index..<rawPackagesData.count)
                var newIndex = 0
                if range == nil {
                    newIndex = rawPackagesData.count
                } else {
                    newIndex = range!.lowerBound + separator.count
                }
                
                let subRange = index..<newIndex
                let packageData = rawPackagesData.subdata(in: subRange)
                
                index = newIndex
                
                guard let rawPackage = try? ControlFileParser.dictionary(controlData: packageData, isReleaseFile: false) else {
                    continue
                }
                guard let packageID = rawPackage["package"] else {
                    continue
                }
                if packageID.isEmpty {
                    continue
                }
                if packageID.hasPrefix("gsc.") {
                    continue
                }
                if packageID.hasPrefix("cy+") {
                    continue
                }
                
                let package = self.package(dictionary: rawPackage)
                var wantInfo: pkgwant = .install
                var eFlag: pkgeflag = .ok
                var pkgStatus: pkgstatus = .installed
                
                let statusValid = DpkgWrapper.getValues(statusField: package.rawControl["status"],
                                                        wantInfo: &wantInfo,
                                                        eFlag: &eFlag,
                                                        pkgStatus: &pkgStatus)
                if !statusValid {
                    continue
                }
                
                package.wantInfo = wantInfo
                package.eFlag = eFlag
                package.status = pkgStatus
                
                if package.eFlag == .ok {
                    if package.status == .notinstalled || package.status == .configfiles {
                        continue
                    }
                }
                
                packagesList[packageID] = package
            }
            tempDictionary.removeAll()
        } catch let error {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
        
        return packagesList
    }
}
