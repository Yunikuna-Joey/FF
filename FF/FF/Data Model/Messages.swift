//
//  Messages.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Messages: Codable, Identifiable, Hashable {
    // who the message was from
    let fromUser: String
    
    // who the message was to
    let toUser: String
    
    // date the message was sent
    let timestamp: Date
    
    // content of message
    let messageContent: String
    
    var id: String {
        return UUID().uuidString
    }

//    var id: String {
//        return messageId ?? NSUUID().uuidString
//    }
//    
    // this will determine who we are chatting with
    var chatPartnerId: String {
        return fromUser == Auth.auth().currentUser?.uid ? toUser : fromUser
    }
    
    // determine if it the current user
    var currentUserFlag: Bool {
        return fromUser == Auth.auth().currentUser?.uid
    }
}
