//
//  NearMeDetailViewController.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import UIKit

class NearMeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
    }
}
