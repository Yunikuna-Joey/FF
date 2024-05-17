//
//  MessageManager.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MessageManager: ObservableObject {
    // This will hold an array of all the messages
    @Published var messageList = [Messages]()
    
    //**** Associated with the original function of queryInboxView
    @Published var documentChanges = [DocumentChange]()
    
    //***** Associated with the function of queryInboxList
    @Published var inboxList = [Messages]()
    
    let dbMessages = Firestore.firestore().collection("Messages")
    let pageSize = 10
    var cursor: DocumentSnapshot?
    
    // Send messages with-in individual chat view
    func sendMessage(messageContent: String, toUser user: User) {
        // this will act as the fromUser
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // this will act as the toUser
        let chatPartnerId = user.id
        
        // create a document for the current user with the person they are chatting with || 1 document will represent a chat with 2 users
        let currentUserReference = dbMessages.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerReference = dbMessages.document(chatPartnerId).collection(currentUid)
        
        // write the most recent message into its own data field
        let currentUserRecent = dbMessages.document(currentUid).collection("recent-message").document(chatPartnerId)
        let chatPartnerRecent = dbMessages.document(chatPartnerId).collection("recent-message").document(currentUid)
        
        let messageId = currentUserReference.documentID
        
        // pack the message object
        let message = Messages(
            // messageId: messageId,
            fromUser: currentUid,
            toUser: chatPartnerId,
            timestamp: Date(),
            messageContent: messageContent,
            readStatus: true // readStatus should be true for the user sending the message
        )
        
        // encode the Messages object for firestore
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        // store into firebase for both the currentUser and the chatPartner
        currentUserReference.setData(messageData)
        chatPartnerReference.document(messageId).setData(messageData)
        
        // store into firebase for both the currentUser and chatPartner [recent-message]
        currentUserRecent.setData(messageData)
        chatPartnerRecent.setData(messageData) { error in
            if error == nil {
                let chatPartnerRecentMsg = self.dbMessages.document(chatPartnerId).collection("recent-message").document(currentUid)
                chatPartnerRecentMsg.updateData(["readStatus": false])
                print("Triggered the read status update for the sender?")
            }
        }
    }
    
    // base function
//    func queryMessage(chatPartner: User, completion: @escaping([Messages]) -> Void) {
//        queryMessage(chatPartner: chatPartner, prevDocument: nil, completion: completion)
//    }
    
    // query messages with-in the individual chat window ***OFFICIAL [overloaded function]
    func queryMessage(chatPartner: User, completion: @escaping([Messages]) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        // first query
        let query = dbMessages
            .document(currentUserId)
            .collection(chatPartnerId)
        // if false then linear order
        // if true then reverse linear order
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
        

        //** analyze the document || first query
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                
                if let error = error {
                    print("[DEBUG]: There was an error with the initial 10 documents \(error.localizedDescription)")
                }
                return
            }
            
            //*** remove this if any errors at first
            guard !snapshot.isEmpty else {
                self.cursor = nil
                completion([])
                return
            }
            
            if snapshot.count == 0 {
                self.cursor = nil
                completion([])
                return
            }
            else {
                self.cursor = snapshot.documents.last
            }
        }
        
        
        //*** adds an event listener to the queried document to determine when new chats are 'added' || when chats are sent from users
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Messages.self) })
            
            messages.reverse()
            completion(messages)
        }
    }
    
    // *** testing loading more messages
    func queryMoreMessages(chatPartner: User, completion: @escaping([Messages]) -> Void) {
        guard let cursor = cursor else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let nextQuery = dbMessages
            .document(currentUserId)
            .collection(chatPartner.id)
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .start(afterDocument: cursor)
        
        nextQuery.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                completion([])
                if let error = error {
                    print("[DEBUG]: There was an error with the next set of messages \(error.localizedDescription)")
                }
                return
            }
            
            guard !snapshot.isEmpty else {
                self.cursor = nil
                completion([])
                return
            }
            
            if snapshot.count == 0 {
                self.cursor = nil
                completion([])
                return
            }
            else {
                self.cursor = snapshot.documents.last
            }
        }
        
        nextQuery.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Messages.self) })
            
//            messages.reverse()
            completion(messages)
        }
    }
    
    //*** Keep this as the original function
    func queryInboxView() {
        // This will query information using the currentUser id so im pretty sure we do not need to pass in the parameter for a current User within function
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = dbMessages
            .document(uid)
            .collection("recent-message")
            .order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({
                $0.type == .added || $0.type == .modified
            }) else { return }
            
            self.documentChanges = changes
        }
    }
    
    //**** Another testing function [official]
    func queryInboxList(completion: @escaping([Messages]) -> Void) {
        // grabs the current user id when function is called
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // This should query the Messages collection, currentUserId document, then go into the recent message
        // ** This will represent messages sent TO the currentUser
        let query = dbMessages
            .document(currentUserId)
            .collection("recent-message")
            .order(by: "timestamp", descending: true)
        
        // ** This will represent messages sent BY the currentUser
        let sentMessages = dbMessages
            .document(currentUserId)
            .collection("recent-message")
            .whereField("fromUser", isEqualTo: currentUserId)
            .order(by: "timestamp", descending: true)
        
        // add in a event listener within the recent messages field to update concurrently the most-recent message
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({
                $0.type == .added || $0.type == .modified
            }) else { return }
            
            var messages = changes.compactMap({ try? $0.document.data(as: Messages.self) })
            completion(messages)
        }
        
        // Event listener for sent messages to update inbox cells
        sentMessages.addSnapshotListener { snapshot, _ in
            //*** play with the filter in event listener
            // current logic: messages sent by curr User do not have to be read, i.e
            guard let changes = snapshot?.documentChanges.filter({
                $0.type == .added
            }) else { return }
            
            var messages = changes.compactMap({ try? $0.document.data(as: Messages.self) })
            completion(messages)
        }
    }
    
    
    //*** update the read status of a particular message
    func updateReadStatus(currUserId: String) {
        let query = dbMessages
            .document(currUserId)
            .collection("recent-message")
        // ** we need to include the chatpartner here as well [you got this]
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
        
        //** attempt to grab the correct firebase document
        query.getDocuments { snapshot, error in
            // Step 1: Determine if there is an error retrieving initial documents from query
            if let error = error {
                print("[DEBUG]: Error getting documents: \(error.localizedDescription)")
                return
            }
            
            // Step 2: Determine if there is a message within the recent-message field
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("[DEBUG]: No recent messages were found")
                return
            }
            
            let recentMessageId = documents[0].documentID
            //            let recentMessageData = documents[0].data()
            
            // Step 3: go into the conversation with the current user and their chat partner
            self.dbMessages
                .document(currUserId)
                .collection("recent-message")
                .document(recentMessageId)
            // ** This updates the recent message field
                .updateData(["readStatus": true]) { error in
                    // Check if there was an error in the process of updating the read status
                    if let error = error {
                        print("[DEBUG]: Error updating read status: \(error.localizedDescription)")
                    }
                    // Debug statement to check if the process was successful
                    else {
                        print("[DEBUG]: Read status updated successfully.")
                        self.dbMessages
                            .document(currUserId)
                            .collection("recent-message")
                            .document(recentMessageId)
                            .getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let readStatus = document.get("readStatus") ?? "Unavailable"
                                    print("[DEBUG]: Read status updated successfully. New read status: \(readStatus)")
                                } else {
                                    print("[DEBUG]: Document does not exist")
                                }
                            }
                    }
                } // self.dbMessages
            
            
        } // end of query line
    } // end of function
    
    //*** current implementation of updateReadStatus
    func updateReadStatusTest(currUserId: String, chatPartnerId: String) {
        dbMessages
            .document(currUserId)
            .collection("recent-message")
            .document(chatPartnerId)
            .updateData(["readStatus" : true]) { error in
                // check if there was an error
                if let error = error {
                    print("[DEBUG]: Error updating the readStatus \(error.localizedDescription)")
                }
                else {
                    print("[DEBUG]: Read status was updated successfully.")
                    print("[DEBUG]: Inbox list: \(self.inboxList)")
                }
            }
    }
}
