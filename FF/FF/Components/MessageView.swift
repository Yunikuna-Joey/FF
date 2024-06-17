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
                messageManager.updateReadStatusTest(currUserId: Auth.auth().currentUser?.uid ?? "", chatPartnerId: chatPartnerObjectId)
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
                        if let chatPartnerObject = chatPartnerObject {
                            AsyncImage(url: URL(string: chatPartnerObject.profilePicture)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                    
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    
                                case .failure:
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                @unknown default:
                                    EmptyView()
                                } // end of switch
                                
                            } // end of async image
                        }
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
                    Text(ConstantFunction.formatTimeAgo(from: message.timestamp))
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    
                } // end of hstack
                .padding()
                .background(
                    ZStack {
                        Color.white.opacity(0.2)
                        BlurView(style: .systemMaterial)
                    }
                )
                .cornerRadius(10)
                .shadow(radius: 5)
                .onAppear {
                    Task {
                        let chatPartnerId = message.fromUser == Auth.auth().currentUser?.uid ? message.toUser : message.fromUser
                        if let user = try await followManager.getUserById(userId: chatPartnerId) {
                            username = user.username
                            partnerPicture = user.profilePicture
                            chatPartnerObject = user
                            chatPartnerObjectId = user.id
                        }
                    }
                }
            } // end of button
            .buttonStyle(PlainButtonStyle())
            
        } // end of NavigationStack
        .navigationDestination(isPresented: $chatFlag) {
            IndividualChatView(chatPartner: $chatPartnerObject)
        }
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
    
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        NavigationStack {
            ZStack {
                BackgroundView()
                
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
//            .background(
//                BackgroundView()
//            )
            .navigationDestination(isPresented: $chatFlag) {
                //** using optional unwrapping is not displaying the hardcoded messages that I have set up in IndividualChatView
                IndividualChatView(chatPartner: $chatPartner)
            }
            .onAppear {
                //** only run queryInbox when the list is empty, but within the function, the event listener is always on ==> provides the ability to listen for document changes [i.e new message.. etc]
                if messageManager.inboxList.isEmpty {
                    messageManager.queryInboxList() { message in
                        // this is going in one by one
                        for element in message {
                            if let index = messageManager.inboxList.firstIndex(where: { $0.fromUser == element.fromUser }) {
                                messageManager.inboxList[index] = element
                            } 
                            else {
                                messageManager.inboxList.append(element)
                            }
                        } // end of for loop
                    
                    } // end of variable unwrapping
                    
                } // end of if statement
                
            } // end of onAppear closure
            
        } // end of NavigationStack
    }

}

#Preview {
    MessageView()
}
