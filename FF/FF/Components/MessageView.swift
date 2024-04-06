//
//  MessageView.swift
//  FF
//
//

import SwiftUI

struct Chat {
    let name: String
    let timestamp: String
    let messageContent: String 
}

struct MessageView: View {
    // who it is
    // when was it
    // what is the message content
    
    // [PLAN]: Firebase for chat storage
    // [PLAN]: APN for push notifications
    // [PLAN]:
    
    
    // Array of chat data
    let chats: [Chat] = [
        Chat(name: "User 1", timestamp: "10:00 AM", messageContent: "Hello"),
        Chat(name: "User 2", timestamp: "10:05 AM", messageContent: "Hi there!"),
        Chat(name: "User 3", timestamp: "10:10 AM", messageContent: "Hey!"),
        // Add more chats as needed
    ]
    
    var body: some View {
        ZStack {
            let screenSize = UIScreen.main.bounds.size
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(chats, id: \.name) { chat in
                        HStack(spacing: 10) {
                            // profile image on the left
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                            
                            // Username and message content
                            VStack(alignment: .leading) {
                                Text(chat.name)
                                    .font(.headline)
                                Text(chat.messageContent)
                            }
                            
                            Spacer()
                            
                            // Timestamp
                            Text(chat.timestamp)
                        } // end of HStack
                        .padding()
                        .background(Color.white)
                        .cornerRadius(1)
                        
                        Divider()
                            .frame(width: screenSize.width * 0.80)
                            .padding(.leading, screenSize.width * 0.20)
                        
                    }
                    Spacer()
                } // end of VStack
            }
            
        } // end of ZStack
    }
}

#Preview {
    MessageView()
}
