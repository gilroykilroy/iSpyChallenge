//
//  CreateChallegeViewController.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import OSLog
import UIKit

class CreateChallengeViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var chosenImage: UIImage?
    private var viewModel = NewChallengeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenImage != nil {
            image.image = chosenImage!
            
            let ratio = chosenImage!.size.width / chosenImage!.size.height
            let newHeight = min(image.frame.width / ratio, 256.0)
            heightConstraint.constant = newHeight
        }
    }
    
    func setChosenImage(_ chosenImage: UIImage) {
        self.chosenImage = chosenImage
    }
    
    @IBAction func submitChallenge(_ sender: UIButton) {
        guard let hintText = hintTextField.text, !hintText.isEmpty else {
            Logger().error("No hint text")
            return
        }
        
        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        
        viewModel.addNewChallenge(image: chosenImage!, hint: hintText) { success in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                
                self?.displayAlert(title: "New Challenge", message: success ? "Successfully saved" : "Could not be saved")
            }
        }
    }
    
    private func displayAlert(title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        dialogMessage.addAction(ok)
        
        present(dialogMessage, animated: true)
    }

}
