//
//  StatusProcessView.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class StatusProcessView: ObservableObject {
    // [Session handling here]
    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    
    // define the variable name : data Type
    func postStatus(userId: String, content: String, bubbles: [String], location: String, timestamp: Date, likes: Int) async throws {
        do {
            // logic to post data into the data-base
            let newStatus = Status(id: UUID().uuidString, userId: userId, content: content, bubbles: bubbles, timestamp: timestamp, location: location, likes: likes)
            
            try await Firestore.firestore().collection("statuses").document(newStatus.id).setData(from: newStatus)
        }
        catch {
            // logic to handle error, if something is wrong
            print("[DEBUG]: Error posting status: \(error.localizedDescription)")
        }	
    }
}
