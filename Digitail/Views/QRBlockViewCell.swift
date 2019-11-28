//
//  QRBlockViewCellCollectionViewCell.swift
//  Digitail
//
//  Created by Miles Au on 2019-11-26.
//  Copyright © 2019 Miles Au. All rights reserved.
//

import UIKit

class QRBlockViewCell: UICollectionViewCell {

    @IBOutlet weak var platformLabelView: UILabel!
    @IBOutlet weak var handleLabelView: UILabel!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var QRBlockSocialIconView: UIImageView!
    @IBOutlet weak var QRBlockCellContentView: UIView!
    @IBOutlet weak var trashButtonView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
