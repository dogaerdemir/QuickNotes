//
//  MainTableViewCell.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 10.09.2023.
//

import UIKit
import Localize_Swift

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var infoCreatedLabel: UILabel!
    @IBOutlet weak var infoEditedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell(note: Note) {
        titleLabel.text = note.title
        contentLabel.text = note.content
        
        let dateFormatter = DateFormatter()
        if Localize.currentLanguage() == "tr" {
            dateFormatter.locale = Locale(identifier: "tr_TR")
            dateFormatter.dateFormat = "d MMMM yyyy - HH:mm"
        } else {
            dateFormatter.locale = Locale(identifier: "en_EN")
            dateFormatter.dateFormat = "MMMM d, yyyy - HH:mm"
        }
        
        
        let createdDateStr = dateFormatter.string(from: note.createdDate)
        let editedDateStr = dateFormatter.string(from: note.editedDate)
    
        infoCreatedLabel.text = "\("cell_note_created".localized()): \(createdDateStr)"
        infoEditedLabel.text = "\("cell_note_edited".localized()): \(editedDateStr)"
    }
    
}
