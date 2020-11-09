//
//  TweakConfiguration.swift
//  libhooker configurator
//
//  Created by CoolStar on 9/30/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import SwiftUI

struct TweakConfig {
    let name: String
    var state: Bool
}

struct TweakConfiguration: View {
    @State private var enableTweaks = true
    @State private var customConfig = false
    @State private var allowDeny = 1
    @State public var launchService: LaunchService
    
    @State private var tweaksList = [
        TweakConfig(name: "Test", state: false),
        TweakConfig(name: "Test2", state: false)
    ]
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $enableTweaks) {
                    Text("Enable Tweaks")
                }
            }
            if enableTweaks {
                Section {
                    Toggle(isOn: $customConfig) {
                        Text("Override Configuration")
                    }
                    if customConfig {
                        Picker(selection: $allowDeny, label: EmptyView()) {
                            Text("Allow").tag(0)
                            Text("Deny").tag(1)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                }
                if customConfig {
                    Section {
                        ForEach(tweaksList.indices) { idx in
                            Toggle(isOn: self.$tweaksList[idx].state) {
                                Text(self.tweaksList[idx].name)
                            }
                        }
                    }
                }
            }
        }.navigationBarTitle(Text(launchService.name), displayMode: .inline)
    }
}
