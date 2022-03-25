import UIKit
import CoreData
import LocalAuthentication
import UserNotifications


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var authSwitch: UISwitch!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedNote = ""
    var selectedNoteID : UUID?
    
    let userDefaults = UserDefaults.standard

    override func viewDidAppear(_ animated: Bool)
    {
        authSwitch.isOn = userDefaults.bool(forKey: "mySwitchValue")
    }
    
    override func viewDidLoad()
    {
        authSwitch.isOn = userDefaults.bool(forKey: "mySwitchValue")
        if authSwitch.isOn
        {
            authenticate()
        }
        
        else
        {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.getData()
        }
    }

    func authenticate()
    {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use pin code"
        localAuthenticationContext.localizedCancelTitle = "Exit"

        var authorizationError: NSError?
        let reason = "Authentication is needed to access to app."

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError)
        {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            { success, evaluateError in
                
                if success
                {
                    DispatchQueue.main.async()
                    {
                        self.showToast(message: "Success", font: .systemFont(ofSize: 12.0))
                        
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.getData()
                    }
                    
                }
                else
                {
                    exit(-1)
                }
            }
        }
        else
        {
            guard let error = authorizationError else
            {
                return
            }
            print(error)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return nameArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedNote = nameArray[indexPath.row]
        selectedNoteID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any)
    {
        selectedNote = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    @objc func getData()
    {
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let name = result.value(forKey: "title") as? String
                    {
                        self.nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID
                    {
                        self.idArray.append(id)
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
        }
        
        catch
        {
            print("Error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toDetailsVC"
        {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenNote = selectedNote
            destinationVC.chosenNoteID = selectedNoteID
        }
    }
        
    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    // editing style -> deleting (swipe left)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let alert = UIAlertController(title: "Deleting", message: "Warning:This cannot be undone", preferredStyle: UIAlertController.Style.alert)
            let deleteButton = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) {UIAlertAction in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
            
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
                
                let idString = self.idArray[indexPath.row].uuidString
                fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
                
                fetchRequest.returnsObjectsAsFaults = false
                do
                {
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0
                    {
                        for result in results as! [NSManagedObject]
                        {
                            if let id = result.value(forKey: "id") as? UUID
                            {
                                if id == self.idArray[indexPath.row]
                                {
                                    context.delete(result)
                                    self.nameArray.remove(at: indexPath.row)
                                    self.idArray.remove(at: indexPath.row)
                                    self.tableView.reloadData()
                                    
                                    do
                                    {
                                        try context.save()
                                    }
                                    catch
                                    {
                                        
                                    }
                                    
                                    break
                                }
                            }
                        }
                    }
                }
                catch
                {
                    print("error")
                }
            }
            
            
            let dismissButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default){ UIAlertAction in
                
            }
            
            alert.addAction(deleteButton)
            alert.addAction(dismissButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchChanged(_ sender: Any)
    {
        userDefaults.set((sender as AnyObject).isOn, forKey: "mySwitchValue")
                
            if authSwitch.isOn
            {
                let alert = UIAlertController(title: "Biometrics have been enabled", message: "", preferredStyle: UIAlertController.Style.alert)
                let exitButton = UIAlertAction(title: "Quit", style: UIAlertAction.Style.destructive){ UIAlertAction in
                    exit(0)
                }
                let continueButton = UIAlertAction(title: "Keep using", style: UIAlertAction.Style.default){ UIAlertAction in
                    
                }
                
                alert.addAction(exitButton)
                alert.addAction(continueButton)
                self.present(alert, animated: true, completion: nil)
            }
    }
}

extension UIViewController
{
    // Adding this method to UIViewController via extension so from now on, we have the ability to create toast messages with this "built in" method.
    func showToast(message : String, font: UIFont)
    {
        /*
         The BEGINNING of the view starts in the middle, so it doesn't actually center itself.
         To center the view we need to subtract half the width of the view from the starting coordinate.
         */
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 1.5, delay: 2, options: .curveEaseOut, animations:{
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
