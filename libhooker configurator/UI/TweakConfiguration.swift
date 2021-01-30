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
    
    var humanReadableName: String {
        name.split(separator: ".").map(String.init).first ?? name
    }
}

struct TweakConfiguration: View {
    @State private var enableTweaks = true
    @State private var customConfig = false
    @State private var allowDeny = 1
    @State public var launchService: LaunchService
    
    @State private var tweaksList: [TweakConfig] = []
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $enableTweaks.onUpdate { self.save() }) {
                    Text(String(localizationKey: "Enable Tweaks"))
                }
            }
            if enableTweaks {
                Section {
                    Toggle(isOn: $customConfig.onUpdate { self.save() }) {
                        Text(String(localizationKey: "Override Configuration"))
                    }
                    if customConfig {
                        Picker(selection: $allowDeny.onUpdate { self.save() }, label: EmptyView()) {
                            Text(String(localizationKey: "Allow")).tag(0)
                            Text(String(localizationKey: "Deny")).tag(1)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                }
                if customConfig {
                    Section {
                        ForEach(tweaksList.indices) { idx in
                            Toggle(isOn: self.$tweaksList[idx].state.onUpdate { self.save() }) {
                                Text(self.tweaksList[idx].humanReadableName)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text(launchService.name), displayMode: .inline)
        .onAppear(perform: { self.fetch() })
    }
    
    private func getServiceData(configs: [String: Any]) -> [String: Any]? {
        if !launchService.bundle.isEmpty {
            if let bundles = configs["bundles"] as? [String: Any],
                let data = bundles[launchService.bundle] as? [String: Any] {
                return data
            }
        } else if !launchService.path.isEmpty {
            if let paths = configs["paths"] as? [String: Any],
                let data = paths[launchService.path] as? [String: Any] {
                return data
            }
        }
        return configs["default"] as? [String: Any]
    }
    
    private func setServiceData(configs: [String: Any], config: [String: Any]) -> [String: Any] {
        var newConfigs = configs
        if !launchService.bundle.isEmpty {
            var bundles = (configs["bundles"] as? [String: Any]) ?? [:]
            bundles[launchService.bundle] = config
            newConfigs["bundles"] = bundles
        } else if !launchService.path.isEmpty {
            var paths = (configs["paths"] as? [String: Any]) ?? [:]
            paths[launchService.path] = config
            newConfigs["paths"] = paths
        } else {
            newConfigs["default"] = config
        }
        return newConfigs
    }
    
    private func fetch() {
        #if targetEnvironment(simulator)
        let rawTweaksList = ["Test1.dylib", "Test2.dylib"]
        #else
        let rawTweaksList: [String] = (try? FileManager.default.contentsOfDirectory(atPath: "/usr/lib/TweakInject"))?.filter({ $0.hasSuffix(".dylib") }) ?? []
        #endif
        
        var tweaks: [String: Bool] = [:]
        for tweakName in rawTweaksList {
            tweaks[tweakName] = false
        }
        
        if let tweakConfigs = LHUserDefaults.standard.dictionary(forKey: "tweakconfigs"),
            let config = getServiceData(configs: tweakConfigs) {
            enableTweaks = (config["enableTweaks"] as? Bool) ?? true
            customConfig = (config["customConfig"] as? Bool) ?? false
            allowDeny = (config["allowDeny"] as? Int) ?? 1
            
            if let savedTweaks = config["tweakConfigs"] as? [String: Bool] {
                for (tweakName, tweakState) in savedTweaks where tweaks.keys.contains(tweakName) {
                    tweaks[tweakName] = tweakState
                }
            }
        }
        
        var tweakConfigs: [TweakConfig] = []
        for (tweakName, tweakState) in tweaks {
            tweakConfigs.append(TweakConfig(name: tweakName, state: tweakState))
        }
        tweakConfigs.sort(by: { $0.name.compare($1.name) == .orderedAscending })
        self.tweaksList = tweakConfigs
    }
    
    private func save() {
        var config: [String: Any] = [:]
        config["enableTweaks"] = enableTweaks
        config["customConfig"] = customConfig
        config["allowDeny"] = allowDeny
        
        var tweaks: [String: Bool] = [:]
        for tweakConfig in tweaksList {
            tweaks[tweakConfig.name] = tweakConfig.state
        }
        config["tweakConfigs"] = tweaks
        
        let tweakConfigs = LHUserDefaults.standard.dictionary(forKey: "tweakconfigs") ?? [:]
        let newTweakConfigs = setServiceData(configs: tweakConfigs, config: config)
        LHUserDefaults.standard.set(newTweakConfigs, forKey: "tweakconfigs")
        LHUserDefaults.standard.synchronize()
    }
}

struct TweakConfiguration_Previews: PreviewProvider {
    static var previews = TweakConfiguration(launchService: LaunchService(name: "", path: "", bundle: ""))
}
