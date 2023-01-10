//
//  NearMeTableViewCell.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import UIKit

class NearMeTableViewCell: UITableViewCell {
    static let reuseIdentifier = "NearMeTableViewCell"
    
    @IBOutlet weak var placard: UIView!         // To "fake" spacing and get rounded corners
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var creatorLabel: UILabel!

    func setupCell(viewModel: NearMeCellViewModel) {
        placard.layer.cornerRadius = 12
        
        hintTextView.textContainer.lineFragmentPadding = 0
        hintTextView.textContainer.lineBreakMode = .byWordWrapping
        hintTextView.textContainerInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        winsLabel.text = viewModel.numWinsString
        ratingsLabel.text = viewModel.averageRatingString
        distanceLabel.text = viewModel.distanceString
        hintTextView.text = viewModel.hintString
        creatorLabel.text = viewModel.challengeCreatorString
    }
}
