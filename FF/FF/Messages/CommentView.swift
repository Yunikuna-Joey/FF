//
//  CommentView.swift
//  FF
//
//

import SwiftUI
import FirebaseAuth

struct CommentView: View {
    let example: Comments = EmptyVariable.EmptyComment
    @EnvironmentObject var statusProcess: StatusProcessView
    @EnvironmentObject var viewModel: AuthView
    
    @State private var commentText: String = ""
    
    let status: Status
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(statusProcess.commentList.sorted(by: {$0.timestamp > $1.timestamp})) { comment in
                        CommentCell(status: status, comment: comment)
                            .padding()
                            .background(
                                ZStack {
                                    Color.white.opacity(0.2)
                                    BlurView(style: .systemMaterial)
                                }
                            )
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding(.vertical, 10)
                        
                        ReplyCell()
                            .padding()
                            .background(
                                ZStack {
                                    Color.white.opacity(0.2)
                                    BlurView(style: .systemMaterial)
                                }
                            )
                            .cornerRadius(20)
                            .shadow(radius: 3)
                            .padding(.leading, 50)
                            .padding(.vertical, 5)
                    }
                    
                } // end of vstack
                .padding()
                
            } // end of scrollView
            .padding(.bottom, 60)
            
            // Holds the reply|| comment button
            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 1)
                    .padding(.vertical, 5)
                    .padding()
                
                TextField("Comment", text: $commentText, axis: .vertical)
                    .padding(12)
                    // this is making room for send button
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .font(.subheadline)
                
                Button(action: {
                    print("Post comment button")
                    if let currentUserObject = viewModel.currentSession {
                        Task {
                            do {
                                try await statusProcess.commentStatus(
                                    postId: status.id,
                                    userObject: currentUserObject,
                                    content: commentText,
                                    timestamp: Date()
                                )
                                commentText = ""
                            }
                            
                            catch {
                                print("[Front_End_DEBUG]: There was an error posting your comment.")
                            }
                        }
                        
                    }
                    
                    else {
                        print("[DEBUG]: Current session is nil so commenting function does not work.")
                    }
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
                .padding(.trailing, 20)
                .disabled(commentText.isEmpty)
                .opacity(commentText.isEmpty ? 0.3 : 1.0)
                
            } // end of zstack
            .padding(.top, 10)
            .padding(.horizontal)
            
        } // end of zstack
        .onAppear {
            statusProcess.commentList.removeAll()
            
            statusProcess.fetchComments(postId: status.id) { comments in
                for comment in comments {
                    statusProcess.commentList.append(comment)
                }
            }
        }
        
    } // end of body
}

struct CommentCell: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    @State private var likeCount: Int = 0
    @State private var likeFlag: Bool = false
    
    @State private var commentCount: Int = 0
    @State private var commentFlag: Bool = false
    
    let status: Status
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
                    .foregroundStyle(Color.primary)
                
                Spacer()
            }
            .padding(.top, 10)
            
            // icons for liking and replying
            HStack(spacing: 20) {
                //** Like button
                Button(action: {
                    Task {
                        likeCount = try await statusProcess.likeComment(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "", commentId: comment.id)
                        likeFlag.toggle()
                    }
                }) {
                    Image(systemName: "heart")
                        .foregroundStyle(Color.gray)
                    
                    Text("\(likeCount)")
                        .foregroundStyle(Color.primary)
                }
                
                //** Comment / Reply button
                Button(action: {
                    print("Comment/reply button in Comment View")
                }) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundStyle(Color.gray)
                    
                    Text("\(commentCount)")
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                    
                // Drop down Button for displaying other replies to this specific comment
                Button(action: {
                    print("This will act as the drop down menu for other replies")
                }) {
                    Image(systemName: "chevron.down.circle.fill")
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.top, 10)
        }
        .onAppear {
            Task {
                // initialize all the like counts for each status
                likeCount = try await statusProcess.fetchLikeCount(postId: comment.id)
                likeFlag = try await statusProcess.fetchLikeFlag(postId: comment.id, userId: Auth.auth().currentUser?.uid ?? "")
                
                // initialize comment count for each status
                commentCount = try await statusProcess.fetchCommentCount(postId: comment.id)
            }
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

// This will be our cell that holds replies
struct ReplyCell: View {
    var body: some View {
        
        // parent vstack
        VStack {
            
            // This will hold profile picture and username
            HStack {
                
                // pfp of the user who replied
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(Color.blue)
                    .frame(width: 25, height: 25)
                
                // username of the user who replied
                Text("aaaaaaaaaaaaaaaaaaaaa")
                    .font(.system(size: 15))
                    
                Spacer()
                
                Text("5 mins ago")
                    .foregroundStyle(Color.gray)
                    .font(.caption)
                    
            } // end of hstack
            
            // act as body
            HStack {
                // content of the reply
                Text("I am a replier!")
                    .font(.system(size: 13))
                    .padding(.vertical, 5)
                
                Spacer()
                
                HStack {
                    // like button
                    Button(action: {
    //                    Task {
    //                        likeCount = try await statusProcess.likeComment(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "", commentId: comment.id)
    //                        likeFlag.toggle()
    //                    }
                        print("Like button")
                    }) {
                        Image(systemName: "heart")
                            .foregroundStyle(Color.gray)
                        
    //                    Text("\(likeCount)")
    //                        .foregroundStyle(Color.primary)
                    }
                    
                    //** Comment / Reply button
                    Button(action: {
                        print("Comment/reply button in Comment View")
                    }) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .foregroundStyle(Color.gray)
                        
    //                    Text("\(commentCount)")
    //                        .foregroundStyle(Color.primary)
                    }
                }
            }
            
            
        } // end of vstack
            
    }
}

//#Preview {
//    CommentView()
//}
