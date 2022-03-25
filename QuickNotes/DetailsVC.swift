import UIKit
import CoreData

class DetailsVC: UIViewController, UITextViewDelegate
{

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    var activeField: UITextField?
    var chosenNote = ""
    var chosenNoteID : UUID?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupTextFields()
        
        self.textField.delegate = self
        
        // Tableview item has been selected
        if chosenNote != ""
        {
            saveButton.isHidden = true
            editButton.isHidden = false
            editButton.isEnabled = false
            //textField.isSelectable = true
            //textField.isEditable = false
            //titleField.isEnabled = false
            //view.isUserInteractionEnabled = false

            // Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            
            let idString = chosenNoteID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do
            {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0
                {
                    for result in results as! [NSManagedObject]
                    {
                        if let title = result.value(forKey: "title") as? String{
                            titleField.text = title
                        }
                        
                        if let note = result.value(forKey: "note") as? String{
                            textField.text = note
                        }
                    }
                }
            }
            catch
            {
                print("error")
            }
            
            
        }
        // Add button is selected
        else
        {
            saveButton.isHidden = false
            editButton.isHidden = true
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonClicked(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        //Attributes
        
        newNote.setValue(titleField.text!, forKey: "title")
        newNote.setValue(textField.text, forKey: "note")
    
        newNote.setValue(UUID(), forKey: "id")
    
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonClicked(_ sender: Any)
    {
        // CoreData update process
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        
        let idString = chosenNoteID?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let object = try context.fetch(fetchRequest)
            if object.count == 1
            {
                let objectUpdate = object.first as! NSManagedObject
                objectUpdate.setValue(textField.text!, forKey: "note")
                objectUpdate.setValue(titleField.text!, forKey: "title")
                do{
                    try context.save()
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard()
    {
        view.endEditing(true)
    }
        
    func textViewDidChange(_ textView: UITextView)
    {
        editButton.isEnabled = true
    }
    
    // Toolbar for top of the keyboard. "Done" button ends editing and dismisses the keyboard.
    func setupTextFields()
    {
        let toolbar = UIToolbar()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        
        toolbar.setItems([space, done], animated: true)
        toolbar.sizeToFit()
        
        textField.inputAccessoryView = toolbar
        titleField.inputAccessoryView = toolbar
    }
        
    @objc func doneButtonClicked()
    {
        view.endEditing(true)
    }
}
