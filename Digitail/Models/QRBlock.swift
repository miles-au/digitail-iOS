//
//  QRBlock.swift
//  Digitail
//
//  Created by Miles Au on 2019-11-10.
//  Copyright © 2019 Miles Au. All rights reserved.
//

import Foundation

struct QRBlock: Codable{
    let platform: String
    let url: String
    let handle: String
    
    // Users/milesau/Library/Developer/CoreSimulator/Devices/8F169948-66A3-4C81-B44D-93B96B17E183/data/Containers/Data/Application/D5230662-D8EA-44EE-8CBB-F08E7C292FC4/Documents
    static let pListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("qrblocks.plist")
    static let platforms: [String] = ["Telephone", "Email", "Website", "Facebook", "Instagram", "LinkedIn", "GitHub", "Twitter"]
}

//MARK: - Retrieving and writing from PList File

extension QRBlock{
    static func getOldQRBlocks() -> [QRBlock]{
        var oldFiles = [QRBlock]()
        
        do {
            let fileURL = QRBlock.pListPath
            let data = try Data(contentsOf: fileURL)
            oldFiles = try PropertyListDecoder().decode([QRBlock].self, from: data)
        } catch {
            print("error writing to file: \(error)")
        }
        
        return oldFiles
    }
    
    static func writeNewQRBlocks(with QRBlockArray: [QRBlock]){
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let data = try encoder.encode(QRBlockArray)
            try data.write(to: QRBlock.pListPath)
        } catch {
            print(error)
        }
    }
}
