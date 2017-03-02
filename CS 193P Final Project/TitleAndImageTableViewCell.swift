//
//  TitleAndImageTableViewCell.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/1/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class TitleAndImageTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var entityImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
