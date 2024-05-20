//
//  StatusProcessView.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

protocol StatusFormProtocol {
    var validForm: Bool { get }
}

class StatusProcessView: ObservableObject {
    // [Session handling here]
//    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    @Published var statusList: [Status] = []
    @Published var feedList = [Status]()
    @Published var searchFeedList: [Status] = []
    @Published var commentList = [Comments]()
    
    private let db = Firestore.firestore()
    private let dbStatus = Firestore.firestore().collection("Statuses")
    // private let dbLikes = Firestore.firestore().collection("Statuses").document("likes")
    
    func postStatus(userId: String, username: String, content: String, bubbleChoice: [String], timestamp: Date, location: String, likes: Int, imageUrls: [String]) async {
        do {
            // handle the new status object
            let newStatus = Status(id: UUID().uuidString, userId: userId, username: username, content: content, bubbleChoice: bubbleChoice, timestamp: timestamp, location: location, likes: likes, imageUrls: imageUrls)
            try dbStatus.document(newStatus.id).setData(from: newStatus)
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
        
        let userQuery = dbStatus
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
        
        userQuery.getDocuments { querySnapshot, error in
            if let error = error {
                print("[DEBUG]: Error fetching stauses \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("[DEBUG]: No documents found")
                completion([])
                return
            }
        }
        
        userQuery.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            
            var statuses = changes.compactMap({ try? $0.document.data(as: Status.self) })
            
            completion(statuses)
        }
    }
    
    // updating like count for a status
    func likeStatus(postId: String, userId: String) async throws -> Int {
        let statusRef = dbStatus
            .document(postId)
        
        // go into the status collection and create a comments document containing all of the comments associated
        let likeRef = statusRef
            .collection("likes")
        
        do {
            let statusDoc = try await statusRef.getDocument()
            var status = try statusDoc.data(as: Status.self)
            
            let likeSnapshot = try await likeRef
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            var likeCount = 0
            
            // if there is already a like document
            if !likeSnapshot.isEmpty {
                // decrement the like-count
                status.likes -= 1
                
                // set the data from status after incrementing the like count
                try statusRef.setData(from: status)
                
                // delete the like object from Firebase
                try await likeSnapshot.documents.first?.reference.delete()
                
                let updatedSnapshot = try await likeRef
                    .getDocuments()
                
                likeCount = updatedSnapshot.count
            }
            
            // if there is no like document
            else {
                // increment the like-count
                status.likes += 1
                
                // set the data from status after decrementing the like count
                try statusRef.setData(from: status)
                
                // create the like object
                let newLike = Likes(id: UUID().uuidString, postId: postId, userId: userId)
                
                // store the like object into firebase
                try likeRef.document(newLike.id).setData(from: newLike)
                
                let updatedSnapshot = try await likeRef
                    .getDocuments()
                
                likeCount = updatedSnapshot.count
            }
            
            return likeCount
            
        } 
        catch {
            print("[DEBUG]: Error liking status: \(error.localizedDescription)")
            throw error
        }
    }
    
    // initializing the like count
    func fetchLikeCount(postId: String) async throws -> Int {
        let snapshot = try await dbStatus
            .document(postId)
            .collection("likes")
            .whereField("postId", isEqualTo: postId)
            .getDocuments()
        
        return snapshot.count
    }
    
    // fetch like-boolean status
    func fetchLikeFlag(postId: String, userId: String) async throws -> Bool {
        let snapshot = try await dbStatus
            .document(postId)
            .collection("likes")
            .whereField("postId", isEqualTo: postId)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return !snapshot.isEmpty
    }
    
    // uploads array of images into firebaseStorage [not a database]
    func uploadImages(images: [UIImage]) async throws -> [String] {
        var imageUrls = [String]()
        let storageRef = Storage.storage().reference()
        
        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continue
            }
            
            let imageId = UUID().uuidString
            let imageRef = storageRef.child("images/\(imageId).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let downloadURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                imageRef.putData(imageData, metadata: metadata) { _, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let downloadURL = url {
                            continuation.resume(returning: downloadURL.absoluteString)
                        }
                    }
                }
            }
            
            imageUrls.append(downloadURL)
        }
        
        return imageUrls
    }
    
    //** Singular UIImage upload [changing cover | profile picture case]
    func uploadImage(image: UIImage) async throws -> String {
        let storageRef = Storage.storage().reference()
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "InvalidImageData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to JPEG data."])
        }
        
        let imageId = UUID().uuidString
        let imageRef = storageRef.child("images/\(imageId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let downloadURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            imageRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let downloadURL = url {
                        continuation.resume(returning: downloadURL.absoluteString)
                    }
                }
            }
        }
        
        print("Reached the end of upload image function [singular]")
        return downloadURL
    }
    
    // fetch search page content
    func fetchSearchPageContent(completion: @escaping ([Status]) -> Void) {
        //*** for determining when the range of current day to search for statuses
        let now = Date()
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: now)
        let endDay = calendar.date(byAdding: .day, value: 1, to: startDay)
        
        let query = dbStatus
            .whereField("timestamp", isGreaterThanOrEqualTo: startDay)
            // may want to revisit this line for warning triggers
            .whereField("timestamp", isLessThan: endDay as Any)
        
        query.getDocuments { snapshot, error in
            // ** catches errors
            if let error = error {
                print("[Search_Content_DEBUG]: Error fetching documents \(error.localizedDescription)")
                completion([])
                return
            }
            
            //*** checks for existence
            guard let documents = snapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            //** decode documents into Status objects
            let statuses = documents.compactMap { doc -> Status? in
                do {
                    return try doc.data(as: Status.self)
                }
                catch {
                    print("[DEBUG]: Unpacking error \(error.localizedDescription)")
                    return nil
                }
            }
            
            //** possibly daily change of the word?
            let searchResults = statuses.filter { $0.content.contains("#journey") }
            print("This is searchResults from status manager \(searchResults)")
//            self.searchFeedList = searchResults
            completion(searchResults)
        }
    }
    
    // add a comment on a post [creates a comment object in firebase]
    func commentStatus(postId: String, userObject: User, content: String, timestamp: Date) async throws {
        do {
            // Comment object
            let newComment = Comments(id: UUID().uuidString, postId: postId, userId: userObject.id, profilePicture: userObject.profilePicture, username: userObject.username, content: content, timestamp: timestamp)
            
            let commentRef = dbStatus.document(postId)
                .collection("comments")
            
            try commentRef.document(newComment.id).setData(from: newComment)
                
        }
        
        catch {
            print("[DEBUG]: Error creating a comment object \(error.localizedDescription)")
        }
    }
    
    // fetch comments for a status
    func fetchComments(postId: String, completion: @escaping ([Comments]) -> Void) {
        let query = dbStatus
            .document(postId)
            .collection("comments")
        
        // handle completion of comments
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                if let error = error {
                    print("[DEBUG]: Error grabbing/finding comment documents \(error.localizedDescription)")
                }
                completion([])
                return
            }
        }
        
        // for real time updates
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added}) else { return }
            
            var comments = changes.compactMap({ try? $0.document.data(as: Comments.self )})
            
            completion(comments)
        }
    }
    
    // fetch comment count for a status
    func fetchCommentCount(postId: String) async throws -> Int {
        let snapshot = try await dbStatus
            .document(postId)
            .collection("comments")
            .getDocuments()
        
        return snapshot.count
    }
    
}
