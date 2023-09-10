//
//  MainTableViewCell.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 10.09.2023.
//

import UIKit

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
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let createdDateStr = dateFormatter.string(from: note.createdDate)
        let editedDateStr = dateFormatter.string(from: note.editedDate)
    
        infoCreatedLabel.text = "CREATED - \(createdDateStr)"
        infoEditedLabel.text = "LAST EDITED - \(editedDateStr)"
    }
    
}
