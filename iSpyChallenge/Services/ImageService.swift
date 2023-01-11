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
    
    // Loads an image by name. First tries in the app and then in the documents directory.
    // Return nil if not found
    func loadImage(ofName name: String) -> UIImage?
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
    
    func loadImage(ofName name: String) -> UIImage? {
        var theImage = UIImage(named: name)

        if theImage == nil {
            // Could be stored in the documents directory
            let fullFileURL = getDocumentsDirectory().appendingPathComponent(name)
            let data = try? Data(contentsOf: fullFileURL)
            if data != nil {
                theImage = UIImage(data: data!)
            }
        }
        
        return theImage
    }
}

// Register us as the default image service
extension Container {
    static let imageService = Factory(scope: .singleton) { ImageService() as ImageServiceProtocol }
}
