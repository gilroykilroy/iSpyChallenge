//
//  Utils.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
