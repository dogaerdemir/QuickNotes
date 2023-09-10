//
//  MainTableViewCell.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 10.09.2023.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var infoCreatedLabel: UILabel!
    @IBOutlet weak var infoEditedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(title: String, created: String, edited: String) {
        titleLabel.text = title
        infoCreatedLabel.text = "Created: \(created)"
        infoEditedLabel.text = "Edited: \(edited)"
    }
    
}
