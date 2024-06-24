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
    @State private var isFollowing = false
    
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
    
    // Dynamic information loading variables
    @State private var followers = 0
    @State private var following = 0
    
    @State private var loadViewPlanFlag: Bool = false
    @State var loadSelectedPlan: Plan = Plan(id: "", userId: "", planTitle: "", workoutType: [:])
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topTrailing) {
                    VStack {
                        // Cover Photo
                        if resultUser.coverPicture.isEmpty {
                            Image("Car")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: screenSize.height * 0.30)
//                                .clipped()
                        }
                        
                        else {
                            AsyncImage(url: URL(string: resultUser.coverPicture)) { phase in
                                switch phase {
                                    
                                case.empty:
                                    ProgressView()
                                        .frame(height: screenSize.height * 0.4)
                                    
                                case.success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: screenSize.height * 0.30)
//                                        .clipped()
                                    
                                case.failure:
                                    HStack {
                                        Image(systemName: "xmark.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        Spacer()
                                        
                                        Text("Could not load cover photo at this moment.")
                                            .foregroundStyle(Color.red.opacity(0.6))
                                            .padding()
                                        
                                        Spacer()
                                    }
                                    .padding()
                                
                                @unknown default:
                                    EmptyView()
                                    
                                } // end of switch closure
                                
                            } // Asyc image closure
                            
                        } // else statement
                        
                        // profile picture
                        if resultUser.profilePicture.isEmpty {
                            Image("car2")
                                .resizable()
                                .frame(width: 200, height: 150)
                                .clipShape(Circle())
                            // [play with this offset value]
                                .offset(y: -100)
                        }
                        
                        else {
                            AsyncImage(url: URL(string: resultUser.profilePicture)) { phase in
                                
                                switch phase {
                                case.empty:
                                    ProgressView()
                                        .frame(height: screenSize.height * 0.40)
                                    
                                case.success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 200, height: 150)
                                        .clipShape(Circle())
                                        .offset(y: -100)
                                    
                                case.failure:
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 150)
                                        .clipShape(Circle())
                                        .offset(y: -100)
                                    
                                @unknown default:
                                    EmptyView()
                                } // end of switch
                                
                            } // end of async image
                            
                        }
                        
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
                                Text("\(followers)")
                            }
                            // category 2
                            VStack {
                                Text("Following")
                                    .font(.headline)
                                Text("\(following)")
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
                                    .foregroundStyle(current == .status ? Color.white.opacity(0.80) : Color.black.opacity(0.80))
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
                                    .foregroundStyle(current == .images ? Color.white.opacity(0.80) : Color.black.opacity(0.80))
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
                                    .foregroundStyle(current == .others ? Color.white.opacity(0.80) : Color.black.opacity(0.80))
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
                                LoadProfileView1(resultUser: resultUser)
                            case .images:
                                LoadProfileView2(resultUser: resultUser)
                            case .others:
                                LoadProfileView3(
                                    resultUser: resultUser,
                                    loadViewPlanFlag: $loadViewPlanFlag,
                                    loadSelectedPlan: $loadSelectedPlan
                                )
                            }
                        }
                        .offset(y: -screenSize.height * 0.10)
                        .padding(.horizontal, 5)
                        .frame(minHeight: screenSize.height * 0.45)
                        
                    } // end of VStack
                    
                    // Follow || unfollow button
                    VStack {
                        Button(action: {
                            Task {
                                do {
                                    if isFollowing {
                                        await followManager.unfollowUser(userId: viewModel.queryCurrentUserId() ?? "", friendId: resultUser.id)
                                        isFollowing = false
                                        print("[DEBUG]: The value after unfollow action is \(isFollowing)")
                                    }
                                    else {
                                        await followManager.followUser(userId: viewModel.queryCurrentUserId() ?? "", friendId: resultUser.id)
                                        isFollowing = true
                                        print("[DEBUG]: The value after follow action is \(isFollowing)")
                                    }
                                }
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(isFollowing ? Color.red : Color.green)
                                .overlay(
                                    Text(isFollowing ? "Unfollow" : "Follow")
                                        .foregroundStyle(Color.white)
                                        .padding()
                                )
                        }
                    } // end of Vstack
                    .frame(width: 100, height: screenSize.height * 0.05)
                    .padding(.top, screenSize.height * 0.32) // Adjust top padding as needed
                    .padding(.trailing, screenSize.width * 0.03) // Adjust trailing padding as needed
                    
                } // end of ZStack
                .background(
                    BackgroundView()
                )
                .onAppear(perform: {
                    // query initial follow status
                    Task {
                        do {
                            isFollowing = await followManager.queryFollowStatus(userId: viewModel.queryCurrentUserId() ?? "", friendId: resultUser.id)
                            followers = await followManager.queryFollowersCount(userId: resultUser.id)
                            following = await followManager.queryFollowingCount(userId: resultUser.id)
                        }
                        
                    }
                })
//                .navigationDestination(isPresented: $loadViewPlanFlag) {
//                    LoadviewPlanView(plan: loadSelectedPlan)
//                }

            } // end of scrollView
            .edgesIgnoringSafeArea(.all)
            
            
        } // end of navigationStack

        
    } // end of body
}

//#Preview {
//    let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
//    LoadProfileView(resultUser: user)
//}


//struct LoadProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
//        LoadProfileView(resultUser: user)
//    }
//}
