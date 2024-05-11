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
//    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    @Published var statusList: [Status] = []
    @Published var feedList = [Status]()
    
    private let db = Firestore.firestore()
    private let dbStatus = Firestore.firestore().collection("Statuses")
    
    func postStatus(userId: String, username: String, content: String, bubbleChoice: [String], timestamp: Date, location: String, likes: Int) async {
        do {
            // handle the new status object
            let newStatus = Status(id: UUID().uuidString, userId: userId, username: username, content: content, bubbleChoice: bubbleChoice, timestamp: timestamp, location: location, likes: likes)
            try await dbStatus.document(newStatus.id).setData(from: newStatus)
        }
        catch {
            print("[DEBUG]: Error posting status: \(error.localizedDescription)")
        }
    }
    
    // delete status from firebase || [work on data-type from postId]
    func deleteStatus(postId: String) async throws {
        do {
            try await dbStatus.document(postId).delete()
        }
        catch {
            print("[DEBUG]: Error deleting status: \(error.localizedDescription)")
        }
    }
    
    // Queries all of the statuses associated only with the given UserID Parameter
    func fetchStatus(userId: String) {
        // query the database collections on userId value
        dbStatus
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
    
    // fetch the feed for the requested user
    func fetchFeed(userId: String, completion: @escaping ([Status]) -> Void) {
        // first query all of the people that userId parameter follows
        let query = db.collection("Following")
            .whereField("userId", isEqualTo: userId)
        
        
        query.getDocuments { snapshot, error in
            // once the error is hit, it should break out of the function body
            guard let snapshot = snapshot else {
                if let error = error {
                    print("[FetchFeed]: Error grabbing following users \(error.localizedDescription)")
                }
                completion([])
                return
            }
        
            
            // This will contain all of the friendId's that our current user is following
            let followingList = snapshot.documents.compactMap { $0.data()["friendId"] as? String }
            print("FollowingList value \(followingList)")
            
            // iterate through the list
            for friend in followingList {
               
                let query2 = self.dbStatus
                    .whereField("userId", isEqualTo: friend)
                
                // for every friendId, attempt to grab their status data
                query2.getDocuments { statusSnapshot, error in
                    // error catch
                    if let error = error {
                        print("[FetchFeed2]: Error grabbing friend statuses \(error.localizedDescription)")
                        return
                    }
                }
                
                query2.addSnapshotListener { snapshot, _ in
                    guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
                    
                    var statuses = changes.compactMap({ try? $0.document.data(as: Status.self )})
                    
                    completion(statuses)
                }
                

            } // end of forloop
            
        } // end of query.getDocuments
    }
}
