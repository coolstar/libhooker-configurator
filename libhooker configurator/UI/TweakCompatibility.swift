//
//  TweakCompatibility.swift
//  libhooker configurator
//
//  Created by CoolStar on 1/30/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

import SwiftUI

enum CompatibilityMode: Int, CaseIterable {
    case libhooker = 0
    case substrate = 1
}

struct TweakCompatibilityConfig {
    let name: String
    var state: CompatibilityMode
    
    var humanReadableName: String {
        name.split(separator: ".").map(String.init).first ?? name
    }
}

struct TweakCompatibilitySelection: View {
    @Binding var config: TweakCompatibilityConfig
    var tweakName: String
    var saveFunc: () -> Void
    
    static var names = [
        String(localizationKey: "libhooker Default"),
        String(localizationKey: "Substrate Compatibility")
    ]
    
    var body: some View {
        Form {
            Section(header: Text(String(localizationKey: "Compatibility Mode")),
                    footer: Text(String(localizationKey: "Enabling substrate compatibility may allow some poorly written / outdated tweaks to work. However, this will increase memory usage."))) {
                ForEach(0 ..< CompatibilityMode.allCases.count, id: \.self) { idx in
                    HStack {
                        Button(action: {
                            self.config.state = CompatibilityMode.allCases[idx]
                            self.saveFunc()
                        }, label: {
                            Text(TweakCompatibilitySelection.names[idx])
                        }).foregroundColor(.primary)
                        Spacer()
                        if self.config.state == CompatibilityMode.allCases[idx] {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationBarTitle(tweakName)
    }
}

struct TweakCompatibility: View {
    @State var tweaksList: [TweakCompatibilityConfig] = fetch()
    var names = TweakCompatibilitySelection.names
    
    var body: some View {
        Form {
            Section {
                ForEach(tweaksList.indices) { idx in
                    NavigationLink(destination: TweakCompatibilitySelection(config: self.$tweaksList[idx],
                                                                            tweakName: self.tweaksList[idx].humanReadableName) {
                                                                                self.save()
                    }) {
                        HStack {
                            Text(self.tweaksList[idx].humanReadableName)
                            Spacer()
                            Text(self.names[self.tweaksList[idx].state.rawValue])
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }.onAppear {
            self.tweaksList = TweakCompatibility.fetch()
        }
        .navigationBarTitle(Text(String(localizationKey: "Tweak Compatibility")), displayMode: .inline)
    }
    
    private func save() {
        var config: [String: Bool] = [:]
        for tweakConfig in tweaksList where tweakConfig.state == .substrate {
            config[tweakConfig.name] = false
        }
        LHUserDefaults.standard.set(config, forKey: "memPrefs")
        LHUserDefaults.standard.synchronize()
    }
    
    static func fetch() -> [TweakCompatibilityConfig] {
        #if targetEnvironment(simulator)
        let rawTweaksList = ["Test1.dylib", "Test2.dylib"]
        #else
        let rawTweaksList: [String] = (try? FileManager.default.contentsOfDirectory(atPath: "/usr/lib/TweakInject"))?.filter({ $0.hasSuffix(".dylib") }) ?? []
        #endif
        
        var tweaks: [String: Bool] = [:]
        for tweakName in rawTweaksList {
            tweaks[tweakName] = true
        }
        
        if let tweakConfigs = LHUserDefaults.standard.dictionary(forKey: "memPrefs") as? [String: Bool] {
            for (tweakName, tweakState) in tweakConfigs where tweaks.keys.contains(tweakName) {
                tweaks[tweakName] = tweakState
            }
        }
        
        var tweakConfigs: [TweakCompatibilityConfig] = []
        for (tweakName, tweakState) in tweaks {
            tweakConfigs.append(TweakCompatibilityConfig(name: tweakName, state: tweakState ? .libhooker : .substrate))
        }
        tweakConfigs.sort(by: { $0.name.compare($1.name) == .orderedAscending })
        return tweakConfigs
    }
}

struct TweakCompatibility_Previews: PreviewProvider {
    static var previews = TweakCompatibility()
}
