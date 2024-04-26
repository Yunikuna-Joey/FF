//
//  IndividualChatView.swift
//  FF
//
//

import SwiftUI

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
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .trailing)
                }
                /*.frame(maxWidth: 256)    */       // needs to be different for different screen sizes
                .background(Color.blue)
                .cornerRadius(25)
                
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
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                }
                //                        .frame(maxWidth: 256)
                .background(Color.gray)
                .cornerRadius(25)
                
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
    @State private var chatPartner: User?
    
    //*** This will need to be added in later
//    let user: User

    
    let username = "Testing Username"
    let longText = "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..', comes from a line in section 1.10.32."
    let shortText = "What are you hitting today?"
    
    let timestamp = "1:40PM"
    
    var body: some View {
        VStack {
            Spacer()
            // Scroll View for message content
            ScrollView(showsIndicators: false) {
                VStack {
                    // This is the case for current user
                    HStack {
                        // timestamp
                        Text(timestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        
                        // Push to the right
                        Spacer()
                        
                        // Message content held in its own Hstack
                        HStack {
                            Text(longText)
                                .padding()
                        }
                        /*.frame(maxWidth: 256)    */       // needs to be different for different screen sizes
                        .background(Color.blue)
                        .cornerRadius(25)
                        
                        // profile picture
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundStyle(Color.yellow)
                            .frame(width: 40, height: 40)
                            .padding(.horizontal, 5)
                    }
                    .padding(.vertical, 5)
                
                
                    // This is the case for recipient user
                    HStack {
                        // recipient picture
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundStyle(Color.orange)
                            .frame(width: 40, height: 40)       // needs to be different for different screen sizes
                            .padding(.horizontal, 5)
                        
                        HStack{
                            Text(shortText)
                                .padding()
                        }
                        //                        .frame(maxWidth: 256)
                        .background(Color.gray)
                        .cornerRadius(25)
                        
                        // timestamp
                        Text(timestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        
                        // push to the left
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    
                }
            }
            
            // Text area for message content to be received
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
//                    messageManager.sendMessage(messageContent: messageContent, toUser: <#T##User#>)
                }) {
                    Text("Send")
                        .fontWeight(.semibold)
                }
                .padding()
            }
            .padding()
            
        }
        .navigationTitle("\(username)")
        .onAppear {
            
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

struct IndividualChatView_Previews: PreviewProvider {
    static var previews: some View {
        IndividualChatView()
    }
}

