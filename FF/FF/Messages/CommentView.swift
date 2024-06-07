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
    @State private var replyVisibility: [String: Bool] = [:] // [commentId: True/False]
    
    //** variable to track the comment button to toggle between functions [declared on the same line to show they work together]
    @State private var replyFunctionFlag: Bool = false; @State private var replyCommentObject: Comments? = nil
    
    let status: Status
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(statusProcess.commentList.sorted(by: {$0.timestamp > $1.timestamp})) { comment in
                        
                        // Comment cell
                        CommentCell(
                            showReplyFlag: Binding(
                                get: { replyVisibility[comment.id] ?? false },
                                set: { replyVisibility[comment.id] = $0 }
                            ),
                            replyFunctionFlag: $replyFunctionFlag,
                            replyCommentObject: $replyCommentObject,
                            status: status,
                            comment: comment
                        )
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
                        // experiment with this line [might be needed later]
//                            .id(comment.id)
                        
                        //*** Conditional Reply flag here [revisit when we finish reply logic]
                        if replyVisibility[comment.id] ?? false {
                            ForEach(statusProcess.replyList.sorted(by: { $0.timestamp > $1.timestamp })) { replyObject in
                                ReplyCell(reply: replyObject)
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
                        }
                        
                    } // end for loop
                    
                } // end of vstack
                .padding()
                
            } // end of scrollView
            .padding(.bottom, 60)
            
            // Holds the reply|| comment button
            ZStack(alignment: .trailing) {
                // Container to handle the username overlay and text field
                HStack {
                    if replyFunctionFlag, let commentObject = replyCommentObject {
                        Button(action: {
                            replyFunctionFlag = false
                            replyCommentObject = nil
                           //** might need to add one for dynamic username...
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.gray)
                                .padding(.leading, 8)
                                .font(.caption)
                        }
                        // Username overlay
                        Text("\(commentObject.username)")
                            .foregroundStyle(Color.blue)
                            .background(Color(.systemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                  
                    
                    // TextField with padding to account for the username
                    TextField("Comment", text: $commentText, axis: .vertical)
                        .padding(12)
                        .padding(.trailing, 48)  // space for the send button
//                        .padding(.leading, replyingToUsername != nil ? 8 : 12)  // adjust leading padding based on username presence
                        .background(Color(.systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .font(.subheadline)
                }
                .background(Color(.systemGroupedBackground))  // to ensure the background color consistency
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Send button
                Button(action: {
                    print("Post comment button")
                    if let currentUserObject = viewModel.currentSession {
                        Task {
                            do {
                                if replyFunctionFlag, let commentObject = replyCommentObject {
                                    try await statusProcess.replyComment(
                                        postId: status.id,
                                        userObject: currentUserObject,
                                        content: commentText,
                                        commentId: commentObject.id
                                    )
                                } 
                                else {
                                    try await statusProcess.commentStatus(
                                        postId: status.id,
                                        userObject: currentUserObject,
                                        content: commentText,
                                        timestamp: Date()
                                    )
                                }
                                
                                // Reset the values
                                commentText = ""
                                replyFunctionFlag = false
                                replyCommentObject = nil
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
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
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
    
    @Binding var showReplyFlag: Bool
    // This will determine whether or not the reply button was pressed, and which commentId was pressed.
    @Binding var replyFunctionFlag: Bool; @Binding var replyCommentObject: Comments?; /*@Binding var viewReplyObjects: Comments?*/
    
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
                Text(ConstantFunction.formatTimeAgo(from: comment.timestamp))
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
                    replyFunctionFlag = true
                    replyCommentObject = comment
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
                    showReplyFlag.toggle()
                    // ** populate some kind of list with reply data?
                    Task {
                        statusProcess.replyList.removeAll()
                        statusProcess.fetchRepliesUnderComment(postId: status.id, commentId: comment.id) { replyObjects in
                            for replyObject in replyObjects {
                                statusProcess.replyList.append(replyObject)
                                print("This is the value of replyList: \(statusProcess.replyList)")
                            }
                            
                        }
                    }
                    
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
        
    } // end of body
    
}

// This will be our cell that holds replies
struct ReplyCell: View {
    let reply: Comments
    
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
                Text("\(reply.username)")
                    .font(.system(size: 15))
                    
                Spacer()
                
                Text(ConstantFunction.formatTimeAgo(from: reply.timestamp))
                    .foregroundStyle(Color.gray)
                    .font(.caption)
                    
            } // end of hstack
            
            // act as body
            HStack {
                // content of the reply
                Text(reply.content)
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
