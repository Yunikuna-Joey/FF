//
//  SearchView.swift
//  FF
//
//

import SwiftUI

struct SearchView: View {
    // hold some image arary... likely just some random users
    let imageArray = ["Car", "car2", "terrifiednootnoot"]
    let itemSize: CGFloat = (UIScreen.main.bounds.width - 40 - 20) / 3 - 10
    
    @State private var searchText: String = ""
    
    let username = "List User 1"
    let bio = "Testing short bio here"
    let following = 12
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // enable scrolling behavior
            ScrollView(showsIndicators: false) {
                // if the search bar is empty
                if searchText.isEmpty {
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
                    VStack {
                        
                        HStack {
                            // image on top
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.leading, 20)
                                .padding(.top, 10)
                            
                            // username || can add badges underneath to showcase
                            Text(username)
                                .font(.headline)
                            
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
                            Image("Car")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                            
                            Image("car2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                            
                            Image("car3")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
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
            
            // search bar
            TextField("Search", text: $searchText)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.33))
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom)
                .frame(maxWidth: 500 ) // Set maximum width
        } // end of ZStack
    }
}

struct listUserProfiles: View {
    let username: String
    let bio: String
    let followers: Int
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.blue)
            
            VStack {
                Text(username)
                    .font(.headline)
                
                Text(bio)
                    .font(.caption)
            }
        }
        .padding()
    }
}

#Preview {
    SearchView()
}
