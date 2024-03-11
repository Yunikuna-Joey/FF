//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

struct ProfileView: View {
    // need to implement scroll view
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
            
            
            VStack {
                Spacer().frame(height: 40)
                Text("@\(username)")
                    .offset(y: 200)
                    .font(.headline)
                    .padding()
                
//                Spacer().frame(height: 7)
                
                HStack {
                    VStack {
                        Text("Check-ins")
                            .offset(y: 200)
                            .font(.headline)
                        
                        Text("\(value1)")
                            .offset(y: 200)
                            .font(.headline)
                    }
                    
                    Spacer().frame(width: 75)
                    
                    VStack {
                        Text("Follower")
                            .offset(y: 200)
                            .font(.headline)
                        
                        Text("\(value1)")
                            .offset(y: 200)
                            .font(.headline)
                    }
                    
                    Spacer().frame(width: 75)
                    
                    VStack {
                        Text("Following")
                            .offset(y: 200)
                            .font(.headline)
                        
                        Text("\(value1)")
                            .offset(y: 200)
                            .font(.headline)
                    }
                    
                } // end of hstack
            } // end of vstack
            
            
        } // end of ZStack
        Spacer()
    }
}

#Preview {
    ProfileView()
}
