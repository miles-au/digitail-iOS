//
//  QRListViewController.swift
//  Digitail
//
//  Created by Miles Au on 2019-11-10.
//  Copyright © 2019 Miles Au. All rights reserved.
//

import UIKit
import QRCode
import SwiftReorder
import SwiftUI

class QRListViewController: UIViewController, UITableViewDataSource {
    
    var QRBlockArray = [QRBlock]()
    var isShuffling = false
    let screenSize: CGRect = UIScreen.main.bounds
    var QRBlockSizeWithoutQRCode: CGFloat = 90.0
    @IBOutlet weak var ShuffleButton: UIBarButtonItem!
    @IBOutlet weak var addQRBlockButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QRBlockArray = QRBlock.getOldQRBlocks()
        
        tableView.dataSource = self
        tableView.reorder.delegate = self
        tableView.register(UINib(nibName: "QRBlockViewCell", bundle: nil), forCellReuseIdentifier: "QRBlockViewCell")
        tableView.rowHeight = screenSize.width + QRBlockSizeWithoutQRCode
        tableView.reorder.longPressDuration = 0.2
        tableView.reorder.cellOpacity = 0.4

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addQRViewController = segue.destination as? AddQRViewController {
            addQRViewController.delegate = self
            
            // navigation bar styling
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
    }

    // MARK: - Table view data source

//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return QRBlockArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let QRBlockObj = QRBlockArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "QRBlockViewCell", for: indexPath) as! QRBlockViewCell
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }

        // Generate QR Image
        if var qrCode = QRCode(QRBlockObj.url){
            if isShuffling{
                cell.platformLabelView.text = QRBlockObj.handle
                cell.QRBlockSocialIconView.image = UIImage(named: QRBlockObj.platform)
                cell.handleLabelView.isHidden = true
                cell.QRCodeImageView.isHidden = true
            } else {
                let screenSize: CGRect = UIScreen.main.bounds
                qrCode.color = CIColor(rgba: "ffffff")
                qrCode.backgroundColor = CIColor(color: #colorLiteral(red: 0.1058823529, green: 0.1647058824, blue: 0.2862745098, alpha: 1))
                qrCode.size = CGSize(width: screenSize.width, height: screenSize.width)
                
                cell.platformLabelView.text = QRBlockObj.platform
                cell.QRBlockSocialIconView.image = UIImage(named: QRBlockObj.platform)
                cell.handleLabelView.text = QRBlockObj.handle
                cell.QRCodeImageView.image = qrCode.image
                cell.handleLabelView.isHidden = false
                cell.QRCodeImageView.isHidden = false
            }
            
        }

        return cell
    }

    //MARK: - Editable TableView
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            QRBlockArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            QRBlock.writeNewQRBlocks(with: QRBlockArray)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    //MARK: - Rearrangeable table view
    
    @IBAction func ReorderButtonPressed(_ sender: UIBarButtonItem) {
        isShuffling = !isShuffling
        if isShuffling{
            addQRBlockButton.isEnabled = false
            ShuffleButton.image = UIImage(systemName: "checkmark")
            tableView.rowHeight = QRBlockSizeWithoutQRCode
        } else {
            addQRBlockButton.isEnabled = true
            ShuffleButton.image = UIImage(systemName: "shuffle")
            tableView.rowHeight = screenSize.width + QRBlockSizeWithoutQRCode
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Link to my website
    @IBAction func linkToMilesWebsitePressed(_ sender: UIButton) {
        if let url = URL(string: "https://milesau.com"){
            UIApplication.shared.open(url)
        }

    }
    
}

extension QRListViewController: DismissAddQRViewControllerDelegate{
    func dismissed() {
        QRBlockArray = QRBlock.getOldQRBlocks()
        tableView.reloadData()
    }
    
}

extension QRListViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return isShuffling
    }
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        let initialPosition = initialSourceIndexPath[1]
        let destinationPosition = finalDestinationIndexPath[1]
        let travellingBlock = QRBlockArray.remove(at: initialPosition)
        QRBlockArray.insert(travellingBlock, at: destinationPosition)
        QRBlock.writeNewQRBlocks(with: QRBlockArray)
    }
}
