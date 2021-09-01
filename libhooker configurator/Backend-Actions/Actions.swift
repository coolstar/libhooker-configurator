//
//  Actions.swift
//  libhooker configurator
//
//  Created by CoolStar on 1/26/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

import Foundation

func runCmd(path: String, args: [String]) -> Int32 {
    let argv: [UnsafeMutablePointer<CChar>?] = args.map { $0.withCString(strdup) }
    defer { for case let arg? in argv { free(arg) } }
    
    var pid = pid_t(0)
    var status = posix_spawn(&pid, path.cString(using: .utf8), nil, nil, argv + [nil], environ)
    if status == 0 {
        if waitpid(pid, &status, 0) == -1 {
            perror("waitpid")
        }
    } else {
        print("posix_spawn:", status)
    }
    return status
}

func userspaceRebootSupported() -> Bool {
    FileManager.default.fileExists(atPath: "/odyssey/jailbreakd.plist") ||
    FileManager.default.fileExists(atPath: "/taurine/jailbreakd.plist") ||
    FileManager.default.fileExists(atPath: "/chimera/jailbreakd.plist")
}

func enableTweaks() {
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "enableTweaks"])
}

func disableTweaks() {
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "disableTweaks"])
}

func respring() {
    _ = runCmd(path: "/usr/bin/sbreload", args: ["sbreload"])
}

func userspaceReboot() {
    guard userspaceRebootSupported() else {
        ldRestart()
        return
    }
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "userspaceReboot"])
}

func ldRestart() {
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "ldRestart"])
}
