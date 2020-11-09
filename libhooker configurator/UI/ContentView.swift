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
    var body: some View {
        NavigationView {
            MasterView()
                .navigationBarTitle(Text("libhooker"))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MasterView: View {
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
    @State private var webprocessTweaks = true
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.3.0")
                }
                HStack {
                    Text("Jailbreak")
                    Spacer()
                    Text("Odyssey 1.1.2")
                }
                HStack {
                    Text("iOS")
                    Spacer()
                    Text(DeviceInfo.shared.iOSVersion())
                }
            }
            Section(header: Text("Global Configuration")) {
                Toggle(isOn: $tweaksEnabled) {
                    Text("Tweaks")
                }
                Toggle(isOn: $webprocessTweaks.onUpdate {
                    print("Webprocess update")
                }) {
                    Text("Allow tweaks in webpages")
                }
                NavigationLink(destination: TweakConfiguration(launchService: LaunchService.empty)) {
                    Text("Default Configuration")
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
        }.alert(isPresented: tweaksBinding()) {
            Alert(title: Text("Userspace Reboot Required"),
                  message: Text("A userspace reboot is required to apply changes"),
                  dismissButton: .default(Text("OK"), action: {
                print("Do userspace reboot")
            }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
