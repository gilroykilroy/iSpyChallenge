//
//  NewChallengeViewModel.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import Factory
import Foundation
import OSLog
import UIKit.UIImage

class NewChallengeViewModel {
    @Injected(Container.dataController) private var dataController
    @Injected(Container.imageService) private var imageService
    @Injected(Container.locationService) private var locationService

    func addNewChallenge(image: UIImage, hint: String, completion: @escaping (_ success: Bool) -> Void) {
        var fileName = ""
        
        // First save the file
        do {
            fileName = try imageService.saveImage(image)
        } catch {
            Logger().error("Error writing image file: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        // Now save the new challenge
        dataController.createChallengeForCurrentUser(hint: hint,
                                                     latitude: locationService.currentLocation.latitude,
                                                     longitude: locationService.currentLocation.longitude,
                                                     photoImageName: fileName,
                                                     completion: completion)
    }
}
