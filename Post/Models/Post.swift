//
//  Post.swift
//  Post
//
//  Created by Darin Marcus Armstrong on 6/24/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

struct Post {
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    init(text: String, username: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
}
