//
//  MockImageService.swift
//  iSpyChallengeTests
//
//  Created by Jeff Shulman on 1/10/23.
//

@testable import iSpyChallenge
import Foundation
import UIKit.UIImage

class MockImageService: ImageServiceProtocol {
    var mockLoadImageFails = false
    var mockSaveImageFails = false
    
    func saveImage(_ image: UIImage) throws -> String {
        if mockSaveImageFails {
            throw "Some saving image error"
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        return fileName
    }
    
    func loadImage(ofName name: String) -> UIImage? {
        if mockSaveImageFails {
            return nil
        }
        
        return UIImage(named: "galvanize.jpg")
    }
}
