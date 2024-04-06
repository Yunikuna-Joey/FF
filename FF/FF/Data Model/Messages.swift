//
//  Messages.swift
//  FF
//
//

import Foundation

struct Messages: Codable {
    // username
    let username: String
    
    // date the message was sent
    let timestamp: Date
    
    // content of message
    let messageContent: String
}
