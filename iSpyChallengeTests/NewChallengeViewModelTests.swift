//
//  NewChallengeViewModelTests.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//

import Combine
import Factory
import Nimble
import XCTest
@testable import iSpyChallenge

final class NewChallengeViewModelTests: XCTestCase {

    var nearMeViewModel: NearMeViewModel!
    var newChallengeViewModel: NewChallengeViewModel!
    
    var mockImageService: MockImageService!
    var mockLocationService: MockLocationService!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Container.Registrations.push()
        
        mockImageService = MockImageService()
        mockLocationService = MockLocationService()

        Container.dataController.register { DataController(apiService: MockAPIService()) }
        Container.imageService.register { self.mockImageService! }
        Container.locationService.register { self.mockLocationService! }

        newChallengeViewModel = NewChallengeViewModel()
        nearMeViewModel = NearMeViewModel()
   }
    
    override func tearDownWithError() throws {
        subscriptions.removeAll()
        try super.tearDownWithError()
        Container.Registrations.pop()
    }
    
    func testMemoryLeaks() {
        weak var weakNewChallengeViewModel = newChallengeViewModel
        expect(weakNewChallengeViewModel).toNot(beNil())
        
        newChallengeViewModel = nil
        
        expect(weakNewChallengeViewModel).to(beNil())
    }

    func testAddNewChallenge() {
        var cellViewModels: [NearMeCellViewModel]?
        
        nearMeViewModel.$cellModels.sink { cellModels in
            cellViewModels = cellModels
        }
        .store(in: &subscriptions)
        
        expect(cellViewModels).toEventuallyNot(beEmpty())
        let count = cellViewModels!.count
        cellViewModels = nil
        
        var completionResult: Bool?
        
        let image = UIImage(named: "galvanize.jpg")!
        newChallengeViewModel.addNewChallenge(image: image, hint: "A hint") { success in
            completionResult = success
        }
        
        expect(completionResult).toEventually(beTrue())
        expect(cellViewModels).toEventuallyNot(beEmpty())
        expect(cellViewModels!.count) == count + 1
        expect(cellViewModels![0].hintString) == "A hint"
    }
    
    func testAddNewChallengeSaveError() {
        mockImageService.mockSaveImageFails = true
        
        var completionResult: Bool?
        
        let image = UIImage(named: "galvanize.jpg")!
        newChallengeViewModel.addNewChallenge(image: image, hint: "A hint") { success in
            completionResult = success
        }
        
        expect(completionResult).toEventually(beFalse())
    }
}
