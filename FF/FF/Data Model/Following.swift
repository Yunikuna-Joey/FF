//
//  Following.swift
//  FF
//
//

import Foundation

struct Following: Identifiable, Codable {
    // represent one instance of who followed who [firestore document id ]
    let id: String
    
    // User A
    let userId: String
    
    // User B
    let friendId: String
}
