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
    @State var searchText: String = ""
    @State var userList: [User] = []
    @State var filterUserList: [User] = []
    
    init(composeFlag: Binding<Bool>) {
        _composeFlag = composeFlag
    }
    
    //*** This should query a user's following
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        ScrollView(showsIndicators: false) {
            LazyVStack {
                TextField("Search", text: $searchText)
                    .padding()
                ForEach(filterUserList, id: \.id) { user in
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
                //** onAppear will set both lists to the same values, then use the filtered List
                Task {
                    do {
                        // This will act as the original list
                        userList = try await followManager.queryFollowers(userId: viewModel.queryCurrentUserId() ?? "")
                        // This will act as the modified list 
                        filterUserList = userList
                    }
                    catch {
                        print("[DEBUG]: Error queryting in compose \(error.localizedDescription)")
                    }
                }
            }
            .onChange(of: searchText) { _, newValue in
                //** Testing empty onChange just for the searchText variable
                if newValue.isEmpty {
                    filterUserList = userList
                }
                else {
                    filterUserList = userList.filter { $0.username.localizedCaseInsensitiveContains(newValue)
                    }
                }
            }
        } // end of scroll view
    } // end of body here
}

//#Preview {
//    ComposeMessageView(composeFlag: true)
//}
