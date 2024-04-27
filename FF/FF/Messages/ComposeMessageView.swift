//
//  ComposeMessageView.swift
//  FF
//
//

import SwiftUI

struct ComposeMessageView: View {
    @EnvironmentObject var followManager: FollowingManager
    @EnvironmentObject var viewModel: AuthView
    @Binding var composeFlag: Bool
//    @State var userList: [String] = []
    @State var userList: [User] = []
    
    init(composeFlag: Binding<Bool>) {
        _composeFlag = composeFlag
    }
    
    //*** This should query a user's following
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(userList, id: \.id) { user in
                    HStack {
                        // profile picture
                        if user.profilePicture.isEmpty {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.blue)
                                .padding()
                        }
                        
                        else {
                            Image(user.profilePicture)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.blue)
                                .padding()
                        }
                        
                        // username
                        Text(user.username)
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    // divider
                    Divider()
                        .frame(width: screenSize.width * 0.80)
                        .padding(.leading, screenSize.width * 0.20)
                        .padding(.trailing, screenSize.width * 0.05)
                }
            } // end of lazyVStack
            .onAppear {
                Task {
                    do {
                        userList = try await followManager.queryFollowers(userId: viewModel.queryCurrentUserId() ?? "")
                    }
                    catch {
                        print("[DEBUG]: Error queryting in compose \(error.localizedDescription)")
                    }
                }
            }
        } // end of scroll view
    }
}

//#Preview {
//    ComposeMessageView(composeFlag: true)
//}
