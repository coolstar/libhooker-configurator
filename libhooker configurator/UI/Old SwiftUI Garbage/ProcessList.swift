//
//  ServiceList.swift
//  libhooker configurator
//
//  Created by CoolStar on 10/1/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import SwiftUI


struct ServiceList: View {
    @State public var serviceFilter: LaunchServiceFilter
    
    @State public var services: [LaunchService] = []
    
    
    
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
