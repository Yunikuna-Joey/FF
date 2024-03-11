//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

struct ProfileView: View {
    // need to implement scroll view
    let username = "abcdefghi"
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
                Spacer()
                
                // Profile image overlaid on the bottom half of the cover photo
                Image("car2")
                    .resizable()
                    .frame(width: 200, height: 150)
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .offset(y: 75) // Offset the profile image downwards
                
                Text("@\(username)")
                    .offset(y: 95)
                    .font(.headline)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            
            
            
        } // end of ZStack
        Spacer()
    }
}

#Preview {
    ProfileView()
}
