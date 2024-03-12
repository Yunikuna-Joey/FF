//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

struct ProfileView: View {
    // Constants
    @State private var current: Tab = .status
    
    enum Tab {
        case status
        case images
        case others
    }
    
    let username = "name here"
    let value1 = 25
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            
            VStack {
                // Cover Photo
                Image("Car")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: screenHeight * 0.35)
                    .clipped()
                
                // profile picture
                Image("car2")
                    .resizable()
                    .frame(width: 200, height: 150)
                    .clipShape(Circle())
                    .offset(y: -100) // Adjust this multiplier as needed
                
                // username
                Text("@\(username)")
                    .font(.headline)
                    .offset(y: -screenHeight * 0.12)
                    
                // portion for user statistics
                HStack(spacing: screenWidth * 0.15) {
                    // category 1
                    VStack {
                        Text("Check-Ins")
                            .font(.headline)
                        Text("\(value1)")
                    }
                    
                    // category 2
                    VStack {
                        Text("Followers")
                            .font(.headline)
                        
                        Text("\(value1)")
                    }
                    
                    // category 3
                    VStack {
                        Text("Following")
                            .font(.headline)
                        
                        Text("\(value1)")
                    }
                    
                }
                .offset(y: -screenHeight * 0.1)
                
                // icons for different views
                HStack {
                    Button(action: {
                        current = .status
                    }) {
                        Image(systemName: "person.fill")
                            .padding()
                    }
                    
                    Button(action: {
                        current = .images
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .padding()
                    }
                    
                    Button(action: {
                        current = .others
                    }) {
                        Image(systemName: "photo.fill")
                            .padding()
                    }
                    
                    
                } // end of hstack for the icons
                .foregroundColor(.blue)
                .padding(.bottom, 20)
                
                // logic for switching different views
                switch current {
                case .status:
                    ProfileView1()
                case .images:
                    ProfileView2()
                case .others:
                    ProfileView3()
                }
                
            } // end of VStack
            .offset(y: -screenHeight * 0.1)
        }
    }
}

#Preview {
    ProfileView()
}
