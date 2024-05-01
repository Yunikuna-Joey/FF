//
//  MessageView.swift
//  FF
//
//

import SwiftUI

struct MessageView: View {
    // [PLAN]: Firebase for chat storage
    // [PLAN]: APN for push notifications
    // [PLAN]:
    
    
    // Array of chat data
    // This should retrieve:
    // [Recipient User, Last message in conversation with Recipient User, time stamp of last message]
    @EnvironmentObject var messageManager: MessageManager
    
    @State private var chatFlag = false
    @State private var composeFlag: Bool = false
    @State private var chatPartner: User?
    
    var body: some View {
        NavigationStack {
            ZStack {
//                let screenSize = UIScreen.main.bounds.size
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        //*** query the messages associated with the current user here
                        ForEach(messageManager.inboxList, id: \.self) { conversation in
                            Text(conversation)
                                .padding()
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
//                if let selectedPartner = chatPartner {
//                    IndividualChatView(chatPartner: $chatPartner)
//                }
                IndividualChatView(chatPartner: $chatPartner)
            }
            .onAppear {
                //** everything here will trigger first [PRIORITY] then main executes
                messageManager.queryInbox { conversations in
                    self.messageManager.inboxList = conversations
                    print("[DEBUG1]: This is the value of inboxList: \(conversations)")
                }
                print("[DEBUG2]: This is the value of inboxList: \(messageManager.inboxList)")
            }
        } // end of NavigationStack
    }

}

#Preview {
    MessageView()
}
