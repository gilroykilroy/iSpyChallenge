//
//  NearMeDetailViewController.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import UIKit

class NearMeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    private var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageName = imageName {
            var theImage = UIImage(named: imageName)
            
            if theImage == nil {
                // Could be stored in the documents directory
                let fullFileURL = getDocumentsDirectory().appendingPathComponent(imageName)
                let data = try? Data(contentsOf: fullFileURL)
                if data != nil {
                    theImage = UIImage(data: data!)
                }
            }
            
            imageView.image = theImage
        }
    }
    
    func setImageName(_ imageName: String) {
        self.imageName = imageName
    }
}
