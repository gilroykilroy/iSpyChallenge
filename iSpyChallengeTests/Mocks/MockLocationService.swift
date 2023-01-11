//
//  MockLocationService.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//

@testable import iSpyChallenge
import CoreLocation

class MockLocationService: NSObject, LocationServiceProtocol, ObservableObject {
    static let defaultLatitude = 37.7904462
    static let defaultLongitude = -122.4011537
    
    @Published private(set) var currentLocation = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)
    var currentLocationPublisher: Published<CLLocationCoordinate2D>.Publisher { $currentLocation }
    
    // Allow direct setting of a location
    func setCurrentLocation(_ currentLocation: CLLocationCoordinate2D) {
        self.currentLocation = currentLocation
    }
}
