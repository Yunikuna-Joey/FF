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
    
    func queryFollowStatus(userId: String, friendId: String) async -> Bool {
        do {
            let snapshot = try await db.collection("Following")
                .whereField("userId", isEqualTo: userId)
                .whereField("friendId", isEqualTo: friendId)
                .getDocuments()
            
            return !snapshot.documents.isEmpty
        }
        catch {
            print("[DEBUG]: Error fetching followStatus \(error.localizedDescription)")
            return false
        }
    }
    
    func queryFollowersCount(userId: String) async -> Int {
        do {
            let snapshot = try await db.collection("Following")
                .whereField("friendId", isEqualTo: userId)
                .getDocuments()
            
            let followerCount = snapshot.documents.count
            print("[DEBUG]: This is the follower count \(followerCount)")
            
            return followerCount
        }
        
        catch {
            print("[DEBUG]: There was an error querying followers \(error)")
            return 0
        }
    }
    
    func queryFollowingCount(userId: String) async -> Int {
        do {
            let snapshot = try await db.collection("Following")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            let followingCount = snapshot.documents.count
            print("[DEBUG]: This is the following count \(followingCount)")
            
            return followingCount
        }
        
        catch {
            print("[DEBUG]: There was an error querying following \(error)")
            return 0
        }
    }
    

    func queryFollowers(userId: String) async throws {
        do {
            let snapshot = try await db.collection("Following")
                .whereField("friendId", isEqualTo: userId)
                .getDocuments()
        }
            
        catch {
            print("[DEBUG]: There was an error with querying follower Id's \(error.localizedDescription)")
        }
    }
    
}
