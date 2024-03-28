//
//  LocationManager.swift
//  FF
//
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    // handle changes
    private let manager = CLLocationManager()
    
    // Listens for changes in the user location
    @Published var userLocation: CLLocation?
    
    // ***optional allow for location manager to be accessed throughout the entire app
    static let shared = LocationManager()
    
    // overwrites the default NSObject init
    override init() {
        super.init()
        // refer to the LocationManager for best location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    // provides the dialogue prompt as a function
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // function that will trigger when the location services permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            // the different cases here
            case .notDetermined:
                print("[DEBUG]: Location not determined")
            case .restricted:
                print("[DEBUG]: Location is restricted")
            case .denied:
                print("[DEBUG]: Location was denied")
            case .authorizedAlways:
                print("[DEBUG]: Location always allowed")
            case .authorizedWhenInUse:
                print("[DEBUG]: Location only in-use")
            @unknown default:
                break
        }
    }
    // updates the location with last known 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
}
