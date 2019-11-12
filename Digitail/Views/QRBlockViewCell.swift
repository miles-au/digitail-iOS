//
//  QRBlockViewCell.swift
//  Digitail
//
//  Created by Miles Au on 2019-11-10.
//  Copyright © 2019 Miles Au. All rights reserved.
//

import UIKit

class QRBlockViewCell: UITableViewCell {

    @IBOutlet weak var platformLabelView: UILabel!
    @IBOutlet weak var handleLabelView: UILabel!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var QRBlockSocialIconView: UIImageView!
    @IBOutlet weak var QRBlockCellContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
