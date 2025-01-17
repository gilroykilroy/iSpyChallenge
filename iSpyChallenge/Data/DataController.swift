//
//  DataController.swift
//  iSpyChallenge
//
//  For expediency of this exersize we will persis the challenges list in UserDefaults under the "challanges" key. It will only
//  be saved if the user actually adds a new challenge.

import Factory
import Foundation

extension NSNotification.Name {
    /// Indicates that a `DataController` instance updated its data.
    /// This notification is only fired on the main thread.
    static let dataControllerDidUpdate = NSNotification.Name(rawValue: "dataControllerDidUpdate")
}

class DataController {
    private let apiService: APIServiceProtocol
    
    private(set) var allUsers: [User] = [] {
        didSet {
            NotificationCenter.default.post(name: .dataControllerDidUpdate, object: self)
        }
    }
    
    // A hack for this project -- assume that the first user is the current user
    private let currentUserIndex = 0
    
    private let defaults = UserDefaults.standard
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    var currentUser: User? {
        allUsers[safe: currentUserIndex]
    }
    
    func loadAllData() {
        var apiUsers: [APIUser] = []
        var apiChallenges: [APIChallenge] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        apiService.getUsers {
            apiUsers = $0
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        // Try user defaults first
        if let savedChallenges = defaults.object(forKey: "challenges") as? Data {
            let decoder = JSONDecoder()
            if let theSavedChallenges = try? decoder.decode([APIChallenge].self, from: savedChallenges) {
                apiChallenges = theSavedChallenges
                dispatchGroup.leave()
            }
        }
        
        if apiChallenges.isEmpty {
            // Read them from json
            apiService.getChallenges {
                apiChallenges = $0
                dispatchGroup.leave()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            dispatchGroup.wait()
            DispatchQueue.main.async {
                self.allUsers = apiUsers.map { User(apiUser: $0, apiChallenges: apiChallenges) }
            }
        }
    }
    
    func createChallengeForCurrentUser(hint: String,
                                       latitude: Double,
                                       longitude: Double,
                                       photoImageName: String,
                                       completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = currentUser else {
            completion(false)
            return
        }
        
        apiService.postChallenge(forUser: currentUser.id,
                                 hint: hint,
                                 location: APILocation(latitude: latitude, longitude: longitude),
                                 photoImageName: photoImageName) { result in
            switch result {
            case .success(let apiChallenge):
                self.appendChallenge(Challenge(apiChallenge: apiChallenge), forUser: currentUser.id)
                
                // Store all the challenges in user defaults
                let apiChallenges = self.allChallenges.map { $0.toAPIChallenge() }
                let encoder = JSONEncoder()
                if let encodedChallenges = try? encoder.encode(apiChallenges) {
                    self.defaults.set(encodedChallenges, forKey: "challenges")
                }
                
                completion(true)
                
            case .failure:
                completion(false)
            }
        }
    }
    
    func submitMatch(forChallenge challengeId: String,
                     latitude: Double,
                     longitude: Double,
                     photoImageName: String,
                     completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = currentUser,
              !currentUser.challenges.map({ $0.id }).contains(challengeId) else {
            completion(false)
            return
        }
        
        apiService.postMatch(fromUser: currentUser.id,
                             forChallenge: challengeId,
                             location: APILocation(latitude: latitude, longitude: longitude),
                             photo: photoImageName) { result in
            switch result {
            case .success(let apiMatch):
                self.appendMatch(Match(apiMatch: apiMatch), forChallenge: challengeId)
                completion(true)
                
            case .failure:
                completion(false)
            }
        }
    }
}

// MARK: Helpers

private extension DataController {
    func appendChallenge(_ challenge: Challenge, forUser userId: String) {
        guard let userIndex = allUsers.firstIndex(where: { $0.id == userId }) else {
            return
        }
        
        DispatchQueue.main.async {
            self.allUsers[userIndex]
                .challenges
                .append(challenge)
        }
    }
    
    func appendMatch(_ match: Match, forChallenge challengeId: String) {
        guard let indexOfUserWhoOwnsChallenge = indexOfUser(whoOwnsChallenge: challengeId),
              let indexOfChallenge = indexOfChallenge(challengeId, forUserIndex: indexOfUserWhoOwnsChallenge) else {
                  return
              }
        
        DispatchQueue.main.async {
            self.allUsers[indexOfUserWhoOwnsChallenge]
                .challenges[indexOfChallenge]
                .matches.append(match)
        }
    }
    
    func indexOfUser(whoOwnsChallenge challengeId: String) -> Int? {
        allUsers.firstIndex(where: { user in
            user.challenges.map { $0.id }.contains(challengeId)
        })
    }
    
    func indexOfChallenge(_ challengeId: String, forUserIndex userIndex: Int) -> Int? {
        allUsers[safe: userIndex]?
            .challenges
            .firstIndex(where: { $0.id == challengeId })
    }
}

// We really only need one copy of all the data
extension Container {
    static let dataController = Factory(scope: .singleton) { DataController(apiService: APIService()) }
}
