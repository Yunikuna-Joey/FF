//
//  FollowingManager.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FollowingManager: ObservableObject {
    private let db = Firestore.firestore()
    
    func followUser(userId: String, friendId: String) async {
        do {
            // create an entry where we see User A follow User B
            let entry = Following(id: UUID().uuidString, userId: userId, friendId: friendId)
            
            try await db.collection("Following").document(entry.id).setData(from: entry)
        }
        
        catch {
            print("[DEBUG]: Error following user: \(error.localizedDescription)")
        }
    }
    
    func unfollowUser(userId: String, friendId: String) async {
        do {
            // query the document that holds when the following instance was made
            let snapshot = try await db.collection("Following")
                .whereField("userId", isEqualTo: userId)
                .whereField("friendId", isEqualTo: friendId)
                .getDocuments()
            
            // delete the entry || snapshot
            for document in snapshot.documents {
                // delete the entry
                try await db.collection("Following").document(document.documentID).delete()
            }
        }
        
        catch {
            print("[DEBUG]: Error unfollowing user \(error.localizedDescription)")
        }
    }
}
