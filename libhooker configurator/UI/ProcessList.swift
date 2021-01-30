//
//  ServiceList.swift
//  libhooker configurator
//
//  Created by CoolStar on 10/1/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import SwiftUI

enum LaunchServiceFilter {
    case apps
    case daemons
}

struct LaunchService: Hashable {
    let name: String
    let path: String
    let bundle: String
    
    static let SpringBoard = LaunchService(name: "SpringBoard",
                                           path: "/System/Library/CoreServices/SpringBoard.app/SpringBoard",
                                           bundle: "")
    static let empty = LaunchService(name: "Default Configuration",
                                     path: "",
                                     bundle: "")
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(bundle)
    }
}

struct ServiceList: View {
    @State public var serviceFilter: LaunchServiceFilter
    
    @State public var services: [LaunchService] = []
    
    private var navTitle: String {
        switch serviceFilter {
        case .apps:
            return "Applications"
        case .daemons:
            return "Daemons"
        }
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(services, id: \.self) { service in
                    NavigationLink(destination: TweakConfiguration(launchService: service)) {
                        Text(service.name)
                    }
                }
            }
        }
        .onAppear(perform: fetch)
        .navigationBarTitle(Text(navTitle), displayMode: .inline)
    }
    
    private func appHidden(app: LSApplicationProxy) -> Bool {
        if app.localizedName() == nil {
            return true
        }
        if app.lhIdentifier() == nil {
            return true
        }
        guard let bundleURL = app.bundleURL(),
            let plistData = try? Data(contentsOf: bundleURL.appendingPathComponent("Info.plist")),
            let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] else {
                return true
        }
        if let tags = plist["SBAppTags"] as? [String],
            tags.contains("hidden") {
            return true
        }
        if let visibility = plist["SBIconVisibilityDefaultVisible"] as? Bool,
            !visibility {
            return true
        }
        return false
    }
    
    private func fetch() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.serviceFilter == .apps {
                let apps = LSApplicationWorkspace.default().allInstalledApplications()
                let services = apps.filter({ !self.appHidden(app: $0) }).map({
                    LaunchService(name: $0.localizedName() ?? "",
                                  path: "",
                                  bundle: $0.lhIdentifier() ?? "")
                }).sorted(by: { $0.name.compare($1.name) == .orderedAscending })
                DispatchQueue.main.async {
                    self.services = services
                }

            } else {
                let servicesList = launchdList()
                let services = servicesList.map({ LaunchService(name: $0[0], path: $0[1], bundle: "") })
                    .sorted(by: { $0.name.compare($1.name) == .orderedAscending })
                DispatchQueue.main.async {
                    self.services = services
                }
            }
        }
    }
}
