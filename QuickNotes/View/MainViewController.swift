import UIKit
import CoreData
import LocalAuthentication
import UserNotifications

protocol NoteDelegate: AnyObject {
    func didAddNote()
}

class MainViewController: UIViewController, NoteDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var authSwitch: UISwitch!
    
    var notes: [Note] = []
    var selectedNote: Note?
    
    let userDefaults = UserDefaults.standard
    let viewModel = MainViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        authSwitch.isOn = userDefaults.bool(forKey: "switchValue")
    }
    
    override func viewDidLoad() {
        authSwitch.isOn = userDefaults.bool(forKey: "switchValue")
        
        if authSwitch.isOn {
            authenticate()
        } else {
            self.getData()
        }
    }
    
    func didAddNote() {
        self.notes = viewModel.fetchNotes()
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
                    DispatchQueue.main.async()
                    {
                        self.showToast(message: "Success", duration: 1.5)
                        self.getData()
                    }
                    
                }
                else {
                    exit(-1)
                }
            }
        }
        else {
            guard let error = authorizationError else {
                return
            }
            print(error)
        }
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        selectedNote = nil
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    @objc func getData() {
        self.notes = viewModel.fetchNotes()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenNote = selectedNote
            destinationVC.delegate = self
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }

    @IBAction func switchChanged(_ sender: Any) {
        userDefaults.set((sender as AnyObject).isOn, forKey: "switchValue")
                
            if authSwitch.isOn {
                let alert = UIAlertController(title: "Biometrics have been enabled", message: "", preferredStyle: UIAlertController.Style.alert)
                let exitButton = UIAlertAction(title: "Quit", style: UIAlertAction.Style.destructive){ UIAlertAction in
                    exit(0)
                }
                let continueButton = UIAlertAction(title: "Keep using", style: UIAlertAction.Style.default){ UIAlertAction in
                    self.dismiss(animated: true)
                }
                
                alert.addAction(exitButton)
                alert.addAction(continueButton)
                self.present(alert, animated: true, completion: nil)
            }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = notes[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = notes[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Deleting", message: "Warning: This cannot be undone", preferredStyle: .alert)
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
