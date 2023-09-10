//
//  SettingsViewController.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 10.09.2023.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var lightDarkSwitch = UISwitch()
    var biometricSwitch = UISwitch()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Settings"
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        self.tabBarController?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    
    func setupViews() {
        if let userInterfaceStyle = UserDefaults.standard.value(forKey: "isDarkMode") as? Bool {
            lightDarkSwitch.isOn = userInterfaceStyle ? true : false
        }
        
        if let appLocking = UserDefaults.standard.value(forKey: "isLockedApp") as? Bool {
            biometricSwitch.isOn = appLocking ? true : false
        }
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        lightDarkSwitch.addTarget(self, action: #selector(lightDarkSwitchChanged), for: .valueChanged)
        biometricSwitch.addTarget(self, action: #selector(biometricSwitchChanged), for: .valueChanged)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Dark Mode"
                cell.accessoryView = lightDarkSwitch
            case 1:
                cell.textLabel?.text = "Lock App"
                cell.accessoryView = biometricSwitch
            default:
                break
        }
        
        return cell
    }
    
    @objc func lightDarkSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        handleDarkModeChange()
    }
    
    @objc func biometricSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isLockedApp")
    }
    
    @objc func handleDarkModeChange() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        self.tabBarController?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}
