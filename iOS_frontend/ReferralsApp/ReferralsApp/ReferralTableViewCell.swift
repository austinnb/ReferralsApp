//
//  ReferralTableViewCell.swift
//  ReferralsApp
//
//  Created by Austin Brewer on 4/20/15.
//  Copyright (c) 2015 Austin Brewer. All rights reserved.
//

import UIKit

class ReferralTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
