import UIKit
import CoreData

class DetailsViewController: UIViewController, UITextViewDelegate
{

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var viewModel: DetailsViewModel?
    
    var chosenNote : Note?
    weak var delegate: NoteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        viewModel = DetailsViewModel(context: context)
        
        setupKeyboardToolbar()
        
        self.textField.delegate = self
        
        if let note = chosenNote {
            saveButton.isHidden = true
            editButton.isHidden = false
            editButton.isEnabled = false
            titleField.text = note.title
            textField.text = note.content
        } else {
            saveButton.isHidden = false
            editButton.isHidden = true
            editButton.isEnabled = true
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        viewModel?.saveNewNote(title: titleField.text!, note: textField.text!)
        delegate?.didAddNote()
        dismiss(animated: true)
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        if let id = chosenNote?.id {
            viewModel?.updateExistingNote(id: id, updatedTitle: titleField.text!, updatedNote: textField.text!)
            delegate?.didAddNote()
            dismiss(animated: true)
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
        
    func textViewDidChange(_ textView: UITextView) {
        editButton.isEnabled = true
    }
    
    func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        
        toolbar.setItems([space, done], animated: true)
        toolbar.sizeToFit()
        
        textField.inputAccessoryView = toolbar
        titleField.inputAccessoryView = toolbar
    }
        
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
}
