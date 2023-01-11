//
//  Challenge+iSpy.swift
//  iSpyChallenge
//
//

import Foundation

extension Challenge {
    init(apiChallenge: APIChallenge) {
        self.init(id: apiChallenge.id,
                  hint: apiChallenge.hint,
                  latitude: apiChallenge.location.latitude,
                  longitude: apiChallenge.location.longitude,
                  photoImageName: apiChallenge.photo,
                  creatorID: apiChallenge.user,
                  matches: apiChallenge.matches.map { Match(apiMatch: $0) },
                  ratings: apiChallenge.ratings.map { Rating(apiRating: $0) })
    }
    
    func toAPIChallenge() -> APIChallenge {
        APIChallenge(id: self.id,
                     photo: self.photoImageName,
                     hint: self.hint,
                     user: self.creatorID,
                     location: APILocation(latitude: self.latitude,
                                           longitude: self.longitude),
                     matches: self.matches.map { $0.toAPIMatch() },
                     ratings: self.ratings.map { $0.toAPIRating() } )
    }
}
