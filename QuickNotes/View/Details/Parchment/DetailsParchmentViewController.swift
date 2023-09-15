//
//  DetailsParchmentViewController.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 15.09.2023.
//

import UIKit

import UIKit
import Parchment

class DetailsParchmentViewController: UIViewController {
    
    let vcs: [UIViewController] = [
        UIStoryboard(name: "DetailsNoteView", bundle: nil).instantiateViewController(withIdentifier: "detailsNoteView") as! DetailsNoteViewController,
        UIStoryboard(name: "DetailsMapView", bundle: nil).instantiateViewController(withIdentifier: "detailsMapView") as! DetailsMapViewController
    ]
    
    var currentDarkModeStatus: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Detay"
        
        let newDarkModeStatus = UserDefaults.standard.bool(forKey: "isDarkMode")
        if currentDarkModeStatus != newDarkModeStatus {
            setPagingControllers() // Triggers only if there is a change in dark mode status, so acts like a viewDidLoad practically
            currentDarkModeStatus = newDarkModeStatus
        }
    }
    
    private func getPagingOptions() -> PagingOptions {
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        var options = PagingOptions()
        options.backgroundColor = isDarkMode ? .black : .white
        options.selectedBackgroundColor = isDarkMode ? .black : .white
        options.selectedScrollPosition = .preferCentered
        options.selectedFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        options.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        options.selectedTextColor = UIColor.purple
        options.textColor = UIColor.lightGray
        options.indicatorColor = UIColor.purple
        options.indicatorOptions = .visible(height: 2, zIndex: 0, spacing: UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 2), insets: .zero)
        options.contentInteraction = .scrolling
        options.borderColor = .darkGray
        options.borderOptions = .visible(height: 0.8, zIndex: 0, insets: .zero)
        options.menuItemSize = .sizeToFit(minWidth: self.view.frame.size.width, height: 150)
        
        return options
    }
    
    private func setPagingControllers() {
        
        let pagingViewController = PagingViewController(options: getPagingOptions(),viewControllers: vcs)
        pagingViewController.menuItemSize = .sizeToFit(minWidth: self.view.frame.width / 4, height: 45)
        pagingViewController.menuItemLabelSpacing = 5
        pagingViewController.collectionView.backgroundColor = .clear
        pagingViewController.collectionView.isScrollEnabled = false
        pagingViewController.collectionView.layer.cornerRadius = 0
        pagingViewController.dataSource = self
        
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagingViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pagingViewController.didMove(toParent: self)
    }
    
    func updateChildViewControllers(withNote note: Note?, delegate: NoteDelegate) {
        if let detailsNoteVC = vcs[0] as? DetailsNoteViewController {
            detailsNoteVC.chosenNote = note
            detailsNoteVC.delegate = delegate
        }
    }
}

extension DetailsParchmentViewController: PagingViewControllerDataSource {
    func numberOfViewControllers(in pagingViewController: Parchment.PagingViewController) -> Int {
        return vcs.count
    }
    
    func pagingViewController(_: Parchment.PagingViewController, viewControllerAt index: Int) -> UIViewController {
        let vc = vcs[index]
        return vc
    }
    
    func pagingViewController(_: Parchment.PagingViewController, pagingItemAt index: Int) -> Parchment.PagingItem {
        let titles = ["Note", "Location",]
        return PagingIndexItem(index: index, title: titles[index])
    }
}
