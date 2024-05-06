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
    
    //    let user: User
    //
    //    init(user: User) {
    //        self.user = user
    //    }
    
    let dbMessages = Firestore.firestore().collection("Messages")
//    var listener: ListenerRegistration?
    
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
            readStatus: false
        )
        
        // encode the Messages object for firestore
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        // store into firebase for both the currentUser and the chatPartner
        currentUserReference.setData(messageData)
        chatPartnerReference.document(messageId).setData(messageData)
        
        // store into firebase for both the currentUser and chatPartner [recent-message]
        currentUserRecent.setData(messageData)
        chatPartnerRecent.setData(messageData)
    }
    
    // query messages with-in the individual chat window
    func queryMessage(chatPartner: User, completion: @escaping([Messages]) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let query = dbMessages
            .document(currentUserId)
            .collection(chatPartnerId)
            .order(by: "timestamp", descending: false)      // *** revisit the string to ensure it matches our data field in database
        
        //*** adds an event listener to the queried document to determine when new chats are 'added' || when chats are sent from users
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Messages.self) })
            
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
                    // Find the index of the message in the inboxList array
//                    if let index = self.inboxList.firstIndex(where: { $0.fromUser == chatPartnerId }) {
//                        // Replace the message with the updated readStatus
//                        var updatedMessage = self.inboxList[index]
//                        updatedMessage.readStatus = true
//                        self.inboxList[index] = updatedMessage
//                    }
//                    else {
//                        print("[DEBUG]: Message not found in inboxList.")
//                        print("[DEBUG]: Inbox list: \(self.inboxList)")
//                    }
                    
                    print("[DEBUG]: Read status was updated successfully.")
                    print("[DEBUG]: Inbox list: \(self.inboxList)")
                }
            }
    }
    
    
}
