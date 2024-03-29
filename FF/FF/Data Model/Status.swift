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
    
    // might want a post character limit
    let content: String
    
    // bubbles [various types of workouts associated with one status]
    let bubbleChoice: [String]
    
    // [determine better data-type if possible]
    let timestamp: Date
    
    // location data [not sure if it should be a string for the time being]
    let location: String
    
    // integer number representing likes
    let likes: Int
}
