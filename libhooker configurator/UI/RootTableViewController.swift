//
//  RootTableViewController.swift
//  libhooker configurator
//
//  Created by Andromeda on 30/03/2021.
//  Copyright © 2021 coolstar. All rights reserved.
//

import UIKit

class RootTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String(localizationKey: "libhooker")
        navigationItem.largeTitleDisplayMode = .automatic
        let item = UIBarButtonItem(title: String(localizationKey: "Apply"), style: .done, target: self, action: #selector(showAlert(_:)))
        self.navigationItem.rightBarButtonItem = item
        
        DeviceInfo.shared.loadRemoteJailbreakData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }

    @objc private func showAlert(_ sender: Any) {
        let alert = UIAlertController(title: String(localizationKey: "Apply Changes"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: String(localizationKey: "Respring"), style: .default) { _ in respring() })
        alert.addAction(UIAlertAction(title: userspaceRebootSupported() ? String(localizationKey: "Reboot Userspace") : String(localizationKey: "ldRestart"),
                                      style: .destructive) { _ in userspaceReboot() })
        alert.addAction(UIAlertAction(title: String(localizationKey: "Cancel"), style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 5
        case 2: return 3
        default: fatalError("You fucked up")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.reusableCell(withStyle: .value1, reuseIdentifier: "ValueCell")
            cell.backgroundColor = ThemeManager.backgroundColour
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.textLabel?.text = String(localizationKey: "Version")
                cell.detailTextLabel?.text = DeviceInfo.shared.libhookerVersion()
                cell.detailTextLabel?.textColor = ThemeManager.labelColour
            } else if indexPath.row == 1 {
                cell.textLabel?.text = String(localizationKey: "Jailbreak")
                cell.detailTextLabel?.text = DeviceInfo.shared.getJailbreakName()
                cell.detailTextLabel?.textColor = ThemeManager.labelColour
            } else if indexPath.row == 2 {
                cell.textLabel?.text = String(localizationKey: "iOS")
                cell.detailTextLabel?.text = DeviceInfo.shared.iOSVersion()
                cell.detailTextLabel?.textColor = ThemeManager.labelColour
            }
            return cell
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = TweaksEnabledSwitch()
                cell.textLabel?.text = String(localizationKey: "Tweaks")
                cell.presentVC = self
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.accessoryType = .none
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            case 1:
                let cell = SettingsSwitchTableViewCell()
                cell.textLabel?.text = String(localizationKey: "Allow tweaks in webpages")
                cell.defaultKey = "webProcessTweaks"
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.accessoryType = .none
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            case 2:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Tweak Compatibility")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            case 3:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Default Configuration")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            case 4:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Reset Configuration")
                cell.accessoryType = .none
                cell.textLabel?.textColor = .systemRed
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            default: fatalError("You Fucked Up")
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "SpringBoard")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            case 1:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Applications")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            case 2:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Daemons")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = ThemeManager.labelColour
                cell.backgroundColor = ThemeManager.backgroundColour
                return cell
            default: fatalError("You Fucked Up")
            }
        }
        fatalError("You Fucked Up")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return ""
        case 1: return String(localizationKey: "Global Configuration")
        case 2: return String(localizationKey: "Process Configuration")
        default: fatalError("You fucked up")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 { return }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 2:
                if #available(iOS 13.0, *) {
                    let tweakCompatList = TweakCompatibilityList(style: .insetGrouped)
                    self.navigationController?.pushViewController(tweakCompatList, animated: true)
                } else {
                    let tweakCompatList = TweakCompatibilityList(style: .grouped)
                    self.navigationController?.pushViewController(tweakCompatList, animated: true)
                }
            case 3:
                let configVC: ConfigViewController
                if #available(iOS 13.0, *) {
                    configVC = ConfigViewController(style: .insetGrouped)
                } else {
                    configVC = ConfigViewController(style: .grouped)
                }
                configVC.launchService = LaunchService.empty
                self.navigationController?.pushViewController(configVC, animated: true)
            case 4:
                let alert = UIAlertController(title: String(localizationKey: "Reset Configuration"),
                                              message: String(localizationKey: "Tweak configurations for all processes will be reset"),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: String(localizationKey: "Yes"), style: .destructive) { _ in
                    LHUserDefaults.standard.set(nil, forKey: "tweakconfigs")
                    LHUserDefaults.standard.set(nil, forKey: "memPrefs")
                    LHUserDefaults.standard.synchronize()
                })
                alert.addAction(UIAlertAction(title: String(localizationKey: "No"), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            default: return
            }
            return
        }
        switch indexPath.row {
        case 0:
            let configVC: ConfigViewController
            if #available(iOS 13.0, *) {
                configVC = ConfigViewController(style: .insetGrouped)
            } else {
                configVC = ConfigViewController(style: .grouped)
            }
            configVC.launchService = LaunchService.SpringBoard
            self.navigationController?.pushViewController(configVC, animated: true)
        case 1:
            let launchListVC: LaunchServiceListView
            if #available(iOS 13.0, *) {
                launchListVC = LaunchServiceListView(style: .insetGrouped)
            } else {
                launchListVC = LaunchServiceListView(style: .grouped)
            }
            launchListVC.serviceFilter = .apps
            self.navigationController?.pushViewController(launchListVC, animated: true)
        case 2:
            let launchListVC: LaunchServiceListView
            if #available(iOS 13.0, *) {
                launchListVC = LaunchServiceListView(style: .insetGrouped)
            } else {
                launchListVC = LaunchServiceListView(style: .grouped)
            }
            launchListVC.serviceFilter = .daemons
            self.navigationController?.pushViewController(launchListVC, animated: true)
        default: return
        }
    }
}

class BaseTableViewController: UITableViewController {
    func reusableCell(withStyle style: UITableViewCell.CellStyle, reuseIdentifier: String) -> UITableViewCell {
        self.reusableCell(withStyle: style, reuseIdentifier: reuseIdentifier, cellClass: UITableViewCell.self)
    }

    func reusableCell(withStyle style: UITableViewCell.CellStyle, reuseIdentifier: String, cellClass: AnyClass) -> UITableViewCell {
        var cell: UITableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            let myClass = cellClass as? UITableViewCell.Type ?? UITableViewCell.self
            cell = myClass.init(style: style, reuseIdentifier: reuseIdentifier)
            cell?.selectionStyle = UITableViewCell.SelectionStyle.gray
        }
        cell?.backgroundColor = UIColor.clear
        return cell ?? UITableViewCell()
    }
}
