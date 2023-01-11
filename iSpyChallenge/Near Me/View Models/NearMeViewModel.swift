//
//  NearMeViewModel.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//
//  The view model for the NearMe list
//  Note the current dataController assumes all the data will fit into memory. We will also assume that we have enough
//  memory to fit all the NearMeCellViewModel's. It is beyond the scope of this exersize to re-implement the
//  dataController to use something like CoreData to not load it all in memory.

import Combine
import CoreLocation
import Factory
import Foundation
import OSLog

class NearMeViewModel: ObservableObject {
    static let defaultLatitude = 37.7904462
    static let defaultLongitude = -122.4011537

    @Injected(Container.dataController) private var dataController
    @Injected(Container.locationService) private var locationService

    @Published var cellModels = [NearMeCellViewModel]()
    
    private var currentLocation: CLLocationCoordinate2D
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        currentLocation = CLLocationCoordinate2D(latitude: NearMeViewModel.defaultLatitude, longitude: NearMeViewModel.defaultLongitude)
        
        addWatchers()
        
        dataController.loadAllData()
    }
    
    // Internals
    
    // We want to be informed of location and data changes
    private func addWatchers() {
        // The dataController uses notifications to notify of updates
        NotificationCenter.default.addObserver(self, selector: #selector(updatedData), name: .dataControllerDidUpdate, object: dataController)
        
        locationService.currentLocationPublisher
            .dropFirst()
            .sink { [weak self] newLocation in
                guard let self = self else { return }

                self.currentLocation = newLocation

                self.updateViewModel()
            }
            .store(in: &subscriptions)
    }
    
    // Build the sorted cellModels list
    private func updateViewModel() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let challenges = self.dataController.allChallenges
            let users = self.dataController.allUsers

            var cellModels = challenges.compactMap { challenge -> NearMeCellViewModel? in
                guard let user = users.first(where: { $0.id == challenge.creatorID }) else {
                    Logger().error("No user for challenge \(challenge.id) of id \(challenge.creatorID)")
                    return nil
                }

                return NearMeCellViewModel(challenge: challenge, user: user, currentLocation: self.currentLocation)
            }

            // Now sort by distance
            cellModels = cellModels.sorted(by: { $0.distanceInMeters < $1.distanceInMeters })

            DispatchQueue.main.async { [weak self] in
                self?.cellModels = cellModels
            }
        }
    }
    
    @objc private func updatedData() {
        updateViewModel()
    }
}
