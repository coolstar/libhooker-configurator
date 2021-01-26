//
//  ContentView.swift
//  libhooker configurator
//
//  Created by CoolStar on 9/28/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var showApplySheet = false
    var body: some View {
        NavigationView {
            MainView()
                .navigationBarTitle(Text("libhooker"))
                .navigationBarItems(trailing: Button("Apply") {
                    self.showApplySheet = true
                }.popSheet(isPresented: $showApplySheet) {
                    PopSheet(title: Text("Apply Changes"), message: nil, buttons: [
                        .default(Text("Respring")) {
                            respring()
                        },
                        .destructive(Text(userspaceRebootSupported() ? "Reboot Userspace" : "ldRestart")) {
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
                    Text("Version")
                    Spacer()
                    Text(DeviceInfo.shared.libhookerVersion())
                }
                HStack {
                    Text("Jailbreak")
                    Spacer()
                    Text(jailbreakVersion)
                }
                HStack {
                    Text("iOS")
                    Spacer()
                    Text(DeviceInfo.shared.iOSVersion())
                }
            }
            Section(header: Text("Global Configuration")) {
                Toggle(isOn: $tweaksEnabled.onUpdate {
                    self.updateTweaksEnabled()
                }) {
                    Text("Tweaks")
                }.alert(isPresented: tweaksBinding()) {
                    Alert(title: Text("\(userspaceRebootSupported() ? "Userspace Reboot" : "LDRestart") Required"),
                          message: Text("\(userspaceRebootSupported() ? "A userspace reboot" : "An ldrestart") is required to apply changes"),
                          dismissButton: .default(Text("OK"), action: {
                            userspaceReboot()
                          }))
                }
                Toggle(isOn: $webProcessTweaks.onUpdate {
                    LHUserDefaults.standard.set(self.webProcessTweaks, forKey: "webProcessTweaks")
                    LHUserDefaults.standard.synchronize()
                }) {
                    Text("Allow tweaks in webpages")
                }
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.empty)) {
                    Text("Default Configuration")
                }
                Button(action: { self.showReset = true }) {
                    Text("Reset Configuration")
                }.foregroundColor(.red).alert(isPresented: $showReset) {
                    Alert(title: Text("Reset Configuration"),
                          message: Text("Tweak configurations for all processes will be reset"),
                          primaryButton: .default(Text("Yes"), action: {
                            LHUserDefaults.standard.set(nil, forKey: "tweakconfigs")
                            LHUserDefaults.standard.synchronize()
                          }),
                          secondaryButton: .cancel(Text("No")))
                }
            }
            Section(header: Text("Process Configuration")) {
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.SpringBoard)) {
                    Text("SpringBoard")
                }
                NavigationLink(destination: ServiceList(serviceFilter: .apps)) {
                    Text("Applications")
                }
                NavigationLink(destination: ServiceList(serviceFilter: .daemons)) {
                    Text("Daemons")
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
