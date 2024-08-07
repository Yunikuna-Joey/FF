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
        "Abs": .red,
        "Arms": .orange,
        "Back": .yellow,
        "Chest": .green,
        "Legs": .blue,
        "Push": .purple,
        "Pull": .cyan
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
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
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
                
                Text(ConstantFunction.formatTimeAgo(from: status.timestamp))
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
                .padding(.bottom, 5)
            
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
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: screenSize.height * 0.50)
                                    .cornerRadius(5)
                                    .clipped()
                                
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
                .frame(height: screenSize.height * 0.50)
                .cornerRadius(5)
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
                        .foregroundStyle(Color.primary)
                        .monospacedDigit()
                        
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
                        .foregroundStyle(Color.primary)
                        .monospacedDigit()
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
        .background(
            ZStack {
                Color.white.opacity(0.2)
                BlurView(style: .systemMaterial)
            }
        )
        .cornerRadius(10)
        .shadow(radius: 2)
    } // end of body
    
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
