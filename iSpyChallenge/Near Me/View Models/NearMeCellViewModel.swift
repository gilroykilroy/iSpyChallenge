//
//  NearMeCellViewModel.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//
//  The view model for the NearMe list cells

import CoreLocation
import Foundation

struct NearMeCellViewModel: CustomDebugStringConvertible {
    // Raw data
    var challenge: Challenge
    var user: User
    var numWins: Int
    var averageRating: Double
    var distanceInMeters: Double
    var photoImageName: String
    
    // Displayed data
    var numWinsString: String
    var averageRatingString: String
    var distanceString: String
    var hintString: String { challenge.hint }
    var challengeCreatorString: String
    
    var debugDescription: String {
        """
        NearMeCellViewModel:
            challenge: \(challenge)
            user: \(user)
            numWins: \(numWins)
            distanceInMeters: \(distanceInMeters)
            photoImageName: \(photoImageName)
            averageRating: \(averageRating)
            numWinsString: \(numWinsString)
            averageRatingString: \(averageRatingString)
            distanceString: \(distanceString)
            hintString: \(hintString)
            challengeCreatorString: \(challengeCreatorString)
        """
    }
    
    init(challenge: Challenge, user: User, currentLocation: CLLocationCoordinate2D) {
        self.challenge = challenge
        self.user = user
        
        // Calculated values
        
        // Count of verified wins
        numWins = challenge.matches.reduce(into: 0, { partialResult, match in
            partialResult += match.verified ? 1 : 0
        })
        
        let totalRating = challenge.ratings.reduce(into: 0.0) { partialResult, rating in
            partialResult += Double(rating.stars)
        }
        
        if !challenge.ratings.isEmpty {
            averageRating = totalRating / Double(challenge.ratings.count)
        } else {
            averageRating = 0.0
        }
        
        distanceInMeters = CLLocation(coordinate: currentLocation).distance(from: CLLocation(latitude: challenge.latitude, longitude: challenge.longitude))
        
        photoImageName = challenge.photoImageName

        // Displayed data
        // Assuming unlocalized english for this challenge
        
        numWinsString = String.localizedStringWithFormat(NSLocalizedString("%d wins", comment: "Number of wins"), numWins)
        averageRatingString = String(format: "%.2f stars", averageRating)
        
        // Note we are assuming we are displaying the distance in meters, vs say, miles. This could be made into a
        // user preference.
        distanceString = String(format: "%.2fm", distanceInMeters)
        
        challengeCreatorString = String(format: "By: %@", user.username)
    }
}

extension NearMeCellViewModel: Equatable {
    static func ==(lhs: NearMeCellViewModel, rhs: NearMeCellViewModel) -> Bool {
        // Assume they are the same if they have the same challenge ID
        lhs.challenge.id == rhs.challenge.id
    }
}
