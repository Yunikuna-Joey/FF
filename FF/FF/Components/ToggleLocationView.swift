//
//  ToggleLocationView.swift
//  FF
//
//

import SwiftUI
import CoreLocation
import MapKit

//* add a coordinate attached to User Object
//* update the existing data structure holding the location to hold [name of establishment: coordinate]
//* need to update the color of the activity circle depending on if the location is active or not 

struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    var description: String {
        return "Lat: \(latitude), Long: \(longitude)"
    }
    
    var numDescription: (Double, Double) {
        return (latitude, longitude)
    }
}

struct ToggleLocationView: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var followManager: FollowingManager
    
    // Checkin menu option here [recent]
    @State private var selectedOption: String = ""
    
    // Location options here
    @ObservedObject var locationManager = LocationManager.shared    // locationManager is shared instance
    
    // Dynamic list of nearby POI [This is for the picker menu (front-end)]
    @State private var nearby: [String] = [""]
    @State private var nearbyCoord: [String: Coordinate] = [:]
    @State private var selectedCoord: Coordinate?
    
    // hashmap to hold all of the following <-> follower relationship coordinate values
    @State private var communityCoordHashmap: [User: Coordinate?] = [:]
    @State private var followerList: [User] = []
    @State private var followingList: [User] = []
    @State private var masterList: [User] = []
    
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
                    .onChange(of: selectedOption) { newValue, _ in
                        if let coordinate = nearbyCoord[newValue] {
                            selectedCoord = coordinate
                            //** This is for currentSession updating
                            updateUserLocation(coordinate)
                            //** Attempts to modify the location
                            Task {
                                try await viewModel.updateUserLocationDB(userId: viewModel.currentSession?.id ?? "", coordinate: coordinate)
                            }
                            print("[ToggleLocationView]: \(viewModel.currentSession)")
                            
                            // 50-meter range for comparison [100 is working]
                            let thresholdDistance: CLLocationDistance = 50.0
                            
                            // Iterate through communityCoordHashmap
                            for (key, value) in communityCoordHashmap {
                                print("Key: \(key.username), Value: \(value?.description ?? "No Coordinate")")
                                
                                // Ensure the current user has valid coordinates
                                if let userCoord = viewModel.currentSession?.currCoordinate {
                                    let currentUserCoord = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
                                    
                                    // Ensure the other user has valid coordinates
                                    if let otherUserCoordValue = value {
                                        let otherUserCoord = CLLocation(latitude: otherUserCoordValue.latitude, longitude: otherUserCoordValue.longitude)
                                        
                                        // Calculate the distance between the two users
                                        let distance = currentUserCoord.distance(from: otherUserCoord)
                                        
                                        // Check if they are within the threshold distance
                                        if distance <= thresholdDistance {
                                            print("Found a match!")
                                            print("User within range: \(key.username)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } // end of hstack
                
                if let coordinate = viewModel.currentSession?.currCoordinate {
                    Text(coordinate.description)
                        .padding()
                        .foregroundStyle(Color.red)
                }
                else {
                    Text("There is no current coordinate for this user")
                        .padding()
                        .foregroundStyle(Color.blue)
                }
                
        
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
        .onAppear {
            // This will handle the backend process of updating the location coordinates
            // of those who the current user follows and if they following follows back
            
            //** naive approach: go through the following and follower list to determine who gets updated with the location
            Task {
                if let currentUserObject = viewModel.currentSession {
                    followerList = try await followManager.queryFollowers(userId: currentUserObject.id)
                    followingList = try await followManager.queryFollowing(userId: currentUserObject.id)
                    
                    // determine which users to add into the master list [contains all users that match the mutual relationship condition]
                    for follower in followerList {
                        if followingList.contains(follower) {
                            masterList.append(follower)
                        }
                    }
                    
                    
                    // for all the user objects in list
                    for userObject in masterList {
                        // update the community coords for each user with their respective current coordinates
                        communityCoordHashmap[userObject] = userObject.currCoordinate
                    }
                }
                
                print("[ToggleLocationOnAppear]: This is community pool -- \(communityCoordHashmap)")
            }
            
            
            
        }
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
//            nearby = response.mapItems.compactMap { mapItem in
//                if let name = mapItem.name, let location = mapItem.placemark.location {
//                    let distance = location.distance(from: currLocation) / 1609.34
//                    return "\(name) - \(String(format: "%.1f", distance)) miles away"
//                }
//                return nil
//            }
//            .sorted() // alphabetically sort the list
            
            var tempNearby: [String] = []
            var tempNearbyLocations: [String: Coordinate] = [:]
            
            //** Attempt to implement rounding to fix matching logic in front-end
            for mapItem in response.mapItems {
                if let name = mapItem.name, let location = mapItem.placemark.location {
                    let distance = location.distance(from: currLocation) / 1609.34
                    let locationName = "\(name) - \(String(format: "%.1f", distance)) miles away"
                    tempNearby.append(locationName)
                    tempNearbyLocations[locationName] = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }
            }
            
            nearby = tempNearby.sorted().reversed()
            nearbyCoord = tempNearbyLocations
        }
    }
    
    //** This will update the coordinate for the User object
    private func updateUserLocation(_ coordinate: Coordinate) {
        viewModel.currentSession?.currCoordinate = coordinate
    }
}

#Preview {
    ToggleLocationView()
}
