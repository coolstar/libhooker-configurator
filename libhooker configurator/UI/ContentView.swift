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
                .navigationBarTitle(Text(String(localizationKey: "libhooker")))
                .navigationBarItems(trailing: Button((String(localizationKey: "Apply"))) {
                    self.showApplySheet = true
                }.popSheet(isPresented: $showApplySheet) {
                    PopSheet(title: Text(String(localizationKey: "Apply Changes")), message: nil, buttons: [
                        .default(Text(String(localizationKey: "Respring"))) {
                            respring()
                        },
                        .destructive(Text(userspaceRebootSupported() ? String(localizationKey: "Reboot Userspace") : String(localizationKey: "ldRestart"))) {
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
                    Text(String(localizationKey: "Version"))
                    Spacer()
                    Text(DeviceInfo.shared.libhookerVersion())
                }
                HStack {
                    Text(String(localizationKey: "Jailbreak"))
                    Spacer()
                    Text(jailbreakVersion)
                }
                HStack {
                    Text(String(localizationKey: "iOS"))
                    Spacer()
                    Text(DeviceInfo.shared.iOSVersion())
                }
            }
            Section(header: Text(String(localizationKey: "Global Configuration"))) {
                Toggle(isOn: $tweaksEnabled.onUpdate {
                    self.updateTweaksEnabled()
                }) {
                    Text(String(localizationKey: "Tweaks"))
                }.alert(isPresented: tweaksBinding()) {
                    Alert(title: Text("\(userspaceRebootSupported() ? String(localizationKey: "Userspace Reboot") : String(localizationKey: "LDRestart")) " + String(localizationKey: "Required")),
                          message: Text("\(userspaceRebootSupported() ? String(localizationKey: "A userspace reboot") : String(localizationKey: "An ldrestart")) " + String(localizationKey: "is required to apply changes")),
                          dismissButton: .default(Text(String(localizationKey: "OK")), action: {
                            userspaceReboot()
                          }))
                }
                Toggle(isOn: $webProcessTweaks.onUpdate {
                    LHUserDefaults.standard.set(self.webProcessTweaks, forKey: "webProcessTweaks")
                    LHUserDefaults.standard.synchronize()
                }) {
                    Text(String(localizationKey: "Allow tweaks in webpages"))
                }
                NavigationLink(destination: TweakCompatibility()) {
                    Text(String(localizationKey: "Tweak Compatibility"))
                }
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.empty)) {
                    Text(String(localizationKey: "Default Configuration"))
                }
                Button(action: { self.showReset = true }, label: {
                    Text(String(localizationKey: "Reset Configuration"))
                }).foregroundColor(.red).alert(isPresented: $showReset) {
                    Alert(title: Text(String(localizationKey: "Reset Configuration")),
                          message: Text(String(localizationKey: "Tweak configurations for all processes will be reset")),
                          primaryButton: .default(Text(String(localizationKey: "Yes")), action: {
                            LHUserDefaults.standard.set(nil, forKey: "tweakconfigs")
                            LHUserDefaults.standard.set(nil, forKey: "memPrefs")
                            LHUserDefaults.standard.synchronize()
                          }),
                          secondaryButton: .cancel(Text(String(localizationKey: "No"))))
                }
            }
            Section(header: Text(String(localizationKey: "Process Configuration"))) {
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.SpringBoard)) {
                    Text(String(localizationKey: "SpringBoard"))
                }
                NavigationLink(destination: ServiceList(serviceFilter: .apps)) {
                    Text(String(localizationKey: "Applications"))
                }
                NavigationLink(destination: ServiceList(serviceFilter: .daemons)) {
                    Text(String(localizationKey: "Daemons"))
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
