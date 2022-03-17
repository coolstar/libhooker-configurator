//
//  SettingsSwitchCell.swift
//  Sileo
//
//  Created by Amy on 16/03/2021.
//  Copyright © 2021 CoolStar. All rights reserved.
//
//  After all, why shouldn't I just copy this out of Sileo
import UIKit

class SettingsSwitchTableViewCell: UITableViewCell {
    
    public var control: UISwitch = UISwitch()

    var defaultKey: String? {
        didSet {
            if let key = defaultKey { control.isOn = LHUserDefaults.standard.bool(forKey: key) }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        control.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        control.addTarget(self, action: #selector(self.didChange(sender:)), for: .valueChanged)
    }
    
    @objc private func didChange(sender: UISwitch!) {
        if let key = defaultKey {
            LHUserDefaults.standard.set(sender.isOn, forKey: key)
            NotificationCenter.default.post(name: Notification.Name(key), object: nil)
            LHUserDefaults.standard.synchronize()
        }
    }
}

class TweaksEnabledSwitch: UITableViewCell {
    private var control: UISwitch = UISwitch()
    var presentVC: UIViewController?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        control.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        control.addTarget(self, action: #selector(self.didChange(sender:)), for: .valueChanged)
        control.isOn = !FileManager.default.fileExists(atPath: "/.disable_tweakinject")
    }
    
    @objc private func didChange(sender: UISwitch!) {
        if control.isOn {
            enableTweaks()
        } else {
            disableTweaks()
        }
        let title =  "\(userspaceRebootSupported() ? String(localizationKey: "Userspace Reboot") : String(localizationKey: "LDRestart"))" + " " + String(localizationKey: "Required")
        let message = "\(userspaceRebootSupported() ? String(localizationKey: "A userspace reboot") : String(localizationKey: "An ldrestart"))"
            + " " + String(localizationKey: "is required to apply changes")
        let applyNowTitle = userspaceRebootSupported() ? String(localizationKey: "Reboot Userspace") : String(localizationKey: "ldRestart")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localizationKey: "Later"), style: .cancel))
        alert.addAction(UIAlertAction(title: applyNowTitle, style: .destructive) { _ in
            userspaceReboot()
        })
        self.presentVC?.present(alert, animated: true, completion: nil)
    }
}

class ConfigSwitch: UITableViewCell {
    public var control: UISwitch = UISwitch()
    var saveFunc: ((_ state: Bool) -> Void)?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        control.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        control.addTarget(self, action: #selector(self.didChange(sender:)), for: .valueChanged)
    }
    
    @objc private func didChange(sender: UISwitch!) {
        guard let saveFunc = saveFunc else { return }
        saveFunc(sender.isOn)
    }
}

class SegmentedCell: UITableViewCell {
    public var segment: UISegmentedControl = UISegmentedControl()
    var keys = [String]() {
        didSet {
            segment.removeAllSegments()
            for key in keys {
                segment.insertSegment(withTitle: key, at: 0, animated: false)
            }
        }
    }
    var saveFunc: ((_ index: Int) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(segment)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        segment.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: 2.5).isActive = true
        segment.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 2.5).isActive = true
        segment.addTarget(self, action: #selector(self.didChange(sender:)), for: .valueChanged)
    }
    
    @objc private func didChange(sender: UISegmentedControl!) {
        guard let saveFunc = saveFunc else { return }
        saveFunc(sender.selectedSegmentIndex)
    }
}
