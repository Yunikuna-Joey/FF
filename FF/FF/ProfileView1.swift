//
//  ProfileView1.swift
//  FF
//
//

import SwiftUI

struct ProfileView1: View {
    var body: some View {
        // Scroll behavior for multiple statuses
        ScrollView {
            // vertical for ordering [spacing between each status update is controlled]
            VStack(spacing: 10) {
                // for loop, to iterate through each status update element [dynamic way of creating dummy data]
                ForEach(1..<10) { index in
                    StatusUpdateView(
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
    // immutatable for each specific user
    let username: String
    let timeAgo: String
    let status: String
    
    
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
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            HStack {
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
    ProfileView1()
}
