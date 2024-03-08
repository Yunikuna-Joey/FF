//
//  HomeView.swift
//  FF
//
//

import SwiftUI

// Status updates [will need to do some work to dynamically retrieve per user] 
struct HomeView: View {
    var body: some View {
        // Scroll behavior for multiple statuses
        ScrollView {
            // vertical for ordering [spacing between each status update is controlled]
            VStack(spacing: 10) {
                // for loop, to iterate through each status update element [dynamic way of creating dummy data]
                ForEach(1..<10) { index in
                    StatusUpdateView(username: "User \(index)", timeAgo: "\(index)m ago", status: "This is the status update text. It can be as long as you want.")
                }
            }
            // create some extra spacing
            .padding()
        }
    }
}

// status update structure,,, what each update will follow in terms of pieces
struct StatusUpdateView: View {
    // immutatable for each specific user
    let username: String
    let timeAgo: String
    let status: String
    
    
    var body: some View {
        // what each individual update is going to follow [stacked bottom to top]
        VStack(alignment: .leading, spacing: 10) {
            // stacked left to right
            HStack(spacing: 10) {
                // image on the left
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
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            // below the left => right will be the actual status
            Text(status)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}


#Preview {
    HomeView()
}
