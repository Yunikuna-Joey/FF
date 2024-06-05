//
//  Constants.swift
//  FF
//
//

import Foundation


// Used for holding constans for the time being 
struct EmptyVariable {
    static let EmptyUser = User(id: "", username: "", databaseUsername: "", firstName: "", lastName: "", email: "", imageArray: [], profilePicture: "", coverPicture: "")
    
    static let EmptyPlan = Plan(id: "", userId: "", planTitle: "", workoutType: [:])
    
    static let EmptyComment = Comments(id: "imagine", postId: "Test1", userId: "admin", profilePicture: "", username: "Testing Offline User", content: "Amazing Post!", likes: 0, timestamp: Date())
}
