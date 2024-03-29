//
//  StatusProcessView.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol StatusFormProtocol {
    var validForm: Bool { get }
}

class StatusProcessView: ObservableObject {
    // [Session handling here]
    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    
    func postStatus(content: String, bubbleChoice: [String], timestamp: Date, location: String, likes: Int) async {
        do {
            // handle the new status object
            let newStatus = Status(id: UUID().uuidString, content: content, bubbleChoice: bubbleChoice, timestamp: timestamp, location: location, likes: likes)
            try await Firestore.firestore().collection("Statuses").document(newStatus.id).setData(from: newStatus)
        } 
        catch {
            print("[DEBUG]: Error posting status: \(error.localizedDescription)")
        }
    }
    
    // delete status from firebase || [work on data-type from postId]
    func deleteStatus(postId: String) async throws {
        do {
            try await Firestore.firestore().collection("statuses").document(postId).delete()
        }
        catch {
            print("[DEBUG]: Error deleting status: \(error.localizedDescription)")
        }
    }
}
