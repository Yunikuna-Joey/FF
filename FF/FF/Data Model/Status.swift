//
//  Status.swift
//  FF
//
//

import Foundation

// [Post-id, User-id, content, timestamp, likes]
struct Status: Identifiable, Codable {
    // POST ID
    let id: String
    
    // userObject
    var userObject: User
    
    // userId
    let userId: String
    
    // might want a post character limit
    let content: String
    
    // bubbles [various types of workouts associated with one status]
    let bubbleChoice: [String]
    
    // [determine better data-type if possible]
    let timestamp: Date
    
    // location data [not sure if it should be a string for the time being]
    let location: String
    
    // integer number representing likes
    var likes: Int
    
    // image url [this will be uploaded before packed in status object]
    var imageUrls: [String]
}
