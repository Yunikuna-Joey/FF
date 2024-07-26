//
//  ToggleLocationView.swift
//  FF
//
//

import SwiftUI
import CoreLocation
import MapKit

struct ToggleLocationView: View {
    @EnvironmentObject var viewModel: AuthView
    
    // Checkin menu option here [recent]
    @State private var selectedOption: String = ""
    
    // Location options here
    @ObservedObject var locationManager = LocationManager.shared    // locationManager is shared instance
    
    // Dynamic list of nearby POI
    @State private var nearby: [String] = [""]
    
    var body: some View {
        ZStack {
            
            VStack {
                
                VStack {
                    
                    // username and profile picture
                    HStack(spacing: 10) {
                        if let currentUserObject = viewModel.currentSession {
                            if currentUserObject.profilePicture.isEmpty {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.blue)
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
                        
                        // ** This will indicate whether or not the location is "in-use"
                        Image(systemName: "circle.fill")
                            .foregroundStyle(Color.green)
                            .foregroundStyle(Color.red)
                        
                        Spacer()
                    }
                } // end of vstack
                
                HStack {
                    Text("Current:")
                        .font(.body)
                    
                    Spacer()
                    
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
                                .font(.footnote)
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
                    
                } // end of hstack
            } // end of VStack
            .padding()
            .background(
                ZStack {
                    Color.white.opacity(0.2)
                    BlurView(style: .systemMaterial)
                }
            )
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
            
        } // end of zstack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BackgroundView()
        )
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
}

#Preview {
    ToggleLocationView()
}
