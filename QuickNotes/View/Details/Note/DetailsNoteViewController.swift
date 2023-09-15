import UIKit
import CoreData

class DetailsNoteViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var adaptiveButton: UIButton!
    
    var viewModel: DetailsViewModel?
    var chosenNote: Note?
    var isNewMode: Bool?
    weak var delegate: NoteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        viewModel = DetailsViewModel(context: context)
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = chosenNote?.title ?? "New Note"
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    
    func setupViews() {
        contentField.layer.borderWidth = 0.3
        contentField.layer.borderColor = UIColor.gray.cgColor
        contentField.layer.cornerRadius = 8
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        setupKeyboardToolbar()
        
        titleField.delegate = self
        contentField.delegate = self
        
        
        
        if let note = chosenNote {
            adaptiveButton.setTitle("Edit", for: .normal)
            titleField.text = note.title
            contentField.text = note.content
            isNewMode = false
        } else {
            adaptiveButton.setTitle("Save", for: .normal)
            let placeholderAttributes: [NSAttributedString.Key : Any] = [
                .font: UIFont.boldSystemFont(ofSize: 19),
                .foregroundColor: UIColor.lightGray
            ]
            
            contentField.attributedText = NSAttributedString(string: "Note", attributes: placeholderAttributes)
            isNewMode = true
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        
        toolbar.setItems([space, done], animated: true)
        toolbar.sizeToFit()
        
        contentField.inputAccessoryView = toolbar
        titleField.inputAccessoryView = toolbar
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        if let mode = isNewMode {
            if mode {
                viewModel?.saveNewNote(title: titleField.text!, note: contentField.text!)
            } else {
                if let id = chosenNote?.id, let text = contentField.text, let title = titleField.text {
                    viewModel?.updateExistingNote(id: id, updatedTitle: title, updatedNote: text)
                }
            }
        }
        
        
        delegate?.didAddNote()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        
    }
}

// MARK: - UITextFieldDelegate

extension DetailsNoteViewController: UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adaptiveButton.isEnabled = true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentField.text = nil
        contentField.textColor = .label
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            contentField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        adaptiveButton.isEnabled = true
    }
    
}
