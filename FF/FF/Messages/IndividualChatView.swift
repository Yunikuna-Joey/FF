//
//  IndividualChatView.swift
//  FF
//
//

import SwiftUI

struct IndividualChatView: View {
    // need to pass in curr user and recipient user pictures
    // need a timestamp

    @State private var messageContent: String = ""
    
    let username = "Testing Username"
    let longText = "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..', comes from a line in section 1.10.32."
    let shortText = "What are you hitting today?"
   
    var body: some View {
        VStack {
            // This is the case for current user
            HStack {
                // Push to the right
                Spacer()
                
                // Message content held in its own Hstack
                HStack {
                    Text(shortText)
                        .padding()
                }
                .frame(maxWidth: 256)           // needs to be different for different screen sizes
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
                .frame(maxWidth: 256)
                .background(Color.gray)
                .cornerRadius(25)
                
                // push to the left
                Spacer()
            }
            .padding(.vertical, 5)
            
        }
        .navigationTitle("\(username)")
    }
}

#Preview {
    IndividualChatView()
}
