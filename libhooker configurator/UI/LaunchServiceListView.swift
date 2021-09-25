//
//  LaunchServiceListView.swift
//  libhooker configurator
//
//  Created by Andromeda on 30/03/2021.
//  Copyright © 2021 coolstar. All rights reserved.
//

import UIKit

enum LaunchServiceFilter {
    case apps
    case daemons
}

struct LaunchService: Hashable {
    let name: String
    let path: String
    let bundle: String
    
    static let SpringBoard = LaunchService(name: String(localizationKey: "SpringBoard"),
                                           path: "/System/Library/CoreServices/SpringBoard.app/SpringBoard",
                                           bundle: "")
    static let empty = LaunchService(name: String(localizationKey: "Default Configuration"),
                                     path: "",
                                     bundle: "")
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(bundle)
    }
}

class LaunchServiceListView: BaseTableViewController {
    
    public var serviceFilter: LaunchServiceFilter?
    public var services: [LaunchService] = [] {
        didSet {
            visibleServices = services
        }
    }
    public var visibleServices: [LaunchService] = [] {
        didSet {
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }
    
    private var navTitle: String {
        switch serviceFilter {
        case .apps:
            return String(localizationKey: "Applications")
        case .daemons:
            return String(localizationKey: "Daemons")
        default: fatalError("You Fucked Up")
        }
    }
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = navTitle
        navigationItem.largeTitleDisplayMode = .never
        self.fetch()
        
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        self.searchController.searchBar.placeholder = "Search"
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleServices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = visibleServices[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = ThemeManager.labelColour
        cell.backgroundColor = ThemeManager.backgroundColour
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let configVC: ConfigViewController
        if #available(iOS 13.0, *) {
            configVC = ConfigViewController(style: .insetGrouped)
        } else {
            configVC = ConfigViewController(style: .grouped)
        }
        configVC.launchService = visibleServices[indexPath.row]
        self.navigationController?.pushViewController(configVC, animated: true)
    }

    private func appHidden(app: LSApplicationProxy) -> Bool {
        if app.localizedName() == nil {
            return true
        }
        if app.lhIdentifier() == nil {
            return true
        }
        guard let bundleURL = app.bundleURL(),
            let plistData = try? Data(contentsOf: bundleURL.appendingPathComponent("Info.plist")),
            let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] else {
                return true
        }
        if let tags = plist["SBAppTags"] as? [String],
            tags.contains("hidden") {
            return true
        }
        if let visibility = plist["SBIconVisibilityDefaultVisible"] as? Bool,
            !visibility {
            return true
        }
        return false
    }
    
    private func fetch() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.serviceFilter == .apps {
                let apps = LSApplicationWorkspace.default().allInstalledApplications()
                let services = apps.filter({ !self.appHidden(app: $0) }).map({
                    LaunchService(name: $0.localizedName() ?? "",
                                  path: "",
                                  bundle: $0.lhIdentifier() ?? "")
                }).sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                DispatchQueue.main.async {
                    self.services = services
                }

            } else {
                let servicesList = launchdList()
                let services = servicesList.map({ LaunchService(name: $0[0], path: $0[1], bundle: "") })
                    .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                DispatchQueue.main.async {
                    self.services = services
                }
            }
        }
    }
}

extension LaunchServiceListView: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard var text = searchController.searchBar.text,
              !text.isEmpty else {
            visibleServices = services
            return
        }
        text = text.lowercased()
        visibleServices = services.filter { $0.name.lowercased().contains(text) }
    }
}
