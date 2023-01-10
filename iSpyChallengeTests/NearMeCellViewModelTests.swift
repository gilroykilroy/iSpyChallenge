//
//  NearMeCellViewModelTests.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//

import CoreLocation
import Nimble
import XCTest
@testable import iSpyChallenge

final class NearMeCellViewModelTests: XCTestCase {
    
    var dataController: DataController!
    var dataLoaded = false

    override func setUpWithError() throws {
        dataController = DataController(apiService: MockAPIService())
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataIsLoaded), name: .dataControllerDidUpdate, object: dataController)
        
        dataController.loadAllData()
        
        expect(self.dataLoaded).toEventually(beTrue())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNewNearMeCellViewModel() throws {
        // Pick the first challenge
        guard let challenge = dataController.allChallenges.first else {
            throw "No challenges"
        }
        
        guard let user = dataController.allUsers.first(where: { $0.id == challenge.creatorID }) else {
            throw "No user"
        }
        
        let newCellVM = NearMeCellViewModel(challenge: challenge,
                                            user: user,
                                            currentLocation: CLLocationCoordinate2D(latitude: 37.7904462, longitude: -122.4011537))
        
        expect(newCellVM.challenge) == challenge
        expect(newCellVM.user) == user
        expect(newCellVM.numWins) == 1
        expect(newCellVM.averageRating.rounded(toPlaces: 2)) == 3.33
        expect(newCellVM.distanceInMeters.rounded(toPlaces: 2)) == 4391.19
        expect(newCellVM.numWinsString) == "1 win"
        expect(newCellVM.averageRatingString) == "3.33 stars"
        expect(newCellVM.distanceString) == "4391.19m"
        expect(newCellVM.hintString) == challenge.hint
        expect(newCellVM.challengeCreatorString) == "By: silverwolf983"
    }
    
    @objc private func dataIsLoaded() {
        dataLoaded = true
    }
}
