//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

// all offset values are based on iPhone 15 Pro, need more functions to determine different sizes

struct ProfileView: View {
    // CONSTANTS
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    @EnvironmentObject var followManager: FollowingManager
    
    // Keep track of which tab we are on
    @State private var current: Tab = .status
    
    // User information
    @State private var currentUserObject: User = EmptyVariable.EmptyUser
    @State private var followerCount: Int = 0
    @State private var followingCount: Int = 0

    // Sheet flags
    @State private var settingsFlag = false
    @State private var pictureFlag = false
    
    // This one is for viewing a plan
    @State var viewPlanFlag: Bool = false
    
    // This one is for creating a new plan
    @State var planScreenFlag: Bool = false
    
    // Cover || Profile Picture
    @State private var selectProfilePicture: UIImage?
    @State private var selectCoverPicture: UIImage?
    @State private var profilePictureFlag: Bool = false
    @State private var coverPictureFlag: Bool = false
    @State private var previewProfileFlag: Bool = false
    @State private var previewCoverFlag: Bool = false
    
    
    // plan object..?
    @State var selectedPlan: Plan = EmptyVariable.EmptyPlan
//    var currentUserObject: User = User(id: "", username: "", databaseUsername: "", firstName: "", lastName: "", email: "", imageArray: [], profilePicture: "", coverPicture: "")
    
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
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        
        NavigationStack {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topTrailing) {
                    VStack {
                        // Cover Photo case 
                        if currentUserObject.coverPicture.isEmpty {
                            Image("Car")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .frame(height: screenSize.height * 0.30)
                                .clipped()
                        }
                        
                        else {
                            AsyncImage(url: URL(string: currentUserObject.coverPicture)) { phase in
                                switch phase {
                                case.empty:
                                    ProgressView()
                                        .frame(height: screenSize.height * 0.4)
                                    
                                case.success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: screenSize.height * 0.30)
                                        .clipped()
                                    
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
                                }
                            }
                        }
                        
                        //** profile picture section
                        if currentUserObject.profilePicture.isEmpty {
                            Image("car2")
                                .resizable()
                                .frame(width: 200, height: 150)
                                .clipShape(Circle())
                                // [play with this offset value]
                                .offset(y: -100)
                        }
                        
                        else {
                            AsyncImage(url: URL(string: currentUserObject.profilePicture)) { phase in
                                switch phase {
                                // Different cases the request might encounter: loading | success | None
                                case .empty:
                                    ProgressView()
                                        .frame(height: screenSize.height * 0.40)
                                    
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 200, height: 150)
                                        .clipShape(Circle())
                                        // [play with this offset value]
                                        .offset(y: -100)
                                    
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
                            
                        }
                            
                        
                        // pushes the cover photo AND profile picture
                        Spacer()
                        
                        // Stack for username
                        HStack {
                            Text(viewModel.currentSession?.username ?? "")
                                .font(.headline)
                            
                            // Change photo menu button (down arrow)
                            Button(action: {
                                print("Change user photo(s) button")
                                pictureFlag.toggle()
                            }) {
                                Image(systemName: "chevron.down.circle.fill")
                            }
                            .sheet(isPresented: $pictureFlag) {
                                NavigationStack {
                                    VStack {
                                        //*** Changing the user Profile picture case
                                        HStack {
                                            
                                            Button(action: {
                                                print("This will act as the profile picture change button")
                                                profilePictureFlag.toggle()
                                            }) {
                                                Text("Change profile picture")
                                            }
                                            .sheet(isPresented: $profilePictureFlag) {
                                                ImagePicker(selectedImage: $selectProfilePicture) {
                                                    previewProfileFlag = true
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        
                                        Divider()
                                        
                                        //*** Changing the cover picture case
                                        HStack {
                                            
                                            Button(action: {
                                                print("This will act as the cover photo change button")
                                                coverPictureFlag.toggle()
                                            }) {
                                                Text("Change cover picture")
                                            }
                                            .sheet(isPresented: $coverPictureFlag) {
                                                ImagePicker(selectedImage: $selectCoverPicture) {
                                                    previewCoverFlag = true
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        
                                    } // end of vstack
                                    //.presentationDetents([.fraction(0.3), .medium, .large])
                                    .presentationDetents([.fraction(0.25), .fraction(0.50), .large])
                                    .navigationDestination(isPresented: $previewProfileFlag) {
                                        PreviewProfilePicture(
                                            selectedImage: $selectProfilePicture,
                                            onSave: {
                                                Task {
                                                    
                                                    if let selectProfilePicture = selectProfilePicture {
                                                        // save the image to Firebase Storage
                                                        let imageUrl = try await statusProcess.uploadImage(image: selectProfilePicture)
                                                        
                                                        // update the User object with profile picture URL
                                                        viewModel.updateProfilePicture(userId: viewModel.queryCurrentUserId() ?? "", profilePictureUrl: imageUrl)
                                                        
                                                        
                                                    }
                                                    
                                                    print("Save profile picture button.")
                                                    selectProfilePicture = nil
                                                    // exits the parent sheet all together
                                                    pictureFlag = false
                                                    
                                                }
                                                
                                            },
                                            onCancel: {
                                                selectProfilePicture = nil
                                                // exits the parent sheet all together
                                                pictureFlag = false
                                            }
                                        )
                                        
                                    } // end of navigationDestination closure
                                    .navigationDestination(isPresented: $previewCoverFlag) {
                                        PreviewCoverPicture(
                                            selectedImage: $selectCoverPicture,
                                            onSave: {
                                                Task {
                                                    if let selectCoverPicture = selectCoverPicture {
                                                        let imageUrl = try await statusProcess.uploadImage(image: selectCoverPicture)
                                                        
                                                        viewModel.updateCoverPicture(userId: viewModel.queryCurrentUserId() ?? "", coverPictureUrl: imageUrl)
                                                    }
                                                    
                                                    print("Save cover picture button")
                                                    selectCoverPicture = nil
                                                    pictureFlag = false
                                                }
                                            },
                                            onCancel: {
                                                selectCoverPicture = nil
                                                // exits the parent view
                                                pictureFlag = false
                                            }
                                        )
                                    }
                                    
                                } // end of navigation stack
                                
                            } // end of sheet closure

                            
                        } // end of parent hstack
                        .offset(y: -screenSize.height * 0.12)
                                                
                        // HStack for user statistics
                        HStack(spacing: screenSize.width * 0.15) {
                            // category 2
                            VStack {
                                Text("Followers")
                                    .font(.headline)
                                Text("\(followerCount)")
                            }
                            // category 3
                            VStack {
                                Text("Following")
                                    .font(.headline)
                                Text("\(followingCount)")
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
//                        .foregroundStyle(Color.blue)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.25)
                                .offset(y: 20)
                                .foregroundStyle(Color.gray)
                        )
                        .offset(y: -screenSize.height * 0.10)
                        
                        
                        // VStack for the actual different tab views
                        VStack {
                            switch current {
                            case .status:
                                ProfileView1()
                            case .images:
                                ProfileView2()
                            case .others:
                                ProfileView3(planScreenFlag: $planScreenFlag, viewPlanFlag: $viewPlanFlag, selectedPlan: $selectedPlan)
                            }
                        }
                        .offset(y: -screenSize.height * 0.10)
                        .padding(.horizontal, 5)
                        .frame(minHeight: screenSize.height * 0.45)
                        
                    } // end of VStack
                    
                    // Settings button
                    VStack {
                        Button(action: {
                            // toggles converts the flag value to true [test]
                            settingsFlag.toggle()
                            print("Settings here for sign out and such")
                        }) {
                            Image(systemName: "gearshape.fill")
                                .padding()
                                .foregroundStyle(Color.blue)
                        }
                    }
                    .padding(.top, screenSize.height * 0.30) // Adjust top padding as needed
                    .padding(.trailing, screenSize.width * 0.01) // Adjust trailing padding as needed
                    // play with sheet and how it feels
                    .sheet(isPresented: $settingsFlag) {
                        SettingView()
                    }
                    
                } // end of ZStack
                
                .onAppear {
                    Task {
                        followerCount =  await followManager.queryFollowersCount(userId: viewModel.queryCurrentUserId() ?? "")
                        followingCount =  await followManager.queryFollowingCount(userId: viewModel.queryCurrentUserId() ?? "")
                        currentUserObject = try await followManager.getUserById(userId: viewModel.queryCurrentUserId() ?? "") ?? EmptyVariable.EmptyUser
//                        print("This is the value of currentUserObject \(currentUserObject)")
                    }
                }
            } // end of scrollView
            .navigationDestination(isPresented: $planScreenFlag) {
                PlanScreenView(planScreenFlag: $planScreenFlag)
            }
            .navigationDestination(isPresented: $viewPlanFlag) {
                viewPlanView(plan: selectedPlan)
            }
            
        } // end of navigation stack
        
    } // end of body here
}

struct PreviewProfilePicture: View {
    @Binding var selectedImage: UIImage?
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()  // Ensure the image fills the frame without preserving aspect ratio
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding()
                
                Button(action: onSave) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding()
                }
            } 
            else {
                Text("No Image Selected")
            }
            
        } // end of vstack
        
    } // end of body
}

struct PreviewCoverPicture: View {
    @Binding var selectedImage: UIImage?
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
//        let screenSize = UIScreen.main.bounds.size
        VStack {
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()  // Ensure the image fills the frame without preserving aspect ratio
                    .frame(width: 200, height: 200)
//                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding()
                
                Button(action: onSave) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            else {
                Text("No Image Selected")
            }
            
        } // end of vstack
        
    } // end of body
}

//#Preview {
//    ProfileView()
//}
