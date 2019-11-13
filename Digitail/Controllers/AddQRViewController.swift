//
//  AddQRViewController.swift
//  Digitail
//
//  Created by Miles Au on 2019-11-10.
//  Copyright © 2019 Miles Au. All rights reserved.
//

import UIKit

protocol DismissAddQRViewControllerDelegate: class {
    func dismissed()
}

class AddQRViewController: UIViewController, UIScrollViewDelegate{
    
    var platformsIconsArray = NewQRPlatformIcon.platforms
    var delegate: DismissAddQRViewControllerDelegate?
    
    @IBOutlet weak var PlatformLabel: UILabel!
    @IBOutlet weak var NewQRUrlTextField: UITextField!
    @IBOutlet weak var NewQRUrlTextFieldLabelView: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var finalPlatform: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "NewQRPlatformIconsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewQRPlatformIconCell")
        layoutCells()
        collectionView.reloadData()
    }
    
    @IBAction func AddQRPressed(_ sender: UIButton) {
        var target = NewQRUrlTextField.text!
        if target.count > 0 , let platform = finalPlatform{
            // validate URL
            var legitTarget = false
            switch platform {
            case "Facebook", "LinkedIn", "GitHub":
                legitTarget = checkURLAndPlatform(url: target, platform: platform)
            case "Instagram", "Twitter":
                if target.first == "@"{
                    target.remove(at: target.startIndex)
                }
                target = "https://www.\(platform.lowercased()).com/\(target)"
            default:
                legitTarget = true
            }
            
            if legitTarget || platform == "Twitter" || platform == "Instagram" {
                let handle = getHandle(platform: platform, url: target)
                let newQRBlock = QRBlock(platform: platform, url: target, handle: handle)
                var QRBlockArray = [QRBlock]()
                
                // open old file
                QRBlockArray = QRBlock.getOldQRBlocks()
                QRBlockArray.append(newQRBlock)
                
                // write to file
                QRBlock.writeNewQRBlocks(with: QRBlockArray)
                
                self.delegate?.dismissed()
                //                dismiss(animated: true, completion: nil)
                navigationController?.popViewController(animated: true)
            } else{
                let alert = UIAlertController(title: "The url is either invalid or doesn't match the platform", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            
        }else{
            let alert = UIAlertController(title: "Please include a url and a platform", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func getHandle(platform: String, url: String) -> String{
        var handle = ""
        var target = url
        if target.last == "/"{
            target.remove(at: target.index(before: target.endIndex))
        }
        
        switch (platform) {
        case "Telephone", "Email", "Website":
            handle = target
        case "Facebook", "LinkedIn", "GitHub":
            if let slug = target.components(separatedBy: "/").last{
                handle = slug
            }
        case "Instagram", "Twitter":
            if let slug = target.components(separatedBy: "/").last{
                handle = "@\(slug)"
            }
        default:
            handle = ""
        }
        
        return handle
    }
    
    func checkURLAndPlatform(url: String, platform: String) -> Bool{
        if let target = URL(string: url) {
            if target.absoluteString.range(of: platform.lowercased()) != nil {
                return true
            }
        }
        return false
    }
    
    @IBAction func NewQRTextFieldPrimaryActionPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}


extension AddQRViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return platformsIconsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewQRPlatformIconCell", for: indexPath)
        let platformIconCell = cell as! NewQRPlatformIconsCollectionViewCell
        platformIconCell.NewQrPlatformCellImageView.image = UIImage(named: platformsIconsArray[indexPath.row].platform)
        
        return cell
    }
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        let itemSize = (UIScreen.main.bounds.size.width - 40)/4
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        collectionViewHeightConstraint.constant = UIScreen.main.bounds.size.width / 2
        collectionView!.collectionViewLayout = layout
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for platformIcon in collectionView.visibleCells{
            let platformIconCell = platformIcon as! NewQRPlatformIconsCollectionViewCell
            platformIconCell.NewQrPlatformCellImageView.layer.borderWidth = 0
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! NewQRPlatformIconsCollectionViewCell
        cell.NewQrPlatformCellImageView.layer.borderWidth = 5.0
        cell.NewQrPlatformCellImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        let platform = platformsIconsArray[indexPath.item].platform
        PlatformLabel.text = "Platform: \(platform)"
        
        switch platform {
        case "Email":
            NewQRUrlTextFieldLabelView.text = "Email:"
        case "Telephone":
            NewQRUrlTextFieldLabelView.text = "Phone Number:"
        case "Instagram", "Twitter":
            NewQRUrlTextFieldLabelView.text = "Handle:"
        default:
            NewQRUrlTextFieldLabelView.text = "URL:"
        }
        finalPlatform = platform
        
    }
    
}
