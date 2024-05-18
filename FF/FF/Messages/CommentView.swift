//
//  CommentView.swift
//  FF
//
//

import SwiftUI

struct CommentView: View {
    let example: Comments = Comments(id: "imagine", postId: "Test1", userId: "admin", profilePicture: "", username: "Testing Offline User", content: "Amazing Post!", timestamp: Date())
    
    @State private var commentText: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ScrollView(showsIndicators: false) {
                VStack {
                    CommentCell(comment: example)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    
                    CommentCell(comment: example)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    
                    CommentCell(comment: example)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                } // end of vstack
                .padding()
                
            } // end of scrollView
            
            // Holds the reply|| comment button
            ZStack(alignment: .trailing) {
                TextField("Comment", text: $commentText, axis: .vertical)
                    .padding(12)
                    // this is making room for send button
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .font(.subheadline)
                
                Button(action: {
                    print("Post comment button")
                }) {
                    Image(systemName: "arrow.up.forward.app")
                        .foregroundStyle(Color.white)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.75))
                        .frame(width: 50, height: 35)
                        .padding()
                )
                .padding(.trailing, 25)
            } // end of zstack
            .padding()
            
        } // end of zstack
    } // end of body
}

struct CommentCell: View {
    let comment: Comments
    
    var body: some View {
        VStack {
            HStack {
                // pfp
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.blue)
                
                // username
                Text(comment.username)
                    .font(.system(size: 15, weight: .regular, design: .default))
                
                Spacer()
                
                // timestamp
                Text(formatTimeAgo(from: comment.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // content
            HStack {
                Text(comment.content)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(Color.purple)
                
                Spacer()
            }
            .padding(.top, 10)
            
            // icons for liking and replying
            HStack(spacing: 20) {
                //** Like button
                Button(action: {
                    print("Like button in Comment View")
                }) {
                    Image(systemName: "heart")
                        .foregroundStyle(Color.black)
                }
                
                //** Comment / Reply button
                Button(action: {
                    print("Comment/reply button in Comment View")
                }) {
                    Image(systemName: "bubble")
                        .foregroundStyle(Color.black)
                }
                
                Spacer()
            }
            .padding(.top, 10)
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

#Preview {
    CommentView()
}
