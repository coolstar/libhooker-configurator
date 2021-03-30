//
//  RootTableViewController.swift
//  libhooker configurator
//
//  Created by Andromeda on 30/03/2021.
//  Copyright © 2021 coolstar. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String(localizationKey: "libhooker")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let item = UIBarButtonItem(title: String(localizationKey: "Apply"), style: .done, target: self, action: #selector(showAlert))
        self.navigationItem.rightBarButtonItem = item
    }

    // MARK: - Table view data source
    
    @objc private func showAlert() {
        let alert = UIAlertController(title: String(localizationKey: "Apply Changes"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: String(localizationKey: "Respring"), style: .default) { _ in respring() })
        alert.addAction(UIAlertAction(title: userspaceRebootSupported() ? String(localizationKey: "Reboot Userspace") : String(localizationKey: "ldRestart"),
                                      style: .destructive) { _ in userspaceReboot() })
        alert.addAction(UIAlertAction(title: String(localizationKey: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
            cell.backgroundColor = .systemGray6
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.textLabel?.text = String(localizationKey: "Version")
                cell.detailTextLabel?.text = DeviceInfo.shared.libhookerVersion()
            } else if indexPath.row == 1 {
                cell.textLabel?.text = String(localizationKey: "Jailbreak")
                cell.detailTextLabel?.text = DeviceInfo.shared.getJailbreakName()
            } else if indexPath.row == 2 {
                cell.textLabel?.text = String(localizationKey: "iOS")
                cell.detailTextLabel?.text = DeviceInfo.shared.iOSVersion()
            }
            return cell
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = TweaksEnabledSwitch()
                cell.textLabel?.text = String(localizationKey: "Tweaks")
                cell.presentVC = self
                cell.textLabel?.textColor = .label
                cell.accessoryType = .none
                cell.backgroundColor = .systemGray6
                return cell
            case 1:
                let cell = SettingsSwitchTableViewCell()
                cell.textLabel?.text = String(localizationKey: "Allow tweaks in webpages")
                cell.defaultKey = "webProcessTweaks"
                cell.textLabel?.textColor = .label
                cell.accessoryType = .none
                cell.backgroundColor = .systemGray6
                return cell
            case 2:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Tweak Compatibility")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = .label
                cell.backgroundColor = .systemGray6
                return cell
            case 3:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Default Compatibility")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = .label
                cell.backgroundColor = .systemGray6
                return cell
            case 4:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Reset Configuration")
                cell.accessoryType = .none
                cell.textLabel?.textColor = .systemRed
                cell.backgroundColor = .systemGray6
                return cell
            default: fatalError("You Fucked Up")
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "SpringBoard")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = .label
                cell.backgroundColor = .systemGray6
                return cell
            case 1:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Applications")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = .label
                cell.backgroundColor = .systemGray6
                return cell
            case 2:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = String(localizationKey: "Daemons")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = .label
                cell.backgroundColor = .systemGray6
                return cell
            default: fatalError("You Fucked Up")
            }
        }
        fatalError("You Fucked Up")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return ""
        case 1: return "Global Configuration"
        case 2: return "Process Configuration"
        default: fatalError("You fucked up")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RootTableViewController {
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
