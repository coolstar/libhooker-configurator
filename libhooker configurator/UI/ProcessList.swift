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
                                           path: "",
                                           bundle: "com.apple.SpringBoard")
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
    
    private func fetch() {
        self.services = [
            LaunchService.SpringBoard,
            LaunchService(name: "Safari", path: "", bundle: "com.apple.MobileSafari")
        ]
    }
}
