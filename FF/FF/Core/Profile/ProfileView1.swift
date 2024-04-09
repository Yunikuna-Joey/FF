//
//  ProfileView1.swift
//  FF
//
//

import SwiftUI

struct ProfileView1: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
    ]
    
    var body: some View {
        // Scroll behavior for multiple statuses
        ScrollView {
            // vertical for ordering [spacing between each status update is controlled]
            VStack(spacing: 10) {
                // for loop, to iterate through each status update element [dynamic way of creating dummy data]
//                ForEach(statusProcess.statusList) { status in
//                    if let currentUser = viewModel.currentSession {
//                        ProfileStatusUpdateView(status: status, username: currentUser.username, timeAgo: status.timestamp, colors: colors)
//                    }
//                }
                
                ForEach(1..<10) { index in
                    ProfileStatusUpdateView(
                        username: "User \(index)",
                        timeAgo: "\(index)m ago",
                        status: "Checked in at this location (5 miles away)")
                }
            }
            // create some extra spacing
            .padding()
        }
    }
}

// status update structure,,, what each update will follow in terms of pieces
struct ProfileStatusUpdateView: View {
    // status object
//    let status: Status
    
    // immutatable for each specific user
    let username: String
    let timeAgo: String
//    let timeAgo: Date
    let status: String
    
    // Color bubbles original list
//    let colors: [String: Color]
    
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
//                Text(formatTimeAgo(from: timeAgo))
//                    .font(.caption)
//                    .foregroundColor(.gray)
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // For loop to gather all statuses associated with logged-in user
            HStack {
                // **** This is for actual production logic
//                ForEach(status.bubbleChoice, id: \.self) { bubble in
//                    let color = colors[bubble] ?? .gray
//                    Text(bubble)
//                        .foregroundStyle(Color.white)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 5)
//                        .background(
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(color)
//                        )
//                        .font(.callout)
//                }
                // keep this for loop for now, so that we can see the preview
                Text("Bubble 1")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
                
                Text("Bubble 2")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
                
                Text("Bubble 3")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
            }
            

            // below the left => right will be the actual status
//            Text(status.content)
//                .font(.body)
            Text(status)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // helper function to achieve time stamps associated with statuses
    func formatTimeAgo(from date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        guard let formattedString = formatter.string(from: date, to: Date()) else {
            return "Unknown"
        }
        
        // Debugging statement
        print("\(formattedString) + ago")
        return formattedString + " ago"
    }
}


#Preview {
    ProfileView1()
}
