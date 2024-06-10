//
//  LoadProfileView1.swift
//  FF
//
//

import SwiftUI
import FirebaseAuth

struct LoadProfileView1: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
    ]
    
    let resultUser: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(statusProcess.statusList) { status in
                    LoadProfileStatusUpdateView(resultUser: resultUser, status: status, colors: colors)
                }
            }
            .padding()
        }
        .onAppear {
            statusProcess.statusList.removeAll()
            statusProcess.fetchStatus(userId: resultUser.id)
        }
    }
}

struct LoadProfileStatusUpdateView: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    // listens for like count changes
    @State private var likeCount: Int = 0
    @State private var likeFlag: Bool = false
    
    @State private var commentCount: Int = 0
    @State private var commentFlag: Bool = false
    
    let resultUser: User
    let status: Status
    
    let colors: [String: Color]
    
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if resultUser.profilePicture.isEmpty {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.blue)
                }
                
                else {
                    AsyncImage(url: URL(string: resultUser.profilePicture)) { phase in
                        switch phase {
                        case.empty:
                            ProgressView()
                                .frame(width: 30, height: 30)
                            
                        case.success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            
                        case.failure:
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Spacer()
                            }
                            .padding()
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text(resultUser.username)
                    .font(.headline)
                
                Spacer()
                
                Text(formatTime(from: status.timestamp))
                    .font(.caption)
                    .foregroundStyle(.gray)
            } // end of HStack
            
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
            } // end of HStack
            
            Text(status.content)
                .font(.body)
            
            if !status.imageUrls.isEmpty {
                TabView {
                    ForEach(status.imageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: screenSize.height * 0.40)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: screenSize.height * 0.40)
                                
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
                         
                    } // end of for loop
                    
                } // end of TabView
                .tabViewStyle(PageTabViewStyle())
                .frame(height: screenSize.height * 0.40)
            }
            
            //*** bottom border
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
                .padding(.vertical, 5)

            
            HStack(spacing: 20) {
                //** Like button
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
                        .fill(likeFlag ? Color.blue.opacity(0.75) : Color.clear)
                        .frame(width: 50, height: 30)
                )
                
                //** Comment button
                Button(action: {
                    print("Comment Button")
                    commentFlag.toggle()
                }) {
                    Image(systemName: "bubble")
                        .foregroundStyle(Color.gray)
                    
                    Text("\(commentCount)")
                        .foregroundStyle(Color.black)
                }
                .sheet(isPresented: $commentFlag) {
                    CommentView(status: status)
                }
                
                // push to the left so its aligned-left
                Spacer()
            }
            .padding(.top, 10)
        } // end of VStack
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    } // end of body
    
    // helper function to achieve time stamps associated with statuses
    func formatTime(from date: Date) -> String {
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
//
//#Preview {
//    LoadProfileView1()
//}

//struct LoadProfileView1_Previews: PreviewProvider {
//    static var previews: some View {
//        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "", coverPicture: "")
//        LoadProfileView1(resultUser: user)
//    }
//}
