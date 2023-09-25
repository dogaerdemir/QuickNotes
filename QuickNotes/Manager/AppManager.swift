//
//  AppManager.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 26.09.2023.
//

import Foundation
import UIKit

class AppManager {
    
    static let shared = AppManager()
    
    var window: UIWindow?
    
    private init() {}
    
    func startAppWithNewWindow(index: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()
        
        let firstStoryboard = UIStoryboard(name: "MainView", bundle: nil)
        let firstVC = firstStoryboard.instantiateInitialViewController()!
        let firstNav = UINavigationController(rootViewController: firstVC)
        firstNav.tabBarItem = UITabBarItem(title: "tab_notes".localized(), image: UIImage(systemName: "list.clipboard"), selectedImage: UIImage(systemName: "list.clipboard.fill"))
        
        let secondStoryboard = UIStoryboard(name: "SettingsView", bundle: nil)
        let secondVC = secondStoryboard.instantiateInitialViewController()!
        let secondNav = UINavigationController(rootViewController: secondVC)
        secondNav.tabBarItem = UITabBarItem(title: "tab_settings".localized(), image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        tabBarController.viewControllers = [firstNav, secondNav]
        
        tabBarController.selectedIndex = index
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
