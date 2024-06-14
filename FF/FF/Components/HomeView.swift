//
//  HomeView.swift
//  FF
//
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Status updates [Dynamically retrieves self-user statuses... need more work for dynamic following]
struct HomeView: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    // dicionary for colors processed on client-side
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
    ]
    
    var body: some View {
        // Scroll behavior for multiple statuses
        ScrollView(showsIndicators: false) {
            // vertical for ordering [spacing between each status update is controlled]
            VStack(spacing: 10) {
                // for loop for processing a user's status's
//                ForEach(statusProcess.feedList) { status in
                ForEach(statusProcess.feedList.sorted(by: { $0.timestamp > $1.timestamp })) { status in
                    
                    StatusUpdateView(
                        status: status,
                        username: status.userObject.username,
                        timeAgo: status.timestamp,
                        colors: colors
                    )
                    
                }
            }
            // create some extra spacing
            .padding()
        }
        .onAppear {
            statusProcess.feedList.removeAll()
                        
            // query statuses for following based on current string user id else { blank }
            statusProcess.fetchFeed(userId: viewModel.queryCurrentUserId() ?? "") { statuses in
                for status in statuses {
                    statusProcess.feedList.append(status)
//                    print("This is the value of status \(status)")
                }
            }
            
           
            // Then in main view, we sort the list by timestamp
            print("This is the value of feedlist: \(statusProcess.feedList)")
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// status update structure,,, what each update will follow in terms of pieces
struct StatusUpdateView: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    @EnvironmentObject var viewModel: AuthView
    
    // listens for like count changes
    @State private var likeCount: Int = 0
    @State private var likeFlag: Bool = false
    
    @State private var commentCount: Int = 0
    @State private var commentFlag: Bool = false
    
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
                .padding(.bottom)
            
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
//                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: screenSize.height * 0.50)
                                    .background(Color.gray.opacity(0.1))  // Background color to fill extra space
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
            }
            
            //*** bottom border
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
                .padding(.vertical, 5)

            
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
                }
                .sheet(isPresented: $commentFlag) {
                    CommentView(status: status)
                }
                
                // push to the left so its aligned-left
                Spacer()
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
    }
    
}


#Preview {
    HomeView()
}
