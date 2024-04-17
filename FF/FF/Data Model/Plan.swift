//
//  Plan.swift
//  FF
//
//

import Foundation

struct WorkoutDetail: Codable {
    let sets: Int
    let reps: Int
}

// temporary data model... might need to modify fields?
struct Plan: Identifiable, Codable {
    // plan id
    let id: String
    
    // who the plan belongs to
    let userId: String
    
    // plan title
    let planTitle: String
    
    // plan contents
    let workoutType: [String: WorkoutDetail]
}
