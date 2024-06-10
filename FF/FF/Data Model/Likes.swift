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
    
    // toUsername
    let toUsername: String 
    
    // comment content
    let content: String
    
    // comment likes
    var likes: Int
    
    // timestamp
    let timestamp: Date
}
