//
//  HomeView.swift
//  FF
//
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Status updates [Dynamically retrieves self-user statuses... need more work for dynamic following]
struct HomeView: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    // dicionary for colors processed on client-side
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
    ]
    
    var body: some View {
        // Scroll behavior for multiple statuses
        ScrollView(showsIndicators: false) {
            // vertical for ordering [spacing between each status update is controlled]
            VStack(spacing: 10) {
                // for loop for processing a user's status's
//                ForEach(statusProcess.feedList) { status in
                ForEach(statusProcess.feedList.sorted(by: { $0.timestamp > $1.timestamp })) { status in
                    
                    StatusUpdateView(
                        status: status,
                        username: status.username,
                        timeAgo: status.timestamp,
                        colors: colors
                    )
                    
                }
            }
            // create some extra spacing
            .padding()
        }
        .onAppear {
            statusProcess.feedList.removeAll()
                        
            // query statuses for following based on current string user id else { blank }
            statusProcess.fetchFeed(userId: viewModel.queryCurrentUserId() ?? "") { statuses in
                for status in statuses {
                    statusProcess.feedList.append(status)
//                    print("This is the value of status \(status)")
                }
            }
            
           
            // Then in main view, we sort the list by timestamp
            print("This is the value of feedlist: \(statusProcess.feedList)")
        }
    }
}

// status update structure,,, what each update will follow in terms of pieces
struct StatusUpdateView: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    // listens for like count changes
    @State private var likeCount: Int = 0
    @State private var likeFlag: Bool = false
    // status object
    let status: Status
    
    // immutatable for each specific user
    let username: String
    let timeAgo: Date
    
    // Color Bubbles here
    let colors: [String: Color]
    
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
                    let color = colors[bubble] ?? .gray
                    Text(bubble)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(color)
                        )
                        .font(.callout)
                }
            }
            

            // below the left => right will be the actual status
            Text(status.content)
                .font(.body)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEach(status.imageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                } // end of hstack
                .padding(.trailing, 25)
            }
            .padding(.leading, 0)
            .padding(.bottom)

            
            HStack {
                Button(action: {
                    Task {
                        likeCount = try await statusProcess.likeStatus(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "")
                        likeFlag.toggle()
                    }
                }) {
                    Image(systemName: likeFlag ? "heart.fill" : "heart")
                        .foregroundStyle(likeFlag ? Color.red : Color.gray)
                    
                    Text("\(likeCount)")
                        .foregroundStyle(Color.black)
//                        .foregroundStyle(likeFlag ? Color.red : Color.gray)
                        
                }
                .foregroundStyle(Color.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 50, height: 30)
                )
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(likeFlag ? Color.blue.opacity(0.80) : Color.clear)
                        .frame(width: 50, height: 30)
                )
            }

            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            Task {
                // initialize all the like counts for each status
                likeCount = try await statusProcess.fetchLikeCount(postId: status.id)
                likeFlag = try await statusProcess.fetchLikeFlag(postId: status.id, userId: Auth.auth().currentUser?.uid ?? "")
            }
        }
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
