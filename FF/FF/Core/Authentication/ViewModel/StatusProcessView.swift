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
    @Published var statusList: [Status] = []
    
    private let db = Firestore.firestore()
    
    func postStatus(userId: String, content: String, bubbleChoice: [String], timestamp: Date, location: String, likes: Int) async {
        do {
            // handle the new status object
            let newStatus = Status(id: UUID().uuidString, userId: userId, content: content, bubbleChoice: bubbleChoice, timestamp: timestamp, location: location, likes: likes)
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
    
    func fetchStatus(userId: String) {
        // query the database collections on userId value
        db.collection("Statuses")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("[DEBUG]: Error fetching statuses: \(error.localizedDescription)")
                    return
                }
                
                // pack the document objects || status objects || one singular entry = document
                guard let documents = querySnapshot?.documents else {
                    print("[DEBUG]: No documents found")
                    return
                }
                
                self.statusList = documents.compactMap { document in
                    do {
                        let status = try document.data(as: Status.self)
                        return status
                    }
                    catch {
                        print("[DEBUG]: Error decoding statuses: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }
    
}
