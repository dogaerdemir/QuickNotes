import UIKit
import CoreData
import LocalAuthentication
import UserNotifications
import DropDown

protocol NoteDelegate: AnyObject {
    func didAddNote()
}

class MainViewController: UIViewController, NoteDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var notes: [Note] = []
    var selectedNote: Note?
    
    lazy var dropDown : DropDown = {
        let menu = DropDown()
        let sortTypes = ["Sort By", "Alphabetical (A-Z)", "Alphabetical (Z-A)", "Create Date (Oldest First)", "Create Date (Newest First)", "Edit Date (Oldest First)", "Edit Date (Newest First)"]
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
        
        menu.width = 220
        
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
    
    var currentSortMethod: String?
    
    let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Notes"
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainTableViewCell")
        
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
        
        let isLockedApp = UserDefaults.standard.bool(forKey: "isLockedApp")
        if isLockedApp {
            authenticate()
        } else {
            self.getData()
            
            sortNotes(by: currentSortMethod ?? "Alphabetical (A-Z)")
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
    }
    
    @objc func showDropDown() {
        dropDown.show()
    }
    
    func sortNotes(by criteria: String) {
        currentSortMethod = criteria
        
        switch criteria {
            case "Alphabetical (A-Z)":
                notes.sort { $0.title < $1.title }
            case "Alphabetical (Z-A)":
                notes.sort { $0.title < $1.title }
                notes.reverse()
            case "Create Date (Oldest First)":
                notes.sort { $0.createdDate < $1.createdDate }
            case "Create Date (Newest First)":
                notes.sort { $0.createdDate < $1.createdDate }
                notes.reverse()
            case "Edit Date (Oldest First)":
                notes.sort { $0.editedDate < $1.editedDate }
            case "Edit Date (Newest First)":
                notes.sort { $0.editedDate < $1.editedDate }
                notes.reverse()
            default:
                break
        }
        self.tableView.reloadData()
    }
    
    func authenticate() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use pin code"
        localAuthenticationContext.localizedCancelTitle = "Exit"
        
        var authorizationError: NSError?
        let reason = "Authentication is needed to access to app."
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                if success {
                    DispatchQueue.main.async() {
                        self.showToast(message: "Success", duration: 1.5)
                        self.getData()
                        self.sortNotes(by: self.currentSortMethod ?? "Alphabetical (A-Z)")
                    }
                }
                else { exit(-1) }
            }
        }
        else { guard authorizationError != nil else { return } }
    }
    
    func didAddNote() {
        self.notes = viewModel.fetchNotes()
        sortNotes(by: currentSortMethod ?? "Alphabetical (A-Z)")
        self.tableView.reloadData()
    }
    
    @objc func handleDarkModeChange() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    
    @objc func getData() {
        self.notes = viewModel.fetchNotes()
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        selectedNote = nil
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenNote = selectedNote
            destinationVC.delegate = self
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainTableViewCell", for: indexPath) as? MainTableViewCell {
            cell.updateCell(note: notes[indexPath.row])
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = notes[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Deleting", message: "This cannot be undone", preferredStyle: .alert)
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let idToDelete = self.notes[indexPath.row].id
                if self.viewModel.deleteNote(with: idToDelete) {
                    self.notes.remove(at: indexPath.row)
                    self.tableView.reloadData()
                } else {
                    print("Error during deleting")
                }
            }
            let dismissButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(deleteButton)
            alert.addAction(dismissButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
