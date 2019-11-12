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
    
    var platformsArray = QRBlock.platforms
    var delegate: DismissAddQRViewControllerDelegate?
    
    @IBOutlet var NewQRPlatformCollection: [UIButton]!
    
    
    @IBAction func NewQRTelephonePressed(_ sender: UIButton) {
        updatePlatformChoice(with: "Telephone", sender: sender)
    }
    @IBAction func NewQREmailPressed(_ sender: UIButton) {
        updatePlatformChoice(with: "Email", sender: sender)
    }
    @IBAction func NewQRWebsitePressed(_ sender: UIButton) {
        updatePlatformChoice(with: "Website", sender: sender)
    }
    @IBAction func NewQRFacebookPressed(_ sender: UIButton) {
        updatePlatformChoice(with: "Facebook", sender: sender)
    }
    @IBAction func NewQRInstagramPressed(_ sender: UIButton) {
        updatePlatformChoice(with: "Instagram", sender: sender)
    }
    @IBAction func NewQRLinkedInPressed(_ sender: UIButton) {
        updatePlatformChoice(with: "LinkedIn", sender: sender)
    }
    @IBAction func NewQRGitHubPressed(_ sender: UIButton) {
        updatePlatformChoice(with: "GitHub", sender: sender)
    }
    @IBAction func NewQRTwitterPressed(_ sender: UIButton) {
        updatePlatformChoice(with: "Twitter", sender: sender)
    }
    
    @IBOutlet weak var PlatformLabel: UILabel!
    @IBOutlet weak var NewQRUrlTextField: UITextField!
    @IBOutlet weak var NewQRUrlTextFieldLabelView: UILabel!
    
    var finalPlatform: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updatePlatformChoice(with platform: String, sender: UIButton){
        PlatformLabel.text = "Platform: \(platform)"
        for platformIcon in NewQRPlatformCollection{
            platformIcon.layer.borderWidth = 0
        }
        
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
        sender.layer.borderWidth = 5
        sender.layer.borderColor = UIColor.white.cgColor
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
