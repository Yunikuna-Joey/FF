//
//  MessageView.swift
//  FF
//
//

import SwiftUI
import FirebaseAuth

struct InboxCellView: View {
    //**** This is to utilize the function to convert ID -> User
    @EnvironmentObject var followManager: FollowingManager
    @EnvironmentObject var messageManager: MessageManager

    @State var username = "" // blank on initial
    @State var partnerPicture = ""
    @State var chatFlag: Bool = false
    @State var chatPartnerObjectId: String = ""
    @State private var chatPartnerObject: User?

    let message: Messages
    
    var body: some View {
        NavigationStack {
            Button(action: {
                chatFlag = true
                // need a function to update the database with the read status 
                messageManager.updateReadStatusTest(currUserId: Auth.auth().currentUser?.uid ?? "", chatPartnerId: chatPartnerObjectId)
//                messageManager.updateReadStatus(currUserId: Auth.auth().currentUser?.uid ?? "")
            }) {
                HStack(spacing: 10) {
                    //** This will be conditionally representing whether or not the message has been read or not
                    if !message.readStatus {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                            .padding(.trailing, 8)
                    }
                    
                    
                    // this will represent the chat partner profile picture
                    if partnerPicture.isEmpty {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.blue)
                    }
                    
                    else {
                        Image(partnerPicture)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.blue)
                    }
                    
                    // this will represent the name of the chat partner AND most recent message in the conversation
                    VStack(alignment: .leading) {
                        Text(username)
                            .font(.headline)
                        
                        Text(message.messageContent)
                            .foregroundStyle(Color.gray)
                    }
                    
                    // push in the left direction
                    Spacer()
                    
                    // timestamp
                    Text(formatTimeAgo(from: message.timestamp))
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    
                } // end of hstack
                .onAppear {
                    Task {
                        let chatPartnerId = message.fromUser == Auth.auth().currentUser?.uid ? message.toUser : message.fromUser
                        if let user = try await followManager.getUserById(userId: chatPartnerId) {
                            username = user.username
                            partnerPicture = user.profilePicture
                            chatPartnerObject = user
                            chatPartnerObjectId = user.id
                            
//                            print("[DEBUG2]: We are inside of the Task within inboxCellView")
//                            print("This is the value of username: \(username)")
                        }
//                        print("[DEBUG2]: We are outside of the Task within inboxCellView")
                    }
                }
            } // end of button
            .buttonStyle(PlainButtonStyle())
            
        } // end of NavigationStack
        .navigationDestination(isPresented: $chatFlag) {
            IndividualChatView(chatPartner: $chatPartnerObject)
        }
    }
    
    func formatTimeAgo(from date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        guard let formattedString = formatter.string(from: date, to: Date()) else {
            return "Unknown"
        }
        
        return formattedString + " ago"
    }
}

struct MessageView: View {
    // [PLAN]: Firebase for chat storage
    // [PLAN]: APN for push notifications
    
    
    // Array of chat data
    // This should retrieve:
    // [Recipient User, Last message in conversation with Recipient User, time stamp of last message]
    @EnvironmentObject var messageManager: MessageManager
    
    @State private var chatFlag = false
    @State private var composeFlag: Bool = false
    @State private var chatPartner: User?
    @State private var queryInboxFlag: Bool = false
    
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        //*** query the messages associated with the current user here
//                        ForEach(messageManager.inboxList, id: \.self) { conversation in
                        ForEach(messageManager.inboxList.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { conversation in
                            InboxCellView(message: conversation)
                                .padding()
                            
                            Divider()
                                .frame(width: screenSize.width * 0.80)
                                .padding(.leading, screenSize.width * 0.20)
                        }
                        
                        Spacer()
                    } // end of VStack
                }
                .navigationBarTitle("Chats")
                .navigationBarItems(trailing:
                    Button(action: {
                        // Action when the button is tapped
                        print("This will act as the compose message button")
                        composeFlag = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    .sheet(isPresented: $composeFlag) {
                        ComposeMessageView(composeFlag: $composeFlag, chatFlag: $chatFlag, chatPartner: $chatPartner)
                    }
                )
                
            } // end of ZStack
            .navigationDestination(isPresented: $chatFlag) {
                //** using optional unwrapping is not displaying the hardcoded messages that I have set up in IndividualChatView
                IndividualChatView(chatPartner: $chatPartner)
            }
            .onAppear {
                //** everything here will trigger first [PRIORITY] then main executes

                //** only run queryInbox when the list is empty, but within the function, the event listener is always on ==> provides the ability to listen for document changes [i.e new message.. etc]
                if messageManager.inboxList.isEmpty && !queryInboxFlag {
                    messageManager.queryInboxList() { message in
                        self.messageManager.inboxList.append(contentsOf: message)
                    
                        queryInboxFlag = true
                        print("Ran inbox function. We should only run this portion once at the beginning and nothing else. The event listener should be taking care of any message updates")
                    }
                }
            }
        } // end of NavigationStack
    }

}

#Preview {
    MessageView()
}
