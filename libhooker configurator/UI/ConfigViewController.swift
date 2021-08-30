//
//  ConfigViewController.swift
//  libhooker configurator
//
//  Created by Andromeda on 30/03/2021.
//  Copyright © 2021 coolstar. All rights reserved.
//

import UIKit

struct TweakConfig {
    let name: String
    var state: Bool
    
    var humanReadableName: String {
        name.split(separator: ".").map(String.init).first ?? name
    }
}

class ConfigViewController: UITableViewController {
    
    private var enableTweaks = true
    private var customConfig = false
    private var allowDeny = 1
    public var launchService: LaunchService?
    
    private var tweaksList: [TweakConfig] = []
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = launchService?.name
        navigationItem.largeTitleDisplayMode = .never
        self.fetch()
    }
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if !enableTweaks { return 1 }
        if !customConfig { return 2 }
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return customConfig ? 2 : 1
        case 2:
            return tweaksList.indices.count
        default: fatalError("You Fucked up")
        }
    }
    
    @objc private func enablePressed(sender: UISwitch!) {
        self.enableTweaks = sender.isOn
        self.save()
        self.tableView.reloadData()
    }
    
    @objc private func overrideConfigPressed(sender: UISwitch!) {
        self.customConfig = sender.isOn
        self.save()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = SettingsSwitchTableViewCell()
            cell.textLabel?.text = String(localizationKey: "Enable Tweaks")
            cell.textLabel?.textColor = ThemeManager.labelColour
            cell.accessoryType = .none
            cell.backgroundColor = ThemeManager.backgroundColour
            cell.control.isOn = enableTweaks
            cell.control.addTarget(self, action: #selector(self.enablePressed(sender:)), for: .valueChanged)
            return cell
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = SettingsSwitchTableViewCell()
                cell.textLabel?.text = String(localizationKey: "Override Configuration")
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.accessoryType = .none
                cell.backgroundColor = ThemeManager.backgroundColour
                cell.control.isOn = customConfig
                cell.control.addTarget(self, action: #selector(self.overrideConfigPressed(sender:)), for: .valueChanged)
                return cell
            case 1:
                let cell = SegmentedCell()
                cell.saveFunc = { index in
                    self.allowDeny = index
                    self.save()
                    self.tableView.reloadData()
                }
                cell.keys = [String(localizationKey: "Deny"), String(localizationKey: "Allow")]
                cell.segment.selectedSegmentIndex = allowDeny
                cell.accessoryType = .none
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            default: fatalError("You fucked up")
            }
        }
        let cell = ConfigSwitch()
        cell.saveFunc = { state in
            self.tweaksList[indexPath.row].state = state
            self.save()
            self.tableView.reloadData()
        }
        cell.textLabel?.text = tweaksList[indexPath.row].humanReadableName
        cell.control.isOn = tweaksList[indexPath.row].state
        cell.backgroundColor = ThemeManager.backgroundColour
        return cell
    }
    
    private func getServiceData(configs: [String: Any]) -> [String: Any]? {
        guard let launchService = launchService else { fatalError("Something is fucked") }
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
        guard let launchService = launchService else { fatalError("Something is fucked") }
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
        let rawTweaksList: [String] = (try? FileManager.default.contentsOfDirectory(atPath: "/usr/lib/TweakInject"))?
            .filter({ $0.hasSuffix(".dylib") }) ?? []
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
