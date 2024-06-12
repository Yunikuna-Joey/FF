//
//  ProfileView2.swift
//  FF
//
//

import SwiftUI

//struct ImageInfo: Identifiable {
//    let id = UUID()
//    let imageName: String
//}

struct ImageUrlWrapper: Identifiable {
    let id = UUID()
    let urlString: String
}

// Images view
struct ProfileView2: View {
    @EnvironmentObject var viewModel: AuthView
//    @State private var currentImage: ImageInfo?
    @State private var currentImageUrl: ImageUrlWrapper?
    
    // Determine the current device viewport dimensions
    let screenSize = UIScreen.main.bounds.size
    
    // need to dynamically gather user's photos at some point********
//    let imageArray = [
//        "Car", 
//        "car2",
//        "terrifiednootnoot",
//        "car3",
//        "car4",
//        "car5",
//        "car6",
//        "car7",
//        "car8",
//        "car9"
//    ].map { ImageInfo(imageName: $0) }
    
    var body: some View {
        let itemWidth: CGFloat = (screenSize.width) / 3
        let itemHeight: CGFloat = (screenSize.height) * 0.10
        
        ZStack(alignment: .bottom) {
            // enable scrolling behavior
            ScrollView {
                // grid to hold the pictures
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemWidth))]) {
                    // iterate through the image array
                    
                    //*** need to populate the imageHashMap list and iterate through
                    if let currentUserObject = viewModel.currentSession {
                        // Sort the keys of the dictionary
                        let sortedKeys = currentUserObject.imageHashMap.keys.sorted()
                        
                        // Iterate through the sorted keys
                        ForEach(sortedKeys.reversed(), id: \.self) { key in
                            if let pictureUrls = currentUserObject.imageHashMap[key] {
                                TabView {
                                    ForEach(pictureUrls, id: \.self) { urlString in
                                        Button(action: {
                                            currentImageUrl = ImageUrlWrapper(urlString: urlString)
                                        }) {
                                            AsyncImage(url: URL(string: urlString)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 30, height: 30)
                                                    
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: itemWidth + 50, height: itemHeight)
                                                        .cornerRadius(5)
                                                        .padding()
                                                    
                                                case .failure:
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
                                                } // end of switch statement
                                                
                                                
                                            } // end of async image closure
                                            
                                        } // button
                                        
                                    } // end of inner for-loop
                                    
                                } // Tab View
                                .frame(width: itemWidth + 50, height: itemHeight)
                                .tabViewStyle(PageTabViewStyle())
                                .cornerRadius(5)
                                .padding()
                            
                            } // variable unwrap
                            
                        } // end of for loop
                        
                    } // end of optional variable unwrapping
                    
                } // end of LazyVGRid
                
            } // end of Scroll View
            .fullScreenCover(item: $currentImageUrl) { imageWrapper in
                ImageFullScreenView(imageUrl: imageWrapper.urlString) {
                    currentImageUrl = nil  // dismiss the full screen view
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
        .onAppear {
            if let currentUserObject = viewModel.currentSession {
                viewModel.listenForUpdates(userObject: currentUserObject)
            }
            
        }
    }
}

struct ImageFullScreenView: View {
    let imageUrl: String
    let dismiss: () -> Void
    
    @State private var imageObject: UIImage?
    @State private var offset = CGSizeZero
    @State private var scale: CGFloat = 1
    @State private var zoomFlag = false
    
    @GestureState private var scaleState: CGFloat = 1
    @GestureState private var offsetState: CGSize = .zero
    
    // initialer for UIimage
    init(imageUrl: String, dismiss: @escaping () -> Void) {
        self.imageUrl = imageUrl
        self.dismiss = dismiss
        self._imageObject = State(initialValue: UIImage(named: imageUrl))
        loadImageFromUrl(imageUrl)
    }
    
    // function to grab image from a url
    private func loadImageFromUrl(_ url: String) {
        guard let imageUrl = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.imageObject = UIImage(data: data)
            }
        }
        task.resume()
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
                    // resets the image regardless of drag
                    offset.width = 0
                    offset.height = 0
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
                
//                print("Max width value: \(maxWidth)")
//                print("ScaledWidth value: \(scaledWidth)")
                print("This is scale value \(scale)")
                print("\n")
            }
    }
    
    var body: some View {
        ZStack {
            // black background to set up the full screen image
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if let imageObject = imageObject {
                // determines the left and right bounds of a zoomed state,,, need a height at another time
                let maxWidth = ((imageObject.size.width) / 10) * scale    // left and right bound calc,, could be refined
                
                // Display the image that was clicked
                Image(uiImage: imageObject)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(self.scale * scaleState)
                //                .offset(x: offset.width + offsetState.width, y: offset.height + offsetState.height)
                // this creates the clamp for the max and min
                    .offset(x: min(max(offset.width + offsetState.width, -maxWidth), maxWidth),
                            y: offset.height + offsetState.height)
                    .gesture(SimultaneousGesture(zoom, drag))
            }
            
            else {
                ProgressView()
                    .onAppear {
                        loadImageFromUrl(imageUrl)
                    }
            }
            
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
            
            Button(action: {
                print("\n")
                print("These are the current offset values")
                print("Offset width: \(offset.width)")
                print("OffsetState width: \(offsetState.width)")
                print("Offset height: \(offset.height)")
                print("OffsetState height: \(offsetState.height)")
                if let image = imageObject {
                    let width = image.size.width
                    let height = image.size.height
                    print("Image Width: \(width)")
                    print("Image Height: \(height)")
                }
                
            }) {
                Image(systemName: "info.bubble")
                    .foregroundStyle(Color.white)
                    .font(.title)
                    .padding()
            }
        }
    }
}

#Preview {
    ProfileView2()
}
