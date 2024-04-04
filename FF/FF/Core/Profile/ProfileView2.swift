//
//  ProfileView2.swift
//  FF
//
//

import SwiftUI

// Images view
struct ProfileView2: View {
    // Determine the current device viewport dimensions
    let screenSize = UIScreen.main.bounds.size
    
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
    
    var body: some View {
        let itemWidth: CGFloat = (screenSize.width) / 3
        let itemHeight: CGFloat = (screenSize.height) * 0.10
        
        ZStack(alignment: .bottom) {
            // enable scrolling behavior
            ScrollView {
                // grid to hold the pictures
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemWidth))]) {
                    // iterate through the image array
                    ForEach(imageArray, id: \.self) {
                        imageName in Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: itemWidth + 50, height: itemHeight)
                            .cornerRadius(5)
                            .padding()
                    }
                }
            }
            
            // ***[omit] this portion in prod
            Button(action: {
                print("This is image width \(itemWidth)")
                print("This is image height \(itemHeight)")
            }) {
                Text("Click me for more information")
            }
        } // end of ZStack
    }
}

#Preview {
    ProfileView2()
}
