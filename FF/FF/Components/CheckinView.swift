//
//  CheckinView.swift
//  FF
//
//

import SwiftUI
import CoreLocation
import MapKit
import FirebaseAuth
import PhotosUI

struct CheckinView: View {
    // env variable to access status functionality
    @EnvironmentObject var statusModel: StatusProcessView
    @EnvironmentObject var viewModel: AuthView
    
    // this is going to hold status Content
    @State private var statusField: String = ""
    
    // no duplicates within a set
    @State private var bubbleChoice: [String] = []
    
    // Available options to choose from [needed state to bind objects to view... to mutate them from off the bottom => top and <=>]
    @State private var bubbles = ["🦵Legs", "🫸Push", "Pull", "Upper", "Lower"]
    
    // Hashmap to map the caption to its color
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
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
//    @State private var selectedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    
    // screen size
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack {
                    
                    VStack {
                        
                        HStack(spacing: 10) {
                            
                            // profile image on the left
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                            
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
//                            .sheet(isPresented: $imagePickerFlag) {
//                                ImagePicker(selectedImage: $selectedImage)
//                            }
                            .sheet(isPresented: $imagePickerFlag) {
                                MultiImagePicker(selectedImages: $selectedImages)
                            }
                            
                        } // end of HStack
                        
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
                            .padding(.bottom, 25)
                            .lineLimit(1...5)
                        
                        //*** previous iteration of feature
//                        if let selectedImage = selectedImage {
//                            Image(uiImage: selectedImage)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 100, height: 100)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                        }
                        
                        // ** horizontal scrolling for the images picked
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding()
                        
                        
                        // Checkin Field option.... need to determine what UI element to use [recent]
                        HStack {
                            Text("Select your location")
                            Spacer()
                            Picker(selection: $selectedOption, label: Text("Choose your option")) {
                                ForEach(nearby, id: \.self) { option in
                                    Text(option)
                                        .tag(option) // Tag the Text view with the option
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                        } // end of hstack
                        .onTapGesture {
                            // this should prompt the user location when this portion is gestured
                            LocationManager.shared.requestLocation()
                            searchNearby()
                        }
                        
                    } // end of inner vstack
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    // bubbles at the bottom row
                    HStack {
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
                                    .font(.callout)
                            }
                        }
                    } // end of HStack
                    Spacer()
                    
                } // outer Vstack
                .padding()
                
                // [testing padding here for everything in the vstack except for the check-in button]
                //            .padding(.top, 40)
                
                // Check-in button
                VStack {
                    Button(action: {
                        let timestamp = Date()
                        let userId = viewModel.queryCurrentUserId()
                        
                        // attempt to post the status into the database [submission]
                        Task {
                            do {
                                // send into firebase
                                await statusModel.postStatus(
                                    userId: userId ?? " ",
                                    username: viewModel.currentSession?.username ?? "",
                                    content: statusField,
                                    bubbleChoice: bubbleChoice,
                                    timestamp: timestamp,
                                    location: selectedOption,
                                    likes: 0
                                )
                                
                                // boolean flag to track
//                                isStatusPosted = true
                                
                                currentTabIndex = 0
                                
                                // reset page values
                                resetPageValues()
                            }
                            
                        }
                        
                        
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
            
        } // end of navigationStack
        .onTapGesture {             // attempt to remove the keyboard when tapping on the search results [anywhere outside of the textfield/keyboard]
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    } // end of var body
    
    private func resetPageValues() {
        // 'clears' the text input fields
        statusField = ""
        bubbleChoice = []
        selectedOption = ""
        isStatusPosted = false
        bubbles = ["🦵Legs", "🫸Push", "Pull", "Upper", "Lower"]
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
                    return "\(name) - \(String(format: "%.2f", distance)) miles away"
                }
                return nil
            }
            .sorted() // alphabetically sort the list
        }
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
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
        
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

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
        config.selectionLimit = 7 // 0 means no limit on pictures [change as needed]
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    // needed for UIViewControllerRepresentable [but blank cause nothing is happening]
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

struct CheckinView_Preview: PreviewProvider {
    static var previews: some View {
        CheckinView(currentTabIndex: .constant(0))
    }
}
