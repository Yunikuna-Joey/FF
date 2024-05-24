//
//  SearchView.swift
//  FF
//
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct SearchView: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var followManager: FollowingManager
    @EnvironmentObject var statusProcess: StatusProcessView
    
    // hold some image arary... likely just some random users
//    let imageArray = ["Car", "car2", "terrifiednootnoot"]
    let itemSize: CGFloat = (UIScreen.main.bounds.width - 40 - 20) / 3 - 10
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    private var db = Firestore.firestore()
    @State private var selectedUser: User? = nil
    
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .bottom) {
                
                
                ScrollView(showsIndicators: false) {
                    
                    // if the search bar is empty
                    if searchText.isEmpty {    // revert the condition change for production
                
                        ForEach(statusProcess.searchFeedList) { status in
                            HashtagCell(status: status)
                                .padding()
                        }
                        
                    }
                    
                    // if it is not empty
                    else {
                        ForEach(searchResults) { user in
                            listUserProfiles(resultUser: user)
                                .onTapGesture {
                                    selectedUser = user
                                }
                        }
                    }
                } // end of scrollView
                .padding(.bottom, 60)
                
                // search bar
                TextField("Search", text: $searchText)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.33))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(maxWidth: 500) // Set maximum width
                    .onChange(of: searchText) {
                        if let currentUser = viewModel.currentSession {
                            searchUsers(currSearchText: searchText, currentUsername: currentUser.username)
                        }
                    }
                
            } // end of ZStack
            .background(
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)).opacity(0.7), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).opacity(0.7), Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)).opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                }
            )
            .onTapGesture {             // attempt to remove the keyboard when tapping on the search results [anywhere outside of the textfield/keyboard]
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationDestination(item: $selectedUser) { user in
                LoadProfileView(resultUser: user)
                    .navigationTitle(user.username)
            }
        } // end of navigation Stack
        .onAppear {
            statusProcess.searchFeedList.removeAll()
            statusProcess.fetchSearchPageContent() { statuses in
                for status in statuses {
                    statusProcess.searchFeedList.append(status)
                }
            }
        }
        
    } // end of body
    
    // function to search for other users
    func searchUsers(currSearchText: String, currentUsername: String) {
        // should display: No results found
        if currSearchText.isEmpty {
            searchResults = []
            print("[DEBUG]: The search field is empty")
            return
        }
        
        db.collection("users")
            .whereField("databaseUsername", isGreaterThanOrEqualTo: currSearchText.lowercased())
            .whereField("databaseUsername", isLessThan: currSearchText.lowercased() + "\u{f8ff}")
            .whereField("databaseUsername", isNotEqualTo: currentUsername.lowercased())
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error searching users: \(error.localizedDescription)")
                }
                else {
                    // clear the search results before appending new users
                    searchResults.removeAll()
                    for document in querySnapshot?.documents ?? [] {
                        if let user = try? document.data(as: User.self) {
                            searchResults.append(user)
                        }
                    }
                }
            }
        
        print("[DEBUG]: The searchUsers function was triggered")
        print("[DEBUG]: This is the searchResults \(searchResults)")
        print("[DEBUG]: This is the searchText \(currSearchText)")
        print("\n")
    }
}

// takes in a user object to extract information
struct listUserProfiles: View {
//    @Binding var userFlag: Bool
    let resultUser: User
    
    var body: some View {
        VStack {
            HStack {
                // image on top
                if resultUser.profilePicture.isEmpty {
                    Image(systemName: "person.circle")        // ****** remove systemName for user-uploaded pictures ******
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.leading, 20)
                }
                else {
                    AsyncImage(url: URL(string: resultUser.profilePicture)) { phase in
                        switch phase {
                        case.empty:
                            ProgressView()
                                .frame(width: 30, height: 30)
                            
                        case.success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(.leading, 20)
                            
                        case.failure:
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .padding(.leading, 20)
                                
                                Spacer()
                            }
                            .padding()
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // username || can add badges underneath to showcase
                Text(resultUser.username)
                    .font(.headline)
                    .foregroundStyle(Color.orange)

                // push to the left
                Spacer()


            }
            .padding(.vertical)
            .padding(.trailing)
            .background(
                ZStack {
                    Color.gray.opacity(0.2)
                    BlurView(style: .systemMaterial)
                }
            )
            .cornerRadius(10)
            .shadow(radius: 5)

            // horizontal row of 3 most recent images
//            HStack {
//                ForEach(resultUser.imageArray, id: \.self) { image in
//                    Image(image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 100, height: 100)
//                        .clipped()
//                        .cornerRadius(10)
//                }
//            }
//            .padding()

        } // vstack for one card
        .padding()
        .padding(.vertical, -10)
    }
}

// for displaying hashtag content
struct HashtagCell: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    @EnvironmentObject var followManager: FollowingManager
    
    @State private var statusUserObject: User = EmptyVariable.EmptyUser
    
    @State private var likeFlag: Bool = false
    @State private var likeCount: Int = 0
    
    @State private var commentFlag: Bool = false
    @State private var commentCount: Int = 0
    
    let status: Status
    
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        
        VStack {
            
            // ** username of the status and timestamp
            HStack {
                if statusUserObject.profilePicture.isEmpty {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                else {
                    AsyncImage(url: URL(string: statusUserObject.profilePicture)) { phase in
                        switch phase {
                        case.empty:
                            ProgressView()
                                .frame(width: 30, height: 30)
                            
                        case.success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            
                        case.failure:
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Spacer()
                            }
                            .padding()
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text(status.username)
                    .font(.headline)
                
                Spacer()
                
                Text(formatTimeAgo(from: status.timestamp))
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            
            // This should overlay the picture and/or image
            HStack {
                Text(status.content)
                    .foregroundStyle(Color.purple)
                
                Spacer()
            }
            .padding(.top, 10)
            
            // ** Content [Being either image or video]
            TabView {
                ForEach(status.imageUrls, id: \.self) { imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: screenSize.height * 0.40)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .frame(height: screenSize.height * 0.40)
                            
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
            .frame(height: screenSize.height * 0.40)
            
            //** bottom border
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
                .padding(.vertical, 5)
            
            // Hold the like and comment icons
            HStack(spacing: 20) {
                //*** Like Button
                Button(action: {
                    Task {
                        likeCount = try await statusProcess.likeStatus(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "")
                        likeFlag.toggle()
                    }
                }) {
                    Image(systemName: likeFlag ? "heart.fill" : "heart")
                        .foregroundStyle(likeFlag ? Color.red : Color.gray)
                    
                    Text("\(likeCount)")
                        .foregroundStyle(Color.black)
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
                        .fill(likeFlag ? Color.blue.opacity(0.80) : Color.clear)
                        .frame(width: 50, height: 30)
                )
                
                // Comment button
                Button(action: {
                    print("Comment Button")
                    commentFlag.toggle()
                }) {
                    Image(systemName: "bubble")
                        .foregroundStyle(Color.gray)
                    
                    Text("\(commentCount)")
                        .foregroundStyle(Color.black)
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
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            Task {
                likeCount = try await statusProcess.fetchLikeCount(postId: status.id)
                likeFlag = try await statusProcess.fetchLikeFlag(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "")
                
                commentCount = try await statusProcess.fetchCommentCount(postId: status.id)
                
                statusUserObject = try await followManager.getUserById(userId: status.userId) ?? EmptyVariable.EmptyUser
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

#Preview {
    SearchView()
}
