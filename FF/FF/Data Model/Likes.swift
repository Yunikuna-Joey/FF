//
//  Likes.swift
//  FF
//
//

import Foundation

struct Likes: Identifiable, Codable {
    // Like id
    let id: String
    // postId
    let postId: String
    // userID 
    let userId: String
}

struct Comments: Identifiable, Codable {
    // Comment ID
    let id: String
    
    // postId
    let postId: String
    
    // UserId
    let userId: String
    
    // userPicture
    let profilePicture: String
    
    // username
    let username: String 
    
    // comment content
    let content: String
    
    // timestamp
    let timestamp: Date
}
