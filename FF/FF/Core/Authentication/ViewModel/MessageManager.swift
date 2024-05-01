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
//    let user: User
//    
//    init(user: User) {
//        self.user = user
//    }
    
    let dbMessages = Firestore.firestore().collection("Messages")
    
    func sendMessage(messageContent: String, toUser user: User) {
        // this will act as the fromUser
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // this will act as the toUser
        let chatPartnerId = user.id
        
        // create a document for the current user with the person they are chatting with || 1 document will represent a chat with 2 users
        let currentUserReference = dbMessages.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerReference = dbMessages.document(chatPartnerId).collection(currentUid)
        
        let messageId = currentUserReference.documentID
        
        // pack the message object
        let message = Messages(
//            messageId: messageId,
            fromUser: currentUid,
            toUser: chatPartnerId,
            timestamp: Date(),
            messageContent: messageContent
        )
        
        // encode the Messages object for firestore
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        // store into firebase for both the currentUser and the chatPartner
        currentUserReference.setData(messageData)
        chatPartnerReference.document(messageId).setData(messageData)
    }
    
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
}
