//
//  HomeView.swift
//  FF
//
//

import SwiftUI
import FirebaseFirestore

// Status updates [Dynamically retrieves self-user statuses... need more work for dynamic following]
struct HomeView: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    var body: some View {
        // Scroll behavior for multiple statuses
        ScrollView {
            // vertical for ordering [spacing between each status update is controlled]
            VStack(spacing: 10) {
                // for loop for processing a user's status's
                ForEach(statusProcess.statusList) { status in
                    if let currentUser = viewModel.currentSession {
                        StatusUpdateView(status: status, username: currentUser.username, timeAgo: status.timestamp)
                    }
                }
            }
            // create some extra spacing
            .padding()
        }
        .onAppear {
            // query the process to start fetching statuses based on current string user id else { blank }
            statusProcess.fetchStatus(userId: viewModel.queryCurrentUserId() ?? "")
        }
    }
}

// status update structure,,, what each update will follow in terms of pieces
struct StatusUpdateView: View {
    let status: Status
    
    // immutatable for each specific user
    let username: String
    let timeAgo: Date
    
    
    var body: some View {
        // what each individual update is going to follow [stacked bottom to top]
        VStack(alignment: .leading, spacing: 10) {
            // stacked left to right
            HStack(spacing: 10) {
                // profile image on the left
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                
                // username text next to image
                Text(username)
                    .font(.headline)
                
                // space between
                Spacer()
                
                // time that message was 'created'
                Text(formatTimeAgo(from: timeAgo))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                ForEach(status.bubbleChoice, id: \.self) { bubble in
                    Text(bubble)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                        )
                        .font(.callout)
                }
            }
            

            // below the left => right will be the actual status
            Text(status.content)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // helper function to achieve time stamps associated with status's
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
    HomeView()
}
