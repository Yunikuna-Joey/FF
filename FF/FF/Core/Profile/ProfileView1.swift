//
//  ProfileView1.swift
//  FF
//
//

import SwiftUI
import FirebaseAuth

struct ProfileView1: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    @State private var colors: [String: Color] = [
        "Abs": .red,
        "Arms": .orange,
        "Back": .yellow,
        "Chest": .green,
        "Legs": .blue,
        "Push": .purple,
        "Pull": .cyan
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 10) {

                ForEach(statusProcess.statusList) { status in
                    if let currentUser = viewModel.currentSession {
                        StatusUpdateView(status: status, username: currentUser.username, timeAgo: status.timestamp, colors: colors)
                    }
                }
            }
            // create some extra spacing
            .padding()
        }
        .onAppear {
            statusProcess.statusList.removeAll()
            statusProcess.fetchStatus(userId: Auth.auth().currentUser?.uid ?? "")
        }
    }
}


#Preview {
    ProfileView1()
}
