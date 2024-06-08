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
    @State private var selectedComment: String? = nil
    @State private var createReplyCell: Bool = false; @State private var createReplyReplyCell: Bool = false; @State private var parentCommentId: String? = nil
    
    let status: Status
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(statusProcess.commentList.sorted(by: {$0.timestamp > $1.timestamp})) { comment in
                        
                        // Comment cell
                        CommentCell(
                            showReplyFlag: Binding(
                                get: { replyVisibility[comment.id] ?? false },
                                set: { replyVisibility[comment.id] = $0 }
                            ),
                            replyFunctionFlag: $replyFunctionFlag,
                            commentCellCommentObject: $replyCommentObject,
                            selectedComment: $selectedComment,
                            createReplyCell: $createReplyCell,
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
                        
                        //*** Conditional Reply flag here [revisit when we finish reply logic]
                        if replyVisibility[comment.id] ?? false {
                            if let repliesDict = statusProcess.repliesDict[comment.id] {
                                // Flatten the nested dictionary structure
                                let sortedReplies = repliesDict.values.sorted(by: { $0.timestamp < $1.timestamp })
                                
                                ForEach(sortedReplies, id: \.id) { replyObject in
                                    ReplyCell(
                                        parentStatus: status,
                                        parentComment: comment,
                                        reply: replyObject,
                                        replyFunctionFlag: $replyFunctionFlag,
                                        replyCellCommentObject: $replyCommentObject,
                                        selectedComment: $selectedComment,
                                        createReplyReplyCell: $createReplyReplyCell,
                                        parentCommentId: $parentCommentId
                                    )
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
                                    
                                    // Fetch and display nested replies
                                    if let nestedRepliesDict = statusProcess.repliesDict[replyObject.id] {
                                        let nestedReplies = nestedRepliesDict.values.sorted(by: { $0.timestamp < $1.timestamp })
                                        
                                        ForEach(nestedReplies, id: \.id) { nestedReplyObject in
                                            ReplyCell(
                                                parentStatus: status,
                                                parentComment: comment,
                                                reply: nestedReplyObject,
                                                replyFunctionFlag: $replyFunctionFlag,
                                                replyCellCommentObject: $replyCommentObject,
                                                selectedComment: $selectedComment,
                                                createReplyReplyCell: $createReplyReplyCell,
                                                parentCommentId: $parentCommentId
                                            )
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
                                }
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
                        HStack(spacing: 10) {
                            Button(action: {
                                replyFunctionFlag = false
                                replyCommentObject = nil
                                selectedComment = nil
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, 8)
                                    .font(.caption)
                            }
                            
                            // Username overlay
                            Text("\(commentObject.username)")
                                .foregroundStyle(Color.primary)
                        }
                        .padding(.trailing, 10)
                        .padding(.vertical, 5)
                        .foregroundStyle(Color.primary)
                        .background(Color.blue.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.leading, 5)
                    }
                  
                    
                    // TextField with padding to account for the username
                    TextField("Comment", text: $commentText, axis: .vertical)
                        .padding(12)
                        .padding(.trailing, 48)  // space for the send button
                        .background(Color(.systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .font(.subheadline)
                        .offset(x: -7)
                }
                .background(Color(.systemGroupedBackground))  // to ensure the background color consistency
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Send button
                Button(action: {
                    print("Post comment button")
                    if let currentUserObject = viewModel.currentSession {
                        Task {
                            do {
                                if replyFunctionFlag && createReplyCell, let commentObject = replyCommentObject {
                                    // Creates a ReplyCell
                                    try await statusProcess.replyComment(
                                        postId: status.id,
                                        userObject: currentUserObject,
                                        content: commentText,
                                        commentId: commentObject.id
                                    )
                                } 
                                else if replyFunctionFlag && createReplyReplyCell, let commentObject = replyCommentObject, let parentCommentId = parentCommentId {
                                    try await statusProcess.replyToReplyCell(
                                        postId: status.id,
                                        fromUserObject: currentUserObject,
                                        content: commentText,
                                        commentId: parentCommentId,
                                        replyId: commentObject.id
                                    )
                                }
                                
                                else {
                                    // Creates a CommentCell
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
    @State private var commentCellLikeCount: Int = 0
    @State private var commentCellLikeFlag: Bool = false
    
    @State private var commentCellCommentCount: Int = 0

    
    @Binding var showReplyFlag: Bool
    // This will determine whether or not the reply button was pressed, and which commentId was pressed.
    @Binding var replyFunctionFlag: Bool; @Binding var commentCellCommentObject: Comments?;
    @Binding var selectedComment: String?
    @Binding var createReplyCell: Bool
    
    
    let status: Status
    let comment: Comments
    
    
    var body: some View {
        VStack {
            // ** holds user information and comment timestamp
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
                        commentCellLikeCount = try await statusProcess.likeComment(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "", commentId: comment.id)
                        commentCellLikeFlag.toggle()
                    }
                }) {
                    Image(systemName: "heart")
                        .foregroundStyle(Color.gray)
                    
                    Text("\(commentCellLikeCount)")
                        .foregroundStyle(Color.primary)
                }
                
                //** Comment / Reply button
                Button(action: {
                    print("Comment/reply button in Comment View")
                    if selectedComment == comment.id {
                        selectedComment = nil
                        replyFunctionFlag = false
                        commentCellCommentObject = nil
                        createReplyCell = false
                    }
                    
                    else {
                        selectedComment = comment.id
                        replyFunctionFlag = true
                        commentCellCommentObject = comment
                        createReplyCell = true
                    }

                }) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundStyle(selectedComment == comment.id ? Color.blue : Color.gray)
                    
                    Text("\(commentCellCommentCount)")
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                    
                // Drop down Button for displaying other replies to this specific comment
                Button(action: {
                    print("This will act as the drop down menu for other replies")
                    showReplyFlag.toggle()
                    // ** populate some kind of list with reply data when the button is pressed
                    Task {
                        statusProcess.fetchRepliesUnderComment(postId: status.id, commentId: comment.id) { replyObjects in
                            DispatchQueue.main.async {
                                for reply in replyObjects {
                                    let replyId = reply.id
                                    if statusProcess.repliesDict[comment.id] == nil {
                                        statusProcess.repliesDict[comment.id] = [:]
                                    }
                                    statusProcess.repliesDict[comment.id]?[replyId] = reply
                                    
                                    // fetched nested replies for each top-level reply
                                    statusProcess.fetchReplyReplyCells(postId: status.id, commentId: comment.id, replyId: reply.id) { nestedReplies in
                                        DispatchQueue.main.async {
                                            for nestedReply in nestedReplies {
                                                let nestedReplyId = nestedReply.id
                                                if statusProcess.repliesDict[comment.id]?[nestedReplyId] == nil {
                                                    statusProcess.repliesDict[comment.id]?[nestedReplyId] = nestedReply
                                                }
                                            }
                                        }
                                    }
                                } // end of for loop
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
                commentCellLikeCount = try await statusProcess.fetchCommentCellLikeCount(postId: status.id, commentId: comment.id)
                commentCellLikeFlag = try await statusProcess.fetchCommentCellLikeFlag(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "", commentId: comment.id)
                
                // initialize comment count for each status
                commentCellCommentCount = try await statusProcess.fetchCommentCellCommentCount(postId: status.id, commentId: comment.id)
            }
        }
        
    } // end of body
    
}

// This will be our cell that holds replies
struct ReplyCell: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    
    //** need the parent status that the reply is under
    let parentStatus: Status
    let parentComment: Comments
    let reply: Comments
    
    @State private var replyCellLikeCount: Int = 0
    @State private var replyCellLikeFlag: Bool = false
    
    @Binding var replyFunctionFlag: Bool; @Binding var replyCellCommentObject: Comments?
    @Binding var selectedComment: String?
    @Binding var createReplyReplyCell: Bool; @Binding var parentCommentId: String?
    
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
                        Task {
                            replyCellLikeCount = try await statusProcess.likeReplyCell(postId: parentStatus.id, userId: Auth.auth().currentUser?.uid ?? "", commentId: parentComment.id, replyId: reply.id)
                            replyCellLikeFlag.toggle()
                        }
                        print("Like button")
                    }) {
                        Image(systemName: "heart")
                            .foregroundStyle(Color.gray)
                        
                        Text("\(replyCellLikeCount)")
                            .foregroundStyle(Color.primary)
                    }
                    
                    //** Comment / Reply button
                    Button(action: {
                        print("Comment/reply button in Comment View")
                        if selectedComment == reply.id {
                            selectedComment = nil
                            replyFunctionFlag = false
                            replyCellCommentObject = nil
                            createReplyReplyCell = false
                            parentCommentId = nil
                        }
                        
                        else {
                            selectedComment = reply.id
                            replyFunctionFlag = true
                            replyCellCommentObject = reply
                            createReplyReplyCell = true
                            parentCommentId = parentComment.id
                        }
                        
                    }) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .foregroundStyle(selectedComment == reply.id ? Color.blue : Color.gray)
                        
                    }
                }
            }
            
            
        } // end of vstack
        .onAppear {
            Task {
                // initialize all the like counts for each status
                replyCellLikeCount = try await statusProcess.fetchReplyCellLikeCount(postId: parentStatus.id, commentId: parentComment.id, replyId: reply.id)
                replyCellLikeFlag = try await statusProcess.fetchReplyCellLikeFlag(postId: parentStatus.id, userId: Auth.auth().currentUser?.uid ?? "", commentId: parentComment.id, replyId: reply.id)
            }
        }
            
    }
}

//#Preview {
//    CommentView()
//}
