//
//  NewQRPlatformIcon.swift
//  Digitail
//
//  Created by Miles Au on 2019-11-12.
//  Copyright © 2019 Miles Au. All rights reserved.
//

import Foundation

struct NewQRPlatformIcon{
    let platform: String
    
    static let platforms: [NewQRPlatformIcon] = [NewQRPlatformIcon(platform: "Telephone"),
                                      NewQRPlatformIcon(platform: "Email"),
                                      NewQRPlatformIcon(platform: "Website"),
                                      NewQRPlatformIcon(platform: "Facebook"),
                                      NewQRPlatformIcon(platform: "Instagram"),
                                      NewQRPlatformIcon(platform: "LinkedIn"),
                                      NewQRPlatformIcon(platform: "GitHub"),
                                      NewQRPlatformIcon(platform: "Twitter")]
}
