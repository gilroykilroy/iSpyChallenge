//
//  NearMeViewModelTests.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//

import Combine
import CoreLocation
import Factory
import Nimble
import XCTest
@testable import iSpyChallenge

final class NearMeViewModelTests: XCTestCase {
    
    var nearMeViewModel: NearMeViewModel!
    
    var mockLocationService: MockLocationService!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Container.Registrations.push()
        
        mockLocationService = MockLocationService()
        Container.dataController.register { DataController(apiService: MockAPIService()) }
        Container.locationService.register { self.mockLocationService! }
        
        nearMeViewModel = NearMeViewModel()
    }
    
    override func tearDownWithError() throws {
        subscriptions.removeAll()
        try super.tearDownWithError()
        Container.Registrations.pop()
    }
    
    func testMemoryLeaks() {
        weak var weakNearMeViewModel = nearMeViewModel
        expect(weakNearMeViewModel).toNot(beNil())
        
        nearMeViewModel = nil
        
        expect(weakNearMeViewModel).to(beNil())
    }
    
    func testNearViewModel() throws {
        var cellViewModels: [NearMeCellViewModel]?
        
        nearMeViewModel.$cellModels.sink { cellModels in
            cellViewModels = cellModels
        }
        .store(in: &subscriptions)
        
        expect(cellViewModels).toEventuallyNot(beEmpty())
        expect(cellViewModels).to(haveCount(6))
        expect(cellViewModels![0].distanceInMeters) < cellViewModels![1].distanceInMeters
        
        // Pick the 4th challenge to be near
        let cellViewModel = cellViewModels![3]
        cellViewModels = nil
        
        mockLocationService.setCurrentLocation( CLLocationCoordinate2D(latitude: cellViewModel.challenge.latitude, longitude: cellViewModel.challenge.longitude) )
        
        expect(cellViewModels).toEventuallyNot(beEmpty())
        expect(cellViewModels).to(haveCount(6))
        expect(cellViewModels![0]).to(equal(cellViewModel))
    }
}
