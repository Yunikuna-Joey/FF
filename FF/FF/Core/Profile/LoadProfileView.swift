//
//  LoadProfileView.swift
//  FF
//
//

import SwiftUI

struct LoadProfileView: View {
    // CONSTANTS
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var followManager: FollowingManager
    @State private var current: Tab = .status
    @State private var settingsFlag = false
    
    // Initializer
    let resultUser: User
    
    // iterate through the different tabs
    func currSelection(_ tab:Tab) -> Bool {
        return current == tab
    }
    
    // create cases for tabs
    enum Tab {
        case status
        case images
        case others
    }
    
    // [test] dynamic user information loading
    let value1 = 25
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                VStack {
                    // Cover Photo
                    Image("Car")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenSize.height * 0.30)
                        .clipped()
                    
                    // profile picture
                    Image("car2")
                        .resizable()
                        .frame(width: 200, height: 150)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    // [play with this offset value]
                        .offset(y: -100)
                    
                    // pushes the cover photo AND profile picture
                    Spacer()
                    
                    // Stack for username
                    HStack {
                        Text(resultUser.username)
                            .font(.headline)
                        // [play with this offset value]
                    }
                    .offset(y: -screenSize.height * 0.12)
                    
                    // HStack for user statistics
                    HStack(spacing: screenSize.width * 0.15) {
                        // category 1
                        VStack {
                            Text("Followers")
                                .font(.headline)
                            Text("\(value1)")
                        }
                        // category 2
                        VStack {
                            Text("Following")
                                .font(.headline)
                            Text("\(value1)")
                        }
                    }
                    .offset(y: -screenSize.height * 0.10)
                    
                    // HStack for clickable icons to switch between the different tabs
                    HStack(spacing: screenSize.width * 0.25) {
                        // Button #1
                        Button(action: {
                            current = .status
                        }) {
                            Image(systemName: "person.fill")
                                .padding()
                                .foregroundStyle(Color.blue)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 20)
                                        .foregroundStyle(currSelection(.status) ? .blue : .clear)
                                )
                        }
                        
                        // Button #2
                        Button(action: {
                            current = .images
                        }) {
                            Image(systemName: "photo.fill")
                                .padding()
                                .foregroundStyle(Color.blue)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 20)
                                        .foregroundStyle(currSelection(.images) ? .blue : .clear)
                                )
                        }
                        
                        // Button #3
                        Button(action: {
                            current = .others
                        }) {
                            Image(systemName: "calendar")
                                .padding()
                                .foregroundStyle(Color.blue)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 20)
                                        .foregroundStyle(currSelection(.others) ? .blue : .clear)
                                )
                        }
                    }
                    .foregroundStyle(Color.blue)
                    .offset(y: -screenSize.height * 0.10)
                    
                    // VStack for the actual different tab views
                    VStack {
                        switch current {
                        case .status:
                            ProfileView1()
                        case .images:
                            ProfileView2()
                        case .others:
                            ProfileView3()
                        }
                    }
                    .offset(y: -screenSize.height * 0.10)
                    .padding(.horizontal, 5)
                    .frame(minHeight: screenSize.height * 0.45)
                    
                } // end of VStack
                
                // Follow || unfollow button
                VStack {
                    Button(action: {
                        print("[DEBUG]: Follow || Unfollow button here")
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color.green)
                            .overlay(
                                Text("Follow")
                                    .foregroundStyle(Color.white)
                                    .padding()
                            )
                    }
                }
                .frame(width: 100, height: screenSize.height * 0.05)
                .padding(.top, screenSize.height * 0.32) // Adjust top padding as needed
                .padding(.trailing, screenSize.width * 0.03) // Adjust trailing padding as needed

            } // end of ZStack
            .navigationTitle(resultUser.username)
        }
    }
}

//#Preview {
//    let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
//    LoadProfileView(resultUser: user)
//}


struct LoadProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
        LoadProfileView(resultUser: user)
    }
}
