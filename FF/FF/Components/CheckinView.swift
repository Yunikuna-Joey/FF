//
//  CheckinView.swift
//  FF
//
//

import SwiftUI
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseStorage
import PhotosUI
import CropViewController

struct CheckinView: View {
    // env variable to access status functionality
    @EnvironmentObject var statusModel: StatusProcessView
    @EnvironmentObject var viewModel: AuthView
    
    // this is going to hold status Content
    @State private var statusField: String = ""
    
    // no duplicates within a set
    @State private var bubbleChoice: [String] = []
    
    // Available options to choose from [needed state to bind objects to view... to mutate them from off the bottom => top and <=>]
    @State private var bubbles = ["Abs", "Arms", "Back", "Chest", "Legs", "Push", "Pull"]
    
    // Hashmap to map the caption to its color
    @State private var colors: [String: Color] = [
        "Abs": .red,
        "Arms": .orange,
        "Back": .yellow,
        "Chest": .green,
        "Legs": .blue,
        "Push": .purple,
        "Pull": .cyan
    ]
    
    // Checkin menu option here [recent]
    @State private var selectedOption: String = ""
    
    // Location options here
    @ObservedObject var locationManager = LocationManager.shared    // locationManager is shared instance
    
    // Dynamic list of nearby POI
    @State private var nearby: [String] = [""]
    
    // handles navigation
    @State private var isStatusPosted = false
    @Binding var currentTabIndex: Int
    
    // image picker
    @State private var imagePickerFlag: Bool = false
    @State private var cropImageFlag: Bool = false

    @State private var selectedImages: [UIImage] = []
    @State private var croppedImageList: [UIImage] = []
    @State private var currentImageIndex = 0
    @State private var currentImage: UIImage?
    
    // screen size
    let screenSize = UIScreen.main.bounds.size
    
    // # of columns for the bubble choices
    private let numberOfColumns = 4
    
    var body: some View {
        NavigationStack {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: numberOfColumns)
            
            ZStack {
                
                VStack {
                    
                    VStack {
                        
                        HStack(spacing: 10) {
                            if let currentUserObject = viewModel.currentSession {
                                if currentUserObject.profilePicture.isEmpty {
                                    // profile image on the left
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                }
                                
                                else {
                                    AsyncImage(url: URL(string: currentUserObject.profilePicture)) { phase in
                                        
                                        switch phase {
                                        case.empty:
                                            ProgressView()
                                                .frame(width: 30, height: 30)
                                            
                                        case.success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                               
                                            
                                        case.failure:
                                            Image(systemName: "xmark.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                            
                                        @unknown default:
                                            EmptyView()
                                        } // end of switch
                                        
                                    } // end of async image
                                }
                            }
                            
                            Text("\(viewModel.currentSession?.username ?? "")")
                                .font(.headline)
                            
                            Spacer()
                            
                            //*** test out image button here [remove later]
                            Button(action: {
                                print("Image button here.")
                                self.imagePickerFlag.toggle()
                            }) {
                                Image(systemName: "photo.on.rectangle.fill")
                                    .font(.title)
                            }
                            .sheet(isPresented: $imagePickerFlag, onDismiss: {
                                if !selectedImages.isEmpty {
                                    currentImageIndex = 0
                                    currentImage = selectedImages[currentImageIndex]
                                    cropImageFlag = true
                                    print("Selected images count: \(selectedImages.count)")
                                    print("Starting to crop image at index: \(currentImageIndex)")
                                }
                            }) {
                                MultiImagePicker(selectedImages: $selectedImages)
                                    .edgesIgnoringSafeArea(.all)
                            }
                            
                        } // end of HStack
                        .sheet(isPresented: $cropImageFlag) {
                            
                            ImageCrop(
                                image: $currentImage,
                                visible: $cropImageFlag,
                                onCropFinished: { croppedImage in
                                    DispatchQueue.main.async {
                                        croppedImageList.append(croppedImage)
                                        currentImageIndex += 1
                                        if currentImageIndex < selectedImages.count {
                                            
                                            self.currentImage = selectedImages[currentImageIndex]
                                            self.cropImageFlag = true
                                            print("Cropping next image at index: \(currentImageIndex)")
                                            
                                        }
                                        else {
                                            
                                            self.cropImageFlag = false
//                                            selectedImages.removeAll()
                                            print("Finished cropping all images.")
                                            
                                        }
                                    }
                                },
                                onCancel: {
                                    selectedImages.removeAll()
                                    croppedImageList.removeAll()
                                    currentImage = nil
                                    cropImageFlag = false
                                }
                            )
                            .edgesIgnoringSafeArea(.all)
                            
                        }
                        
                        // bubbles for the status
                        HStack {
                            ForEach(bubbleChoice.indices, id: \.self) { i in
                                let bubble = bubbleChoice[i]
                                let color = colors[bubble] ?? .black
                                Button(action: {
                                    // Remove from status
                                    bubbleChoice.remove(at: i)
                                    // Add back to bottom row
                                    bubbles.append(bubble)
                                }) {
                                    Text(bubble)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundColor(color)
                                        )
                                        .font(.callout)
                                }
                            }
                        } // end of HStack
                        
                        // User enters their status
                        TextField("What are you up to today", text: $statusField, axis: .vertical)
                            .padding(.top)
                            .padding(.bottom, 15)
                            .lineLimit(1...5)
                        
                        // Area for holding images that user wants to attach to a post
                        if !croppedImageList.isEmpty {
                            TabView {
                                ForEach(croppedImageList.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: croppedImageList[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: .infinity, maxHeight: screenSize.height * 0.20)
                                            .cornerRadius(5)
                                            .clipped()
                                        
                                        Button(action: {
                                            removeImage(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding([.top, .trailing], 10)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(height: screenSize.height * 0.20)
                            .cornerRadius(5)
                            
                        }
                        
                        // Checkin Field option.... need to determine what UI element to use [recent]
                        Menu {
                            Picker(selection: $selectedOption, label: EmptyView()) {
                                ForEach(nearby, id: \.self) { option in
                                    Text(option)
                                        .tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedOption.isEmpty ? "Select location" : selectedOption)
                                    .foregroundStyle(selectedOption.isEmpty ? Color.gray.opacity(0.75) : Color.primary)
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        .padding(.top, 5)
                        .onTapGesture {
                            // this should prompt the user location when this portion is gestured
                            LocationManager.shared.requestLocation()
                            searchNearby()
                        }
                        
                    } // end of inner vstack
                    .padding()
                    .background(
                        ZStack {
                            Color.white.opacity(0.2)
                            BlurView(style: .systemMaterial)
                        }
                    )
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(bubbles, id: \.self) { bubble in
                            Button(action: {
                                if bubbleChoice.contains(bubble) {
                                    // Remove the bubble from the bubbleChoice array
                                    if let indexToRemove = bubbleChoice.firstIndex(of: bubble) {
                                        bubbleChoice.remove(at: indexToRemove)
                                        bubbles.append(bubble)
                                    }
                                } 
                                else {
                                    // Append the bubble to the bubbleChoice array
                                    bubbleChoice.append(bubble)
                                    if let indexToRemove = bubbles.firstIndex(of: bubble) {
                                        bubbles.remove(at: indexToRemove)
                                    }
                                }
                            }) {
                                Text(bubble)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(colors[bubble] ?? .gray)
                                    )
//                                    .font(.system(.callout, design: .monospaced))
                                    .font(.callout)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 5)
                    
                    Spacer()
                    
                } // outer Vstack
                .padding()
                
                
                // Check-in button
                VStack {
                    Button(action: {
                        
                        // attempt to post the status into the database [submission]
                        Task {
                            do {
                                if let currentUserObject = viewModel.currentSession, let currentUserId = viewModel.currentSession?.id {
                                    // if there are selected images or user-provided images
                                    if !selectedImages.isEmpty {
                                        let imageUrls = try await statusModel.uploadImages(images: selectedImages)
                                        
                                        // This will save the pictures from the status object into the User datafield imageHashmap
                                        try await viewModel.updateUserImageHashMap(
                                            userId: currentUserId,
                                            newImageUrls: imageUrls
                                        )
                                        
                                        // send into firebase
                                        await statusModel.postStatus(
                                            currentUserObject: currentUserObject,
                                            userId: currentUserId,
                                            content: statusField,
                                            bubbleChoice: bubbleChoice,
                                            timestamp: Date(),
                                            location: selectedOption,
                                            likes: 0,
                                            imageUrls: imageUrls
                                        )
                                        
                                        
                                    }
                                    
                                    // if there are no selected images provided by the user
                                    else {
                                        await statusModel.postStatus(
                                            currentUserObject: currentUserObject,
                                            userId: currentUserId,
                                            content: statusField,
                                            bubbleChoice: bubbleChoice,
                                            timestamp: Date(),
                                            location: selectedOption,
                                            likes: 0,
                                            imageUrls: [""]
                                        )
                                    }
                                    
                                    // move to homeView after
                                    currentTabIndex = 0
                                    
                                    // reset page values
                                    resetPageValues()
                                    
                                } // variable unwrapping
                                
                            } // end of do closure
                            
                        } // end of task
                        
                        
                        // [revisit on prod]
                        printDimensions()
                        
                        
                    }) {
                        Rectangle()
                            .foregroundStyle(Color.blue)
                            .frame(width: screenSize.width, height: setButtonHeight())
                            .overlay(
                                Text("Check-In")
                                    .foregroundStyle(Color.white)
                            )
                    }
                }
                // adjust this for the button position
                .padding(.top, screenSize.height / 2)
                .disabled(!validForm)
                .opacity(validForm ? 1.0 : 0.5)
                
            } // end of zstack
            .padding()
            .background(
                BackgroundView()
            )
            
        } // end of navigationStack
        .onTapGesture { // attempt to remove the keyboard when tapping on the search results [anywhere outside of the textfield/keyboard]
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    } // end of var body
    
    private func resetPageValues() {
        // 'clears' the text input fields
        statusField = ""
        bubbleChoice = []
        selectedOption = ""
        isStatusPosted = false
        bubbles = ["Abs", "Arms", "Back", "Chest", "Legs", "Push", "Pull"]
        selectedImages = []
        croppedImageList = []
    }
    
    func printDimensions() {
        let width = screenSize.width
        let height = screenSize.height
        
        print("This is the current width \(width) and current height \(height)")
    }
    
    // not exactly screen dimensions, but [viewport]
    func setButtonHeight() -> CGFloat {
        // calculate the button height
        let screenHeight = screenSize.height
        let isProMax = screenHeight >= 900
        return isProMax ? screenHeight - 875 : screenHeight - 800   // ProMax height | Normal Height
    }
    
    private func searchNearby() {
        guard let currLocation = locationManager.userLocation else {
            print("Current location not available")
            return
        }
        
        // test coordinates
//        let lat = 33.783949360719454
//        let long = -117.89386927496363
        
//        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        let currLocation = CLLocation(latitude: lat, longitude: long)
        
        let coordinate = CLLocationCoordinate2D(latitude: currLocation.coordinate.latitude, longitude: currLocation.coordinate.longitude)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Gym"
        // unit of measurements is in meters... [1 mile = ~1609meters]
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for places: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Extract POI names from nearby places
            nearby = response.mapItems.compactMap { mapItem in
                if let name = mapItem.name, let location = mapItem.placemark.location {
                    let distance = location.distance(from: currLocation) / 1609.34
                    return "\(name) - \(String(format: "%.1f", distance)) miles away"
                }
                return nil
            }
            .sorted() // alphabetically sort the list
        }
    }
    
    private func removeImage(at index: Int) {
        croppedImageList.remove(at: index)
    }
    
} // end of structure declaration

extension CheckinView: StatusFormProtocol {
    var validForm: Bool {
        return !statusField.isEmpty && !selectedOption.isEmpty
    }
}

//*** image picker structure
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (() -> Void)?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked?() // Notify that the image is picked
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

//*** multiple image picker structure
struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: MultiImagePicker
        
        // *** initialize the picker
        init(parent: MultiImagePicker) {
            self.parent = parent
        }
        
        // *** handles dismissing the picker screen[sheet]
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // populates the state variable with all of the images the user picked
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        } // picker function
        
    } // end of class
    
    // create the object
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // configure the picker with certain settings
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        // max amount of pictures
        config.selectionLimit = 10 // 0 means no limit on pictures [change as needed]
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    // needed for UIViewControllerRepresentable [but blank cause nothing is happening]
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

//*** new image crop wrapper
struct ImageCrop: UIViewControllerRepresentable{
    @Binding var image: UIImage?
    @Binding var visible: Bool
    var onCropFinished: (UIImage) -> Void
    var onCancel: () -> Void

    class Coordinator: NSObject, CropViewControllerDelegate{
        let parent: ImageCrop

        init(_ parent: ImageCrop){
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            withAnimation {
                parent.visible = false
            }
            parent.onCropFinished(image)
        }

        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            withAnimation{
                parent.visible = false
            }
            parent.onCancel()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let img = self.image ?? UIImage()
        let cropViewController = CropViewController(image: img)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
}

struct CheckinView_Preview: PreviewProvider {
    static var previews: some View {
        CheckinView(currentTabIndex: .constant(0))
    }
}
