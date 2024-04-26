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
    @State var userList: [String] = []
    
    init(composeFlag: Binding<Bool>) {
        _composeFlag = composeFlag
    }
    
    //*** This should query a user's following
    var body: some View {
        LazyVStack {
            ForEach(userList.indices, id: \.self) { index in
                Text(userList[index].username)
                    .foregroundStyle(Color.black)
                    .padding()
            }
        }
        .onAppear {
            Task {
                do {
                    let fetchInformation = try await followManager.queryFollowers(userId: viewModel.queryCurrentUserId() ?? "")
                    userList = fetchInformation
                }
                catch {
                    print("[DEBUG]: Error queryting in compose \(error.localizedDescription)")
                }
            }
        }
    }
}

//#Preview {
//    ComposeMessageView(composeFlag: true)
//}
