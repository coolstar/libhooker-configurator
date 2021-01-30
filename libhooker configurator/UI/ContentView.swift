//
//  ContentView.swift
//  libhooker configurator
//
//  Created by CoolStar on 9/28/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import SwiftUI
import Combine
//NSLocalizedString("Respring", comment: "")
struct ContentView: View {
    @State var showApplySheet = false
    var body: some View {
        NavigationView {
            MainView()
                .navigationBarTitle(Text(NSLocalizedString("libhooker", comment: "")))
                .navigationBarItems(trailing: Button((NSLocalizedString("Apply", comment: ""))) {
                    self.showApplySheet = true
                }.popSheet(isPresented: $showApplySheet) {
                    PopSheet(title: Text(NSLocalizedString("Apply Changes", comment: "")), message: nil, buttons: [
                        .default(Text(NSLocalizedString("Respring", comment: ""))) {
                            respring()
                        },
                        .destructive(Text(userspaceRebootSupported() ? NSLocalizedString("Reboot Userspace", comment: "") : NSLocalizedString("ldRestart", comment: ""))) {
                            userspaceReboot()
                        },
                        .cancel()
                    ])
                })
                
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView: View {
    @State private var tweaksEnabled = !FileManager.default.fileExists(atPath: "/.disable_tweakinject")
    private var tweaksEnabled2 = !FileManager.default.fileExists(atPath: "/.disable_tweakinject")
    
    func tweaksBinding() -> Binding<Bool> {
        Binding<Bool>(
            get: {
                self.tweaksEnabled != self.tweaksEnabled2
            },
            set: { _ in
                
            }
        )
    }
    
    @State private var jailbreakVersion = DeviceInfo.shared.getJailbreakName()
    @State private var showReset = false
    @State private var webProcessTweaks = LHUserDefaults.standard.bool(forKey: "webProcessTweaks")
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text(NSLocalizedString("Version", comment: ""))
                    Spacer()
                    Text(DeviceInfo.shared.libhookerVersion())
                }
                HStack {
                    Text(NSLocalizedString("Jailbreak", comment: ""))
                    Spacer()
                    Text(jailbreakVersion)
                }
                HStack {
                    Text(NSLocalizedString("iOS", comment: ""))
                    Spacer()
                    Text(DeviceInfo.shared.iOSVersion())
                }
            }
            Section(header: Text(NSLocalizedString("Global Configuration", comment: ""))) {
                Toggle(isOn: $tweaksEnabled.onUpdate {
                    self.updateTweaksEnabled()
                }) {
                    Text(NSLocalizedString("Tweaks", comment: ""))
                }.alert(isPresented: tweaksBinding()) {
                    Alert(title: Text("\(userspaceRebootSupported() ? NSLocalizedString("Userspace Reboot", comment: "") : NSLocalizedString("LDRestart", comment: ""))" + NSLocalizedString("Required", comment: "")),
                          message: Text("\(userspaceRebootSupported() ? NSLocalizedString("A userspace reboot", comment: "") : NSLocalizedString("An ldrestart", comment: ""))" + NSLocalizedString("is required to apply changes", comment: "")),
                          dismissButton: .default(Text(NSLocalizedString("OK", comment: "")), action: {
                            userspaceReboot()
                          }))
                }
                Toggle(isOn: $webProcessTweaks.onUpdate {
                    LHUserDefaults.standard.set(self.webProcessTweaks, forKey: "webProcessTweaks")
                    LHUserDefaults.standard.synchronize()
                }) {
                    Text(NSLocalizedString("Allow tweaks in webpages", comment: ""))
                }
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.empty)) {
                    Text(NSLocalizedString("Default Configuration", comment: ""))
                }
                Button(action: { self.showReset = true }) {
                    Text(NSLocalizedString("Reset Configuration", comment: ""))
                }.foregroundColor(.red).alert(isPresented: $showReset) {
                    Alert(title: Text(NSLocalizedString("Reset Configuration", comment: "")),
                          message: Text(NSLocalizedString("Tweak configurations for all processes will be reset", comment: "")),
                          primaryButton: .default(Text(NSLocalizedString("Yes", comment: "")), action: {
                            LHUserDefaults.standard.set(nil, forKey: "tweakconfigs")
                            LHUserDefaults.standard.synchronize()
                          }),
                          secondaryButton: .cancel(Text(NSLocalizedString("No", comment: ""))))
                }
            }
            Section(header: Text(NSLocalizedString("Process Configuration", comment: ""))) {
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.SpringBoard)) {
                    Text(NSLocalizedString("SpringBoard", comment: ""))
                }
                NavigationLink(destination: ServiceList(serviceFilter: .apps)) {
                    Text(NSLocalizedString("Applications", comment: ""))
                }
                NavigationLink(destination: ServiceList(serviceFilter: .daemons)) {
                    Text(NSLocalizedString("Daemons", comment: ""))
                }
            }
        }.onAppear(perform: {
            DeviceInfo.shared.loadRemoteJailbreakData {
                self.jailbreakVersion = DeviceInfo.shared.getJailbreakName()            
            }
        })
    }
    
    func updateTweaksEnabled() {
        if tweaksEnabled {
            enableTweaks()
        } else {
            disableTweaks()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
