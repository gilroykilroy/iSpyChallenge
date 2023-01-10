//
//  MockAPIService.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//
// A synchronous version of the APIService

@testable import iSpyChallenge
import Foundation

class MockAPIService: APIServiceProtocol {
    func getUsers(completion: @escaping ([APIUser]) -> Void) {
        let users: [APIUser]? = object(fromJSONNamed: "users")
        completion(users ?? [])
    }
    
    func getChallenges(completion: @escaping ([APIChallenge]) -> Void) {
        let challenges: [APIChallenge]? = object(fromJSONNamed: "challenges")
        completion(challenges ?? [])
    }
    
    func postChallenge(forUser userId: String,
                       hint: String,
                       location: APILocation,
                       photoImageName: String,
                       completion: @escaping (Result<APIChallenge, Error>) -> Void) {
        // Mock a successful response from the API
        let apiChallenge = APIChallenge(id: UUID().uuidString,
                                        photo: photoImageName,
                                        hint: hint,
                                        user: userId,
                                        location: location,
                                        matches: [],
                                        ratings: [])
        
        completion(.success(apiChallenge))
    }
    
    func postMatch(fromUser userId: String,
                   forChallenge challengeId: String,
                   location: APILocation,
                   photo: String,
                   completion: @escaping (Result<APIMatch, Error>) -> Void) {
        // Mock a successful response from the API
        let apiMatch = APIMatch(id: UUID().uuidString,
                                location: location,
                                photo: photo,
                                verified: false,
                                user: userId)
        
        completion(.success(apiMatch))
    }
    
    private func object<T: Decodable>(fromJSONNamed jsonName: String) -> T? {
        guard let url = Bundle.main.url(forResource: jsonName, withExtension: "json") else {
            print("APIService error: Could not find resource for JSON named '\(jsonName)'")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("APIService error: \(error)")
            return nil
        }
    }
}
