//
//  DeviceInfo.swift
//  libhooker configurator
//
//  Created by CoolStar on 10/20/20.
//  Copyright © 2020 coolstar. All rights reserved.
//
import Foundation
import UIKit
import CommonCrypto

public class DeviceInfo {
    static let shared = DeviceInfo()
    
    func iOSVersion() -> String {
        UIDevice.current.systemVersion
    }
    
    var cachedData: [String: String] = [:]
    func getJailbreakVersion(sha1: String) -> String? {
        if cachedData.isEmpty {
            return "..."
        }
        return cachedData[sha1]
    }
    
    func loadRemoteJailbreakData(callback: @escaping () -> Void) {
        if !cachedData.isEmpty {
            return
        }
        guard let url = URL(string: "https://repo.theodyssey.dev/jbd-vers.plist") else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] {
                    self.cachedData = plist
                    callback()
                }
            }
        }.resume()
    }
    
    func getJailbreakName() -> String {
        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        guard !detectOdysseyRa1n() else {
            return "Odysseyra1n"
        }
        let odysseyJbd = "/odyssey/jailbreakd"
        let taurineJbd = "/taurine/jailbreakd"
        let chimeraJbd = "/chimera/jailbreakd"
        
        let jbdSHA1: String
        let jailbreakName: String
        if FileManager.default.fileExists(atPath: odysseyJbd) {
            jailbreakName = "Odyssey"
            jbdSHA1 = sha1File(url: URL(fileURLWithPath: odysseyJbd))
        } else if FileManager.default.fileExists(atPath: taurineJbd) {
            jailbreakName = "Taurine"
            jbdSHA1 = sha1File(url: URL(fileURLWithPath: taurineJbd))
        } else if FileManager.default.fileExists(atPath: chimeraJbd) {
            jailbreakName = "Chimera"
            jbdSHA1 = sha1File(url: URL(fileURLWithPath: chimeraJbd))
        } else {
            jailbreakName = "Unknown"
            jbdSHA1 = ""
        }
        if jailbreakName != "Unknown" {
            if let version = getJailbreakVersion(sha1: jbdSHA1) {
                return "\(jailbreakName) \(version)"
            }
        }
        return jailbreakName
        #endif
    }
    
    let packagesList = PackageListManager.shared.packagesList()
    func libhookerVersion() -> String {
        #if targetEnvironment(simulator)
        return "1.4.0"
        #else
        let libhookerPackage = packagesList["org.coolstar.libhooker"]
        return libhookerPackage?.version ?? "Unknown"
        #endif
    }
    
    private func detectOdysseyRa1n() -> Bool {
        isUnionMountPresent()
    }

    private func sha1File(url: URL) -> String {
        let bufferSize = 16 * 1024
        do {
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }
            
            var context = CC_SHA1_CTX()
            CC_SHA1_Init(&context)
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if !data.isEmpty {
                    data.withUnsafeBytes {
                        _ = CC_SHA1_Update(&context, $0.baseAddress, CC_LONG(data.count))
                    }
                    return true
                } else {
                    return false
                }
            }) {}
            
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            _ = CC_SHA1_Final(&digest, &context)
            
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            return ""
        }
    }
}
