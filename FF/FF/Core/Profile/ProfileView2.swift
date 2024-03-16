//
//  ProfileView2.swift
//  FF
//
//

import SwiftUI

// Images view
struct ProfileView2: View {
    let imageArray = [
        "Car", 
        "car2",
        "terrifiednootnoot",
        "car3",
        "car4",
        "car5",
        "car6",
        "car7",
        "car8",
        "car9"
    ]
    let itemSize: CGFloat = (UIScreen.main.bounds.width - 40 - 20) / 3 - 10
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // enable scrolling behavior
            ScrollView {
                // grid to hold the pictures
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize))]) {
                    // iterate through the image array
                    ForEach(imageArray, id: \.self) {
                        imageName in Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: itemSize + 32, height: itemSize)
                            .cornerRadius(5)
                    }
                }
            }
        } // end of ZStack
    }
}

#Preview {
    ProfileView2()
}
