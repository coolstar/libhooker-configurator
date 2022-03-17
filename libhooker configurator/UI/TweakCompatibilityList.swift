//
//  TweakCompatibilityList.swift
//  libhooker configurator
//
//  Created by Andromeda on 30/03/2021.
//  Copyright © 2021 coolstar. All rights reserved.
//

import UIKit

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

class TweakCompatibilityList: BaseTableViewController {
    
    var tweaksList = fetch() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var names = CompatibilitySelectView.names
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String(localizationKey: "Tweak Compatibility")
        navigationItem.largeTitleDisplayMode = .never
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tweaksList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reusableCell(withStyle: .value1, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = tweaksList[indexPath.row].humanReadableName
        cell.detailTextLabel?.text = self.names[tweaksList[indexPath.row].state.rawValue]
        cell.detailTextLabel?.textColor = .systemBlue
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = ThemeManager.labelColour
        cell.backgroundColor = ThemeManager.backgroundColour
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let csv: CompatibilitySelectView
        if #available(iOS 13, *) {
            csv = CompatibilitySelectView(style: .insetGrouped)
        } else {
            csv = CompatibilitySelectView(style: .grouped)
        }
        csv.config = self.tweaksList[indexPath.row]
        csv.tweakName = self.tweaksList[indexPath.row].humanReadableName
        csv.saveFunc = { config in
            self.tweaksList[indexPath.row] = config
            self.save()
        }
        self.navigationController?.pushViewController(csv, animated: true)
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

class CompatibilitySelectView: BaseTableViewController {
    var config: TweakCompatibilityConfig?
    var tweakName: String? {
        didSet {
            self.title = tweakName
        }
    }
    var saveFunc: ((_ config: TweakCompatibilityConfig) -> Void)?
    
    static var names = [
        String(localizationKey: "libhooker Default"),
        String(localizationKey: "Substrate Compatibility")
    ]
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CompatibilityMode.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = CompatibilitySelectView.names[indexPath.row]
        if self.config?.state == CompatibilityMode.allCases[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.textColor = ThemeManager.labelColour
        cell.backgroundColor = ThemeManager.backgroundColour
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard var config = config,
              let saveFunc = saveFunc else { return }
        config.state = CompatibilityMode.allCases[indexPath.row]
        self.config = config
        self.tableView.reloadData()
        saveFunc(config)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        String(localizationKey: "Compatibility Mode")
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        String(localizationKey: "Enabling substrate compatibility may allow some poorly written / outdated tweaks to work. However, this will increase memory usage.")
    }
}
