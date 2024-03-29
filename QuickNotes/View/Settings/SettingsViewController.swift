//
//  SettingsViewController.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 10.09.2023.
//

import UIKit
import Localize_Swift

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var lightDarkSwitch = UISwitch()
    var biometricSwitch = UISwitch()
    var languageButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 85, height: 20)
        button.setTitle("tab_settings_language_button".localized(), for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    let userDefaults = UserDefaults.standard
    let availableLanguages = Localize.availableLanguages(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "tab_settings".localized()
    }
    
    func setupViews() {
        
        handleDarkModeChange()
    
        if let userInterfaceStyle = UserDefaults.standard.value(forKey: "isDarkMode") as? Bool {
            lightDarkSwitch.isOn = userInterfaceStyle ? true : false
        }
        
        if let appLocking = UserDefaults.standard.value(forKey: "isLockedApp") as? Bool {
            biometricSwitch.isOn = appLocking ? true : false
        }

        languageButton.setTitle("\(Localize.currentLanguage().localized()) ↓", for: .normal)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        lightDarkSwitch.addTarget(self, action: #selector(lightDarkSwitchChanged), for: .valueChanged)
        biometricSwitch.addTarget(self, action: #selector(biometricSwitchChanged), for: .valueChanged)
        languageButton.addTarget(self, action: #selector(doChangeLanguage), for: .touchUpInside)
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
    
    @objc func doChangeLanguage() {
        let actionSheet = UIAlertController(title: nil, message: "alert_languages".localized(), preferredStyle: UIAlertController.Style.actionSheet)
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        actionSheet.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                Localize.setCurrentLanguage(language)
                UserDefaults.standard.set(Localize.currentLanguage(), forKey: "language")
                AppManager.shared.startAppWithNewWindow(index: self.tabBarController?.selectedIndex ?? 0)
            })
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "alert_cancel".localized(), style: UIAlertAction.Style.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                return 1
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "tab_settings_section_appearance".localized()
            case 1:
                return "tab_settings_section_security".localized()
            case 2:
                return "tab_settings_section_language".localized()
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "tab_settings_dark_mode".localized()
                    cell.accessoryView = lightDarkSwitch
                }
            case 1:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "tab_settings_lock_app".localized()
                    cell.accessoryView = biometricSwitch
                }
            case 2:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "tab_settings_language".localized()
                    cell.accessoryView = languageButton
                }
            default:
                break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            doChangeLanguage()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
