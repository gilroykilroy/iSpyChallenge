//
//  NearMeDetailViewController.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import Factory
import UIKit

class NearMeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @Injected(Container.imageService) private var imageService
    private var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageName = imageName {
            imageView.image = imageService.loadImage(ofName: imageName)
        }
    }
    
    func setImageName(_ imageName: String) {
        self.imageName = imageName
    }
}
