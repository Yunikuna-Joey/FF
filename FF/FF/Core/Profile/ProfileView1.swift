//
//  ProfileView1.swift
//  FF
//
//

import SwiftUI
import FirebaseAuth

struct ProfileView1: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    @State private var colors: [String: Color] = [
        "Abs": .red,
        "Arms": .orange,
        "Back": .yellow,
        "Chest": .green,
        "Legs": .blue,
        "Push": .purple,
        "Pull": .cyan
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 10) {

                ForEach(statusProcess.statusList) { status in
                    if let currentUser = viewModel.currentSession {
                        ProfileStatusUpdateView(status: status, username: currentUser.username, timeAgo: status.timestamp, colors: colors)
                    }
                }
            }
            // create some extra spacing
            .padding()
        }
        .onAppear {
            statusProcess.statusList.removeAll()
            statusProcess.fetchStatus(userId: Auth.auth().currentUser?.uid ?? "")
        }
    }
}

struct ProfileStatusUpdateView: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    @EnvironmentObject var viewModel: AuthView
    
    // listens for like count changes
    @State private var likeCount: Int = 0
    @State private var likeFlag: Bool = false
    
    @State private var commentCount: Int = 0
    @State private var commentFlag: Bool = false
    
    @State private var deleteFlag: Bool = false
    
    @State private var statusUserObject: User?
    
    // status object
    let status: Status
    
    // immutatable for each specific user
    let username: String
    let timeAgo: Date
    
    // Color Bubbles here
    let colors: [String: Color]
    
    var body: some View {
        // what each individual update is going to follow [stacked bottom to top]
        VStack(alignment: .leading, spacing: 10) {
            let screenSize = UIScreen.main.bounds.size
            
            // stacked left to right
            HStack(spacing: 10) {
                
                // profile image on the left
                if let statusUserObject = statusUserObject {
                    if statusUserObject.profilePicture.isEmpty {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.blue)
                    }
                    
                    else {
                        AsyncImage(url: URL(string: statusUserObject.profilePicture)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 30, height: 30)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }

                }
                
                else {
                    ProgressView()
                        .frame(width: 30, height: 30)
                        .onAppear {
                            Task {
                                do {
                                    statusUserObject = try await viewModel.convertUserIdToObject(status.userId)
                                }
                                catch {
                                    print("Failed to fetch user: \(error)")
                                }
                            }
                        }
                }
                
                // username text next to image
                Text(username)
                    .font(.headline)
                
                // space between
                Spacer()
                
                // time that message was 'created'
                Text(ConstantFunction.formatTimeAgo(from: timeAgo))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Bubble choices associated with a status
            HStack {
                ForEach(status.bubbleChoice, id: \.self) { bubble in
                    let color = colors[bubble] ?? .gray
                    Text(bubble)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(color)
                        )
                        .font(.callout)
                }
            }
            

            // below the left => right will be the actual status
            Text(status.content)
                .font(.body)
                .padding(.bottom, 5)
            
            if !status.imageUrls.isEmpty {
                TabView {
                    ForEach(status.imageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: screenSize.height * 0.50)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: screenSize.height * 0.50)
                                    .cornerRadius(5)
                                    .clipped()
                                
                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                            @unknown default:
                                EmptyView()
                            } // end of switch
                            
                        } // end of async image
                         
                    } // end of for loop
                    
                } // end of TabView
                .tabViewStyle(PageTabViewStyle())
                .frame(height: screenSize.height * 0.50)
                .cornerRadius(5)
            }
            
            //*** bottom border
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
                .padding(.vertical, 5)

            // Button HStack
            HStack(spacing: 20) {
                //** Like button
                Button(action: {
                    Task {
                        likeCount = try await statusProcess.likeStatus(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "")
                        likeFlag.toggle()
                    }
                }) {
                    Image(systemName: likeFlag ? "heart.fill" : "heart")
                        .foregroundStyle(likeFlag ? Color.red : Color.gray)
                    
                    Text("\(likeCount)")
                        .foregroundStyle(Color.primary)
                        .monospacedDigit()
//                        .foregroundStyle(likeFlag ? Color.red : Color.gray)
                        
                }
                .foregroundStyle(Color.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 50, height: 30)
                )
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(likeFlag ? Color.blue.opacity(0.75) : Color.clear)
                        .frame(width: 50, height: 30)
                )
                
                //** Comment button
                Button(action: {
                    print("Comment Button")
                    commentFlag.toggle()
                }) {
                    Image(systemName: "bubble")
                        .foregroundStyle(Color.gray)
                    
                    Text("\(commentCount)")
                        .foregroundStyle(Color.primary)
                        .monospacedDigit()
                }
                .sheet(isPresented: $commentFlag) {
                    CommentView(status: status)
                }
                
                // push to the left so its aligned-left
                Spacer()
                
                //** Delete button if currentUser is the owner of the StatusUpdateView
                if let statusUserObject = statusUserObject {
                    if statusUserObject == viewModel.currentSession {
                        
                        Button(action: {
                            print("Act as the delete button")
                            deleteFlag.toggle()
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.red)
                        }
                    } // end of condition
                } // variable unwrap
            }
            .padding(.top, 10)

            
        }
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
                // initialize all the like counts for each status
                likeCount = try await statusProcess.fetchLikeCount(postId: status.id)
                likeFlag = try await statusProcess.fetchLikeFlag(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "")
                
                // initialize comment count for each status
                commentCount = try await statusProcess.fetchCommentCount(postId: status.id)
            }
        }
        .sheet(isPresented: $deleteFlag) {
            VStack {
                Text("Are you sure you want to delete this post?")
                    .padding()
                
                HStack {
                    Button(action: {
                        print("Act as the no button")
                        deleteFlag.toggle()
                    }) {
                        Text("No")
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        print("Act as the yes button")
                        Task {
                            try await statusProcess.deleteStatus(postId: status.id)
                            //** Removes itself from the HomeView
                            if let index = statusProcess.feedList.firstIndex(where: { $0.id == status.id }) {
                                statusProcess.feedList.remove(at: index)
                            }
                            //** Removes itself from the PFV1
                            if let index = statusProcess.statusList.firstIndex(where: { $0.id == status.id }) {
                                statusProcess.feedList.remove(at: index)
                            }
                            deleteFlag.toggle()
                        }
                    }) {
                        Text("Yes")
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .presentationDetents([.fraction(0.15)])
        }
    }
    
}


#Preview {
    ProfileView1()
}
