//
//  SearchView.swift
//  FF
//
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

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
                
                // search bar
                TextField("Search", text: $searchText)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.33))
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
                        .frame(width: 50, height: 50)
                        .padding(.leading, 20)
                        .padding(.top, 10)
                }
                else {
                    Image(resultUser.profilePicture)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.leading, 20)
                        .padding(.top, 10)
                }

                // username || can add badges underneath to showcase
//                NavigationLink(
//                    destination: LoadProfileView(resultUser: resultUser)
//                        .navigationTitle(resultUser.username)
//                ) {
//                    Text(resultUser.username)
//                        .font(.headline)
//                        .foregroundStyle(Color.orange)
//                }

                Text(resultUser.username)
                    .font(.headline)
                    .foregroundStyle(Color.orange)

                // push to the left
                Spacer()


            }

            // horizontal row of 3 most recent images
            HStack {
                ForEach(resultUser.imageArray, id: \.self) { image in
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(10)
                }
            }
            .padding()

        } // vstack for one card
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5))
        )
        .padding()
        .padding(.vertical, -10)
    }
}

struct HashtagCell: View {
    let status: Status
    
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        
        VStack {
            
            // ** username of the status and timestamp
            HStack {
                Text(status.username)
                    .font(.headline)
                
                Spacer()
                
                Text(formatTimeAgo(from: status.timestamp))
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            
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
            
            // This should overlay the picture and/or image
            HStack {
                Text(status.content)
                    .foregroundStyle(Color.purple)
                
                Spacer()
            }
            .padding(.top, 10)
            
            // Hold the like and comment icons
            HStack(spacing: 10) {
                Image(systemName: "heart")
                
                Image(systemName: "bubble.fill")
                
                Spacer()
            }
            .padding(.top, 10)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
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
