//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

struct ProfileView: View {
    // Constants
    @State private var current: Tab = .status
    
    func currSelection(_ tab:Tab) -> Bool {
        return current == tab
    }
    
    enum Tab {
        case status
        case images
        case others
    }
    
    let username = "Womp Womp"
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
                HStack(spacing: screenWidth * 0.25) {
                    Button(action: {
                        current = .status
                    }) {
                        Image(systemName: "person.fill")
                            .padding()
                            .foregroundStyle(Color.blue)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .offset(y: 20)
                                    .foregroundStyle(currSelection(.status) ? .blue : .clear)
                            )
                    }
                    
                    Button(action: {
                        current = .images
                    }) {
                        Image(systemName: "photo.fill")
                            .padding()
                            .foregroundStyle(Color.blue)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .offset(y: 20)
                                    .foregroundStyle(currSelection(.images) ? .blue : .clear)
                            )
                    }
                    
                    Button(action: {
                        current = .others
                    }) {
                        Image(systemName: "calendar")
                            .padding()
                            .foregroundStyle(Color.blue)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .offset(y: 20)
                                    .foregroundStyle(currSelection(.others) ? .blue : .clear)
                            )
                    }
                    
                    
                } // end of hstack for the icons
                .foregroundColor(.blue)
                .offset(y: -screenHeight * 0.1)
                
                VStack {
                    // logic for switching different views
                    switch current {
                    case .status:
                        ProfileView1()
                    case .images:
                        ProfileView2()
                    case .others:
                        ProfileView3()
                    }
                }
                .offset(y: -screenHeight * 0.1)
                .padding(.horizontal, 5)
                .frame(minHeight: screenHeight * 0.45) // ensure that all content will be shown and not stuck under the safe area
                    
                
            } // end of VStack
            .offset(y: -screenHeight * 0.1)
        }
    }
}

#Preview {
    ProfileView()
}
