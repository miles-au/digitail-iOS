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

class QRListViewController: UIViewController {
    
    var QRBlockArray = [QRBlock]()
    var isShuffling = false
    let screenSize: CGRect = UIScreen.main.bounds
    var QRBlockSizeWithoutQRCode: CGFloat = 90.0
    let layout = UICollectionViewFlowLayout()
    var qrSquareSize: CGFloat = 0.0
    
    @IBOutlet weak var ShuffleButton: UIBarButtonItem!
    @IBOutlet weak var addQRBlockButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QRBlockArray = QRBlock.getOldQRBlocks()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragInteractionEnabled = false
        collectionView.reorderingCadence = .immediate
        collectionView.register(UINib(nibName: "QRBlockViewCell", bundle: .none), forCellWithReuseIdentifier: "QRBlockViewCell")
        
        setupCells()
        layoutCells()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addQRViewController = segue.destination as? AddQRViewController {
            addQRViewController.delegate = self
            
            // navigation bar styling
            let backItem = UIBarButtonItem()
            backItem.image = UIImage(systemName: "xmark")
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupCells()
        layoutCells()
    }

    //MARK: - Rearrangeable collection view
    @IBAction func ReorderButtonPressed(_ sender: UIBarButtonItem) {
        isShuffling = !isShuffling
        if isShuffling{
            addQRBlockButton.isEnabled = false
            collectionView.dragInteractionEnabled = true
            ShuffleButton.image = UIImage(systemName: "checkmark")
            layout.itemSize = CGSize(width: qrSquareSize, height: 70.0)
        } else {
            addQRBlockButton.isEnabled = true
            collectionView.dragInteractionEnabled = false
            ShuffleButton.image = UIImage(systemName: "shuffle")
            layout.itemSize = CGSize(width: qrSquareSize, height: qrSquareSize + 100.0)
        }
        collectionView.reloadData()
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
        collectionView.reloadData()
    }
}

extension QRListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QRBlockArray.count
    }
    
    @objc func removeQRBlock(sender: UICollectionViewCell){
        let index = sender.tag
        QRBlockArray.remove(at: index)
        QRBlock.writeNewQRBlocks(with: QRBlockArray)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let QRBlockObj = QRBlockArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QRBlockViewCell", for: indexPath) as! QRBlockViewCell
        cell.trashButtonView.tag = indexPath.row
        cell.trashButtonView.addTarget(self, action: #selector(QRListViewController.removeQRBlock(sender:)), for: .touchUpInside)
        
        // Generate QR Image
        if var qrCode = QRCode(QRBlockObj.url){
            if isShuffling{
                cell.platformLabelView.text = QRBlockObj.handle
                cell.QRBlockSocialIconView.image = UIImage(named: QRBlockObj.platform)
                cell.handleLabelView.isHidden = true
                cell.QRCodeImageView.isHidden = true
                cell.trashButtonView.isHidden = false
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
                cell.trashButtonView.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isShuffling
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let travellingBlock = QRBlockArray.remove(at: sourceIndexPath.row)
        QRBlockArray.insert(travellingBlock, at: destinationIndexPath.row)
        QRBlock.writeNewQRBlocks(with: QRBlockArray)
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func setupCells(){
        if screenSize.width < 700{ // width suggests mobile screen
            qrSquareSize = UIScreen.main.bounds.size.width - 20.0
        } else if screenSize.width < 800 { // width suggests smaller iPad screen
            qrSquareSize = UIScreen.main.bounds.size.width / 2 - 20.0
        } else if screenSize.width < 1100 { // width suggests larger iPad screen in portrait
            qrSquareSize = UIScreen.main.bounds.size.width / 3 - 20.0
        } else { // width suggests larger iPad screen in landscape
            qrSquareSize = UIScreen.main.bounds.size.width / 4 - 20.0
        }
    }
    
    func layoutCells() {
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: qrSquareSize, height: qrSquareSize + 100.0)
        collectionView!.collectionViewLayout = layout
    }
}

