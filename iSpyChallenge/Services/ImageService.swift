//
//  ImageService.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//
//  Protocol and service to save an image to disk

import Factory
import Foundation
import UIKit.UIImage

protocol ImageServiceProtocol {
    // Saves an image to disk returning the file name in the documents directory it was saved under.
    // throws any errors
    func saveImage(_ image: UIImage) throws -> String
}

class ImageService: ImageServiceProtocol {
    func saveImage(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw "Could not generate image data for saving"
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let fullFileName = getDocumentsDirectory().appendingPathComponent(fileName)
        
        try data.write(to: fullFileName)
        return fileName
    }
}

// Register us as the default image service
extension Container {
    static let imageService = Factory(scope: .singleton) { ImageService() as ImageServiceProtocol }
}
