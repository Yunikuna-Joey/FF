//
//  ProfileView2.swift
//  FF
//
//

import SwiftUI

struct ImageInfo: Identifiable {
    let id = UUID()
    let imageName: String
}

// Images view
struct ProfileView2: View {
    @State private var currentImage: ImageInfo?
    
    // Determine the current device viewport dimensions
    let screenSize = UIScreen.main.bounds.size
    
    // need to dynamically gather user's photos at some point********
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
    ].map { ImageInfo(imageName: $0) }
    
    var body: some View {
        let itemWidth: CGFloat = (screenSize.width) / 3
        let itemHeight: CGFloat = (screenSize.height) * 0.10
        
        ZStack(alignment: .bottom) {
            // enable scrolling behavior
            ScrollView {
                // grid to hold the pictures
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemWidth))]) {
                    // iterate through the image array
                    ForEach(imageArray) { imageInfo in
                        Button(action: {
                            currentImage = imageInfo
                        }) {
                            Image(imageInfo.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: itemWidth + 50, height: itemHeight)
                                .cornerRadius(5)
                                .padding()
                        }
                    }
                }
            }
            .fullScreenCover(item: $currentImage) { imageInfo in
                if let index = imageArray.firstIndex(where: { $0.id == imageInfo.id }) {
                    ImageFullScreenView(imageName: imageInfo.imageName, currentIndex: index, imageArray: imageArray.map { $0.imageName }) {
                        currentImage = nil  // dismiss the full screen view
                    }
                }
            }
            
            // ***[omit] this portion in prod
//            Button(action: {
//                print("This is image width \(itemWidth)")
//                print("This is image height \(itemHeight)")
//            }) {
//                Text("Click me for more information")
//            }
        } // end of ZStack
    }
}

struct ImageFullScreenView: View {
    let imageName: String
    let currentIndex: Int
    let imageArray: [String]
    let dismiss: () -> Void
    
    var body: some View {
        ZStack {
            // black background to set up the full screen image
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            // Display the image that was clicked
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            // close button to exit the full screen view
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(Color.white)
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                } // end of Hstack
                Spacer()
            } // end of Vstack
        }
    }
}

#Preview {
    ProfileView2()
}
