//
//  NewChallengeViewController.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import AVFoundation
import OSLog
import PhotosUI
import UIKit

class NewChallengeViewController: UIViewController {
    @IBAction func takePhotoTapped(_ sender: UIButton) {
        showImagePickerForCamera()
    }
    
    @IBAction func chooseImageTapped(_ sender: UIButton) {
        showImagePickerForPhotos()
    }
    
    private var chosenImage: UIImage?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "CreateChallenge" else {
            Logger().error("Not a seque we're looking for \(String(describing: segue.identifier))")
            return
        }
        
        guard let createChallengeViewController = segue.destination as? CreateChallengeViewController else {
            preconditionFailure("Expecting a CreateChallengeViewController here")
        }
        
        guard let chosenImage = chosenImage else {
            preconditionFailure("Expecting a chosen image")
        }

        createChallengeViewController.setChosenImage(chosenImage)
    }

    private func showImagePickerForCamera() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayAlert(title: "No Camera", message: "This device has no camera")
            return
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .denied, .restricted:
            // Put up an alert telling user to authorize this app
            let settings = UIAlertAction(title: "Settings", style: .default) { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            displayAlert(title: "No Permission", message: "You have not given us permission to use your camera", action: settings)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self?.showCamera()
                    }
                }
            }
            
        case .authorized:
            showCamera()
            
        @unknown default:
            Logger().error("Unhandled authorization status \(authStatus.rawValue)")
        }
    }
    
    private func showImagePickerForPhotos() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    private func showCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.showsCameraControls = true

        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func addChallengeWithImage(_ image: UIImage) {
        chosenImage = image
        
        performSegue(withIdentifier: "CreateChallenge", sender: self)
    }
    
    private func displayAlert(title: String, message: String, action: UIAlertAction? = nil) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        dialogMessage.addAction(ok)
        if let action = action {
            dialogMessage.addAction(action)
        }
        
        present(dialogMessage, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension NewChallengeViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true)

        addChallengeWithImage(chosenImage)
    }
}

// MARK: - UINavigationControllerDelegate

extension NewChallengeViewController: UINavigationControllerDelegate {
    
}

// MARK: - PHPickerViewControllerDelegate

extension NewChallengeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
           result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
              if let image = object as? UIImage {
                 DispatchQueue.main.async { [weak self] in
                     self?.addChallengeWithImage(image)
                 }
              }
           })
        }
    }
}
