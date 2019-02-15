//
//  EntryCell.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: EntryCell.self)
    }

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    func configure(with viewModel: EntryViewModel) {
        thumbnailImageView.image = viewModel.thumbnailImage
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.width/2 // Make the thumnail a circular view.
        
        dateLabel.text = viewModel.creationDate
        descriptionLabel.text = viewModel.description
        locationLabel.text = viewModel.locationName
        
    }
}
