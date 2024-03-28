//
//  CheckinView.swift
//  FF
//
//

import SwiftUI
import CoreLocation
import MapKit

struct CheckinView: View {
    // this is going to hold status Content
    @State private var statusField: String = ""
    
    // no duplicates within a set
    @State private var bubbleChoice: [(String, Color)] = []
    
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
    
    let username = "@Username"
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack(spacing: 10) {
                        // profile image on the left
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        
                        // Username
                        Text(username)
                            .font(.headline)
                        
                        Spacer()
                        
                    } // end of HStack
                    
                    // bubbles for the status
                    HStack {
                        ForEach(bubbleChoice.indices, id: \.self) { i in
                            let (bubble, _) = bubbleChoice[i]
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
                    
                } // end of vstack
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // bubbles at the bottom row
                HStack {
                    ForEach(bubbles.indices, id: \.self) { i in
                        let bubble = bubbles[i]
                        let color = colors[bubble] ?? .black
                        Button(action: {
                            // $0.0 is a method of referring to tupple (bubble, color) $0.0 == bubble $0.1 == color
                            if bubbleChoice.contains(where: { $0.0 == bubble }) {
                                bubbleChoice.removeAll(where: { $0.0 == bubble })
                            }
                            else {
                                bubbleChoice.append((bubble, color))
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
                                        .foregroundColor(color)
                                )
                                .font(.callout)
                        }
                    }
                } // end of HStack
                Spacer()
            }
            
            
            
            
            VStack {
                Button(action: {
//                    postStatus()
                    print("Circle button")
                }) {
                    Circle()
                        .foregroundStyle(Color.blue)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("Check-In")
                                .foregroundStyle(Color.white)
                        )
                }
            }
            // adjust this for the button position
            .padding(.top, 450)
            
        } // end of zstack
        .padding()
        
    } // end of var body
    
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

#Preview {
    CheckinView()
}
