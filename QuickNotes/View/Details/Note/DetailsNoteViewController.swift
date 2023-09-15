import UIKit
import CoreData

class DetailsNoteViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var adaptiveButton: UIButton!
    
    var viewModel: DetailsViewModel?
    var chosenNote: Note?
    var originalNoteTitle: String?
    var originalNoteContent: String?
    var isNewMode: Bool?
    var placeholderLabel : UILabel!
    
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
        
        titleField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        contentField.delegate = self
        
        if let note = chosenNote {
            adaptiveButton.setTitle("Edit", for: .normal)
            adaptiveButton.isEnabled = false
            titleField.text = note.title
            contentField.text = note.content
            setupOriginalNote()
            isNewMode = false
            showPlaceholder()
        } else {
            isNewMode = true
            showPlaceholder()
            adaptiveButton.setTitle("Save", for: .normal)
            //titleField.becomeFirstResponder()
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func setupOriginalNote() {
        originalNoteTitle = titleField.text
        originalNoteContent = contentField.text
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
    
    func showPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Note"
        placeholderLabel.font = .boldSystemFont(ofSize: 19)
        placeholderLabel.sizeToFit()
        contentField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (contentField.font?.pointSize)! / 2 - 2)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !contentField.text!.isEmpty
    }
    
    func checkForChanges() {
        guard let titleText = titleField.text, !titleText.isEmpty,
              let contentText = contentField.text, !contentText.isEmpty else {
            adaptiveButton.isEnabled = false
            return
        }
        
        let hasChanged = (originalNoteTitle != titleField.text) || (originalNoteContent != contentField.text)
        adaptiveButton.isEnabled = hasChanged
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkForChanges()
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
}

// MARK: - UITextFieldDelegate and UITextViewDelegate

extension DetailsNoteViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkForChanges()
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }

}
