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
    
    static let EmptyComment = Comments(id: "imagine", postId: "Test1", userId: "admin", profilePicture: "", username: "Testing Offline User", toUsername: "To Testing Offline User", content: "Amazing Post!", likes: 0, timestamp: Date())
}

struct ConstantFunction {
    static func formatTimeAgo(from date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        guard let formattedString = formatter.string(from: date, to: Date()) else {
            return "Unknown"
        }
        
        return formattedString + " ago"
    }
}
