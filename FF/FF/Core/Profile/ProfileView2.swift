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
                ImageFullScreenView(imageName: imageInfo.imageName) {
                    currentImage = nil  // dismiss the full screen view
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
    let dismiss: () -> Void
    
    @State private var imageObject: UIImage?
    @State private var offset = CGSizeZero
    @State private var scale: CGFloat = 1
    @State private var zoomFlag = false
    
    @GestureState private var scaleState: CGFloat = 1
    @GestureState private var offsetState: CGSize = .zero
    
    // initialer for UIimage
    init(imageName: String, dismiss: @escaping () -> Void) {
        self.imageName = imageName
        self.dismiss = dismiss
        self._imageObject = State(initialValue: UIImage(named: imageName))
    }
    
    // zooming in / out
    var zoom: some Gesture {
        MagnificationGesture()
            .updating($scaleState) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                let newScale = scale * value
                
                // condition so that it cannot zoom out past the original image size
                if newScale >= 1 {
                    scale = newScale
                }
                else {
                    scale = 1
                }
                
                // determine whether or not the picture is zoomed
                if value >= 1 {
                    zoomFlag = true
                }
                else {
                    zoomFlag = false
                }
            }
    }
    
    // dragging around the image [window]
    var drag: some Gesture {
        DragGesture()
            .updating($offsetState) { currentState, gestureState, _ in
                gestureState = currentState.translation
            }
            .onEnded { value in
                // check if dragging is allowed based on zoom flag
                guard zoomFlag else { return }
            
                offset.height += value.translation.height
                offset.width += value.translation.width
                
            }
    }
    
    var body: some View {
        ZStack {
            // black background to set up the full screen image
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            // Display the image that was clicked
            Image(uiImage: imageObject!)
                .resizable()
                .scaledToFit()
                .scaleEffect(self.scale * scaleState)
                .offset(x: offset.width + offsetState.width, y: offset.height + offsetState.height)
                .gesture(SimultaneousGesture(zoom, drag))
            
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
