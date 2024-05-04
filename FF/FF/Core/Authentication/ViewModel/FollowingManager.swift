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
    
    // query the follower Id's of the requested ID 
    func queryFollowers(userId: String) async throws -> [User] {
        // represents the list of type User being returned from the function
        var followers: [User] = []
        
        do {
            let snapshot = try await db.collection("Following")
                .whereField("friendId", isEqualTo: userId)
                .getDocuments()
            
            for document in snapshot.documents {
                // we want the id's that follow the parameter userID
                if let followerId = document["userId"] as? String,
                   let user = try await getUserById(userId: followerId) {
                    followers.append(user)
                }
                
                else {
                    print("[DEBUG]: There is an error within queryFollowers")
                }
            }
        
            print("This is the value of follower: \(followers)")
            return followers
        } 
        
        catch {
            print("[DEBUG]: There was an error querying follower Users \(error.localizedDescription)")
            throw error
        }
    }
    
    //** This should query all of the id's that the requested UserID follows
    func queryFollowing(userId: String) async throws -> [User] {
        // represents the list of type User being returned from the function
        var following: [User] = []
        
        do {
            let snapshot = try await db.collection("Following")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            for document in snapshot.documents {
                // we want the id's that follow the parameter userID
                if let followerId = document["friendId"] as? String,
                   let user = try await getUserById(userId: followerId) {
                    following.append(user)
                }
                
                else {
                    print("[DEBUG]: There is an error within queryFollowers")
                }
            }
        
            print("This is the value of follower: \(following)")
            return following
        }
        
        catch {
            print("[DEBUG]: There was an error querying follower Users \(error.localizedDescription)")
            throw error
        }
    }
    
    // converts id into a user object
    func getUserById(userId: String) async throws -> User? {
        do {
            //**** make sure when querying user collection, we use lowercase :))))))))!
            let querySnapshot = try await db.collection("users").getDocuments()
            
            for document in querySnapshot.documents {
                let userData = document.data()
                
                if let id = userData["id"] as? String, id == userId,
                   let username = userData["username"] as? String,
                   let databaseUsername = userData["databaseUsername"] as? String,
                   let firstName = userData["firstName"] as? String,
                   let lastName = userData["lastName"] as? String,
                   let email = userData["email"] as? String,
                   let imageArray = userData["imageArray"] as? [String],
                   let profilePicture = userData["profilePicture"] as? String {
                    let user = User(
                        id: id,
                        username: username, 
                        databaseUsername: databaseUsername,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        imageArray: imageArray,
                        profilePicture: profilePicture
                    )
//                    print("This is the value of user \(user)")
                    return user
                }
            }
            
            print("[DEBUG]: User with ID \(userId) not found.")
            return nil
        } 
        catch {
            print("[DEBUG]: There was an error getting user by ID \(userId): \(error.localizedDescription)")
            throw error
        }
    }
    
}
