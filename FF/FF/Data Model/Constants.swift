//
//  Constants.swift
//  FF
//
//

import Foundation


// Used for holding constans for the time being 
struct EmptyVariable {
    static let EmptyUser = User(id: "", username: "", databaseUsername: "", firstName: "", lastName: "", email: "", imageHashMap: [:], profilePicture: "", coverPicture: "")
    
    static let EmptyPlan = Plan(id: "", userId: "", planTitle: "", workoutType: [:])
    
    static let EmptyComment = Comments(id: "imagine", postId: "Test1", userObject: EmptyUser, userId: "admin", toUsername: "To Testing Offline User", content: "Amazing Post!", likes: 0, timestamp: Date())
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
    
    static func validatePassword(_ password: String) -> String? {
        // Uppercase functionality
        if !password.contains(where: { $0.isUppercase }) {
            return "Password must contain at least one uppercase letter!"
        }
        
        // Symbol functionality
        let symbols = "!@#$%^&*()_+\\-=[]{};':\"|,.<>/?"
        if !password.contains(where: { symbols.contains($0) }) {
            return "Password must contain at least one symbol!"
        }
        
        // password length validate
        if password.count < 8 {
            return "Password must be at least 8 characters long!"
        }
        
        // digit validation
        if !password.contains(where: {$0.isNumber }) {
            return "Password must contain at least one digit!"
        }
    
        return nil
    }
}
