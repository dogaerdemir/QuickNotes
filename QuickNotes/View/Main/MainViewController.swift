import UIKit
import CoreData
import LocalAuthentication
import UserNotifications
import DropDown
import Localize_Swift

protocol NoteDelegate: AnyObject {
    func didAddNote()
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    var selectAllButton: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    lazy var dropDown : DropDown = {
        let menu = DropDown()
        let sortTypes = ["tab_notes_sortby".localized(), "tab_notes_sort_alph_az".localized(), "tab_notes_sort_alph_za".localized(), "tab_notes_sort_create_old".localized(), "tab_notes_sort_create_new".localized(), "tab_notes_sort_edit_old".localized(), "tab_notes_sort_edit_new".localized()]
        menu.dataSource = sortTypes
        
        menu.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            if index == 0 {
                cell.isUserInteractionEnabled = false
                cell.optionLabel!.font = UIFont.boldSystemFont(ofSize: 16)
                cell.optionLabel!.textAlignment = .center
                
            } else {
                cell.isUserInteractionEnabled = true
                cell.optionLabel!.textAlignment = .left
            }
        }
        
        menu.cellConfiguration = { [weak self] (index, item) in
            if index == 0 {
                return item
            } else if let selectedSort = self?.currentSortMethod, item == selectedSort {
                return "\(item) ✅"
            } else {
                return item
            }
        }
        
        menu.width = 225
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if isDarkMode {
            menu.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
            menu.textColor = .white
        } else {
            menu.backgroundColor = .white
            menu.textColor = .black
        }
        
        return menu
    }()
    
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    var selectedNote: Note?
    
    var currentSortMethod: String?
    var currentDarkModeStatus: Bool?
    
    let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "tab_notes".localized()
        
        let newDarkModeStatus = UserDefaults.standard.bool(forKey: "isDarkMode")
        if currentDarkModeStatus != newDarkModeStatus {
            handleDarkModeChange() // Triggers only if there is a change in dark mode status
            currentDarkModeStatus = newDarkModeStatus
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        //self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }*/
    
    func setupViews() {
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainTableViewCell")
        tableView.allowsMultipleSelectionDuringEditing = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
        
        currentSortMethod = UserDefaults.standard.string(forKey: "currentSortMethod")
        
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(showDropDown))
        self.navigationItem.rightBarButtonItem = sortButton
        
        addButton.layer.cornerRadius = 25
        
        dropDown.direction = .bottom
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            if index == 0 {
                return
            }
            UserDefaults.standard.set(item, forKey: "currentSortMethod")
            UserDefaults.standard.synchronize()
            
            self?.currentSortMethod = item
            self?.sortNotes(by: item)
            self?.dropDown.reloadAllComponents()
        }
        
        dropDown.anchorView = sortButton
        
        if let appLocking = UserDefaults.standard.value(forKey: "isLockedApp") as? Bool {
            if appLocking {
                authenticate()
            } else {
                self.getData()
                sortNotes(by: currentSortMethod ?? "tab_notes_sort_alph_az".localized())
            }
        } else {
            self.getData()
        }
        
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
            
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
            topBorder.backgroundColor = UIColor.gray.cgColor
            
            tabBar.layer.addSublayer(topBorder)
            tabBar.clipsToBounds = true
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "tab_notes_search_notes".localized()
        navigationItem.searchController = searchController
        
    }
    
    @objc func showDropDown() {
        dropDown.show()
    }
    
    func sortNotes(by criteria: String) {
        currentSortMethod = criteria
        
        switch criteria {
            case "tab_notes_sort_alph_az".localized():
                notes.sort { $0.title < $1.title }
            case "tab_notes_sort_alph_za".localized():
                notes.sort { $0.title < $1.title }
                notes.reverse()
            case "tab_notes_sort_create_old".localized():
                notes.sort { $0.createdDate < $1.createdDate }
            case "tab_notes_sort_create_new".localized():
                notes.sort { $0.createdDate < $1.createdDate }
                notes.reverse()
            case "tab_notes_sort_edit_old".localized():
                notes.sort { $0.editedDate < $1.editedDate }
            case "tab_notes_sort_edit_new".localized():
                notes.sort { $0.editedDate < $1.editedDate }
                notes.reverse()
            default:
                break
        }
        self.tableView.reloadData()
    }
    
    func authenticate() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "security_use_pin".localized()
        localAuthenticationContext.localizedCancelTitle = "exit".localized()
        
        var authorizationError: NSError?
        let reason = "security_auth_reason".localized()
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                if success {
                    DispatchQueue.main.async() {
                        self.showToast(message: "success".localized(), duration: .short)
                        self.getData()
                        self.sortNotes(by: self.currentSortMethod ?? "tab_notes_sort_alph_az".localized())
                    }
                }
                else { exit(-1) }
            }
        }
        else { guard authorizationError != nil else { return } }
    }
    
    func updateSelectAllButton() {
        if tableView.indexPathsForSelectedRows?.count == notes.count {
            selectAllButton.title = "tab_notes_deselect_all".localized()
        } else {
            selectAllButton.title = "tab_notes_select_all".localized()
        }
    }
    
    func updateDropDownAppearance() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if isDarkMode {
            dropDown.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
            dropDown.textColor = .white
        } else {
            dropDown.backgroundColor = .white
            dropDown.textColor = .black
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    @objc func activateMultiSelectMode() {
        tableView.setEditing(true, animated: true)
        
        let deleteAllButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(deleteSelectedRows))
        deleteAllButton.tintColor = .systemRed
        let cancelButton = UIBarButtonItem(image: UIImage(systemName: "trash.slash.fill"), style: .done, target: self, action: #selector(exitEditingMode))
        selectAllButton = UIBarButtonItem(title: "tab_notes_select_all".localized(), style: .plain, target: self, action: #selector(selectOrDeselectAll))
        self.navigationItem.leftBarButtonItems = [deleteAllButton, cancelButton]
        self.navigationItem.rightBarButtonItem = selectAllButton
    }
    
    @objc func exitEditingMode() {
        tableView.setEditing(false, animated: true)
        self.navigationItem.leftBarButtonItems = nil
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(showDropDown))
        self.navigationItem.rightBarButtonItem = sortButton
        dropDown.anchorView = sortButton
    }
    
    @objc func deleteSelectedRows() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            let sortedRows = selectedRows.sorted(by: { $0.row > $1.row })
            
            for indexPath in sortedRows {
                let idToDelete = self.notes[indexPath.row].id
                if self.viewModel.deleteNote(with: idToDelete) {
                    self.notes.remove(at: indexPath.row)
                } else {
                    print("Error during deleting")
                }
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: sortedRows, with: .fade)
            tableView.endUpdates()
        }
        
        exitEditingMode()
    }
    
    @objc func selectOrDeselectAll() {
        if tableView.indexPathsForSelectedRows?.count == notes.count {
            for indexPath in tableView.indexPathsForSelectedRows! {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            selectAllButton.title = "tab_notes_select_all".localized()
        } else {
            for row in 0..<notes.count {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
            }
            selectAllButton.title = "tab_notes_deselect_all".localized()
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                activateMultiSelectMode()
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    @objc func handleDarkModeChange() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        self.tabBarController?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        updateDropDownAppearance()
    }
    
    @objc func getData() {
        self.notes = viewModel.fetchNotes()
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        selectedNote = nil
        let storyboard = UIStoryboard(name: "DetailsParchmentView", bundle: nil)
        if let destination = storyboard.instantiateViewController(withIdentifier: "detailsParchmentView") as? DetailsParchmentViewController {
            destination.updateChildViewControllers(withNote: nil, delegate: self)
            navigationController?.pushViewController(destination, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredNotes.count : notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainTableViewCell", for: indexPath) as? MainTableViewCell {
            let note = isFiltering() ? filteredNotes[indexPath.row] : notes[indexPath.row]
            cell.updateCell(note: note)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            selectedNote = notes[indexPath.row]
            let storyboard = UIStoryboard(name: "DetailsParchmentView", bundle: nil)
            if let destination = storyboard.instantiateViewController(withIdentifier: "detailsParchmentView") as? DetailsParchmentViewController {
                destination.updateChildViewControllers(withNote: selectedNote!, delegate: self)
                navigationController?.pushViewController(destination, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            updateSelectAllButton()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateSelectAllButton()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "delete_alert_deleting".localized(), message: "delete_alert_warning".localized(), preferredStyle: .alert)
            let deleteButton = UIAlertAction(title: "delete".localized(), style: .destructive) { _ in
                let idToDelete = self.notes[indexPath.row].id
                if self.viewModel.deleteNote(with: idToDelete) {
                    self.notes.remove(at: indexPath.row)
                    self.tableView.reloadData()
                } else {
                    print("delete_error".localized())
                }
            }
            let dismissButton = UIAlertAction(title: "alert_cancel".localized(), style: .default, handler: nil)
            alert.addAction(deleteButton)
            alert.addAction(dismissButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UISearchResultUpdating

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            filteredNotes = notes.filter { note in
                let isTitleMatching = note.title.localizedCaseInsensitiveContains(text)
                let isContentMatching = note.content.localizedCaseInsensitiveContains(text)
                return isTitleMatching || isContentMatching
            }
        } else {
            filteredNotes = notes
        }
        tableView.reloadData()
    }
}

// MARK: - NoteDelegateProtocol

extension MainViewController: NoteDelegate {
    func didAddNote() {
        self.notes = viewModel.fetchNotes()
        sortNotes(by: currentSortMethod ?? "tab_notes_sort_alph_az".localized())
        self.tableView.reloadData()
    }
}
