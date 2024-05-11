//
//  IndividualChatView.swift
//  FF
//
//

import SwiftUI
import FirebaseAuth

struct ChatCellView: View {
    let currentUserFlag: Bool
    let message: Messages
    
    var body: some View {
        // This will style / format the messages that are from the current user
        if currentUserFlag {
            HStack {
                // timestamp
                Text(formatTimeAgo(from: message.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                
                // Push to the right
                Spacer()
                
                // Message content held in its own Hstack
                HStack {
                    Text(message.messageContent)
                        .padding()
//                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .trailing)
                }
                .background(Color.blue)
                .cornerRadius(25)
                .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .trailing)

                
                // profile picture
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(Color.yellow)
                    .frame(width: 40, height: 40)
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 5)
        }
        
        // This will style / format the messages are are NOT from the current user [other users]
        else {
            HStack {
                // recipient picture
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(Color.orange)
                    .frame(width: 40, height: 40)       // needs to be different for different screen sizes
                    .padding(.horizontal, 5)
                
                HStack{
                    Text(message.messageContent)
                        .padding()
//                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                }
                //                        .frame(maxWidth: 256)
                .background(Color.gray)
                .cornerRadius(25)
                .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                
                // timestamp
                Text(formatTimeAgo(from: message.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                
                // push to the left
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
    
    // helper function to achieve time stamps associated with status's
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

struct IndividualChatView: View {
    // need to pass in curr user and recipient user pictures
    @EnvironmentObject var messageManager: MessageManager
    @EnvironmentObject var viewModel: AuthView

    @State private var messageContent: String = ""
    @Binding var chatPartner: User?
    @State var loadingMessageFlag: Bool = false
    @State private var topFlag: Bool = false
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var botFlag: Bool = false
    
    
    init(chatPartner: Binding<User?>) {
        _chatPartner = chatPartner
    }
    
    var body: some View {
        VStack {
            Spacer()
            
                
            // Scroll View for message content
            ScrollViewWithDelegate(scrolledToTop: $topFlag, scrollProxy: $scrollProxy, showsIndicators: false, shouldScrollBottom: botFlag) {
//            ScrollView(showsIndicators: false) {
                
                //*** modify this vstack to determine if lazy is needed here
                VStack {
                    //** loading the inital 10 messages in its cells
                    ForEach(messageManager.messageList, id: \.id) { message in
                        ChatCellView(currentUserFlag: message.currentUserFlag, message: message)
                    }
                    
                } // end of lazyvstack
                
            } // end of scrollViewWithDelegate
            .onChange(of: topFlag) {
                
                // need this check so that we do not load multiple instances of 1 query into the messageList [if already loading, don't load more]
                guard !loadingMessageFlag else { return }
            
                print("Top was reached")
               
               // Set loading flag to true to prevent multiple calls
                loadingMessageFlag = true
                
                if let chatPartner = chatPartner {
                    messageManager.queryMoreMessages(chatPartner: chatPartner) { messages in
                        for message in messages {
                            messageManager.messageList.insert(message, at: 0)
                        }
                        
                        // delay the toggle of booleans because of edge case where instances were happening within one time-frame
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            loadingMessageFlag = false
                            topFlag = false
                            botFlag = true
                        }
                    }
                }
                
            }

            
            //*** Text area for message content to be received || This does not need to be modified for dynamic user loading
            ZStack(alignment: .trailing) {
                // axis parameter allows for the textfield to expand vertically
                TextField("Enter your message here", text: $messageContent, axis: .vertical)
                    .padding(12)
                    // this is making room for send button
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .font(.subheadline)
                
                Button(action: {
                    print("This will act as the send button")
                    //*** This is unwrapping the chatPartner
                    if let partner = chatPartner {
                        messageManager.sendMessage(messageContent: messageContent, toUser: partner)
                        print("Testing if this statement is triggered")
                        // clear the message in the textField after function successfully runs
                        messageContent = ""
                    }
                    else {
                        print("This is the value of chatPartner at the time of button press \($chatPartner)")
                    }
                }) {
                    Text("Send")
                        .fontWeight(.semibold)
                }
                .padding()
            }
            .padding()
            
        }
        .navigationTitle("\(chatPartner?.username ?? "Chat")")
        // remove any previous messages within a conversation && populate the messageList to load
        .onAppear {
            //** attempt to clear the message list
            messageManager.messageList.removeAll()
            // Validates that a registered user was tapped on then retreives the messages
            if let chatPartner = chatPartner {
                populateMessageList(chatPartnerObject: chatPartner)
            }
            
            print("*****************ON APPEAR ********************")
        }
        // mark the most recent message as read upon leaving the conversationView
        .onDisappear {
            if let chatPartner = chatPartner {
                messageManager.updateReadStatusTest(currUserId: Auth.auth().currentUser?.uid ?? "", chatPartnerId: chatPartner.id)
            }
        }
        
    }
    
    func populateMessageList(chatPartnerObject: User) {
        // This function call must take a specific user []
        if messageManager.messageList.isEmpty {
            messageManager.queryMessage(chatPartner: chatPartnerObject) { messages in
                // This will populate the messageList variable in messageManager
                // ==>
                // then we will iterate through the messageManager.messageList in MAIN to retrieve the data within the messageList
                for message in messages {
                    messageManager.messageList.append(message)
                }
                print("This is the value of messageList \(messageManager.messageList)")
            }
        }
    }
    
    // helper function to achieve time stamps associated with status's
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

//struct IndividualChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        let chatPartner = User(id: "admin", username: "test-user", databaseUsername: "test-user", firstName: "test", lastName: "user", email: "test@email.com", imageArray: [""], profilePicture: "")
//        IndividualChatView(chatPartner: chatPartner)
//    }
//}

