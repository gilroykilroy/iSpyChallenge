//
//  Rating+iSpy.swift
//  iSpyChallenge
//
//

import Foundation

extension Rating {
    init(apiRating: APIRating) {
        self.init(id: apiRating.id,
                  stars: apiRating.value,
                  creatorID: apiRating.user)
    }
    
    func toAPIRating() -> APIRating {
        APIRating(id: self.id,
                  value: self.stars,
                  user: self.creatorID)
    }
}
