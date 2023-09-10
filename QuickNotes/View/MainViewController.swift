import UIKit
import CoreData
import LocalAuthentication
import UserNotifications

protocol NoteDelegate: AnyObject {
    func didAddNote()
}

class MainViewController: UIViewController, NoteDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notes: [Note] = []
    var selectedNote: Note?
    let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainTableViewCell")
        
        let isLockedApp = UserDefaults.standard.bool(forKey: "isLockedApp")
        if isLockedApp { authenticate() } else { self.getData() }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDarkModeChange), name: NSNotification.Name("darkModeChanged"), object: nil)
        let blockedVC = UIViewController() as? DetailsViewController
        _ = blockedVC?.view
        
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
                    }
                }
                else { exit(-1) }
            }
        }
        else { guard let error = authorizationError else { return } }
    }
    
    func didAddNote() {
        self.notes = viewModel.fetchNotes()
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
