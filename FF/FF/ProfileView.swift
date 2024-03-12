//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

struct ProfileView: View {
    @State private var currentTab: Tab = .status
    
    enum Tab {
        case status
        case images
        case other
    }
    
    let username = "abcdefghi"
    let value1 = 15
    
    
    
    var body: some View {
        ZStack {
            // Cover photo background
            Image("Car")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
            
            VStack(alignment: .center) {
                // Pushes the profile picture downwards by adding a spacer
                Spacer()
                
                // Profile image overlaid on the bottom half of the cover photo
                Image("car2")
                    .resizable()
                    .frame(width: 200, height: 150)
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .offset(y: 75) // Offset the profile image downwards
                
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            
            Spacer()
            
            
            VStack {
                Spacer().frame(height: 40)
                Text("@\(username)")
                
                    .font(.headline)
                    .padding()
                
//                Spacer().frame(height: 7)
                
                HStack {
                    VStack {
                        Text("Check-ins")
                            
                            .font(.headline)
                        
                        Text("\(value1)")
                            
                            .font(.headline)
                    }
                    
                    Spacer().frame(width: 75)
                    
                    VStack {
                        Text("Follower")
                            
                            .font(.headline)
                        
                        Text("\(value1)")
                            
                            .font(.headline)
                    }
                    
                    Spacer().frame(width: 75)
                    
                    VStack {
                        Text("Following")
                            
                            .font(.headline)
                        
                        Text("\(value1)")
                            
                            .font(.headline)
                    }
                    
                } // end of hstack for statistics
                
            } // end of vstack for username and statistics
            .offset(y: 200)
            
            
            
            HStack {
                Button(action: {
                    currentTab = .status
                }) {
                    Image(systemName: "person.fill")
                        .padding()
                }
                
                Button(action: {
                    currentTab = .images
                }) {
                    Image(systemName: "chart.bar.fill")
                        .padding()
                }
                
                Button(action: {
                    currentTab = .other
                }) {
                    Image(systemName: "photo.fill")
                        .padding()
                }
                
                
            } // end of hstack for the icons
            .foregroundColor(.blue)
            .padding(.bottom, 20)

            switch currentTab  {
            case .status:
                ProfileView1()
            case .images:
                ProfileView2()
            case .other:
                ProfileView3()
            }
            
            
        } // end of ZStack
    }
}

#Preview {
    ProfileView()
}
