//
//  LocationService.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/9/23.
//
//  Protocol and service to provide the users current location.
//  If the user doesn't give us permission we will use the challenge default location

import Combine
import CoreLocation
import Factory
import OSLog

protocol LocationServiceProtocol {
    var currentLocation: CLLocationCoordinate2D { get }
    var currentLocationPublisher: Published<CLLocationCoordinate2D>.Publisher { get }
}

class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    static let defaultLatitude = 37.7904462
    static let defaultLongitude = -122.4011537
    
    @Published private(set) var currentLocation = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)
    var currentLocationPublisher: Published<CLLocationCoordinate2D>.Publisher { $currentLocation }
    
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        
        locationManager.delegate = self
        
        if locationManager.authorizationStatus != CLAuthorizationStatus.authorizedWhenInUse {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            // Good to go so start monitoring significant changes
            manager.startMonitoringSignificantLocationChanges()
            Logger().debug("Monitoring location changes")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Last location in locations is most current
        let currentCLLocation = locations.last!
        currentLocation = currentCLLocation.coordinate
        
        Logger().debug("Current location \(currentCLLocation)")
    }
}

// Register us as the default locationService
extension Container {
    static let locationService = Factory(scope: .singleton) { LocationService() as LocationServiceProtocol }
}
