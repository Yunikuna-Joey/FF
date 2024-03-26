//
//  LocationManager.swift
//  FF
//
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    // handle changes
    private let manager = CLLocationManager()
    //
    @Published var userLocation: CLLocation?
    
    // ***optional allow for location manager to be accessed throughout the entire app
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
        
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func manageLocation(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
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
    
    func manageLocation(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.userLocation = location
    }
}
