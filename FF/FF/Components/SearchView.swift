//
//  SearchView.swift
//  FF
//
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SearchView: View {
    // hold some image arary... likely just some random users
    let imageArray = ["Car", "car2", "terrifiednootnoot"]
    let itemSize: CGFloat = (UIScreen.main.bounds.width - 40 - 20) / 3 - 10
    
    @State private var searchText: String = ""
    @State private var searchResults = []
    private var db = Firestore.firestore()
    
    let username = "List User 1"
    
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // enable scrolling behavior
                ScrollView(showsIndicators: false) {
                    // if the search bar is empty
                    if searchText.isEmpty {    // revert the condition change for production
                        // grid to hold the pictures
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize))]) {
                            // iterate through the image array
                            ForEach(imageArray, id: \.self) {
                                imageName in Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: itemSize + 32, height: itemSize)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    
                    // if it is not empty
                    else {
                        listUserProfiles(profilePicture: Image(systemName: "person.circle"), username: username, imageArray: imageArray)
                    }
                    
                }
                
                // search bar
                TextField("Search", text: $searchText)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(maxWidth: 500 ) // Set maximum width
//                    .onChange(of: searchText) {
//                        searchUsers()
//                    }
                
            } // end of ZStack
        }
    }
    
    private func searchUsers() {
        // should display: No results found
        if searchText.isEmpty {
            searchResults = []
            return
        }
        
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThan: searchText + "\u{f8ff}")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error searching users: \(error.localizedDescription)")
                }
                else {
                    searchResults = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: User.self)
                    } ?? []
                }
            }
    }
}

struct listUserProfiles: View {
    let profilePicture: Image
    let username: String
    let imageArray: [String]
    
    
    var body: some View {
        VStack {
            HStack {
                // image on top
                profilePicture
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                
                // username || can add badges underneath to showcase
                NavigationLink(destination: LoadProfileView()) {
                    Text(username)
                        .font(.headline)
                        .foregroundStyle(Color.orange)
                }
                
                // push to the left
                Spacer()
                
                // Follow and unfollow button || need logic to toggle between Follow and Unfollow
                Button(action: {
                    print("Follow / unfollow button")
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color.green)
                        .overlay(
                            Text("Follow")
                                .foregroundStyle(Color.white)
                                .padding(4)
                        )
                        .frame(width: 100, height: 30)
                        .padding()
                }
            }
            
            // horizontal row of 3 most recent images
            HStack {
                ForEach(imageArray, id: \.self) { image in
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
    }
}

#Preview {
    SearchView()
}
