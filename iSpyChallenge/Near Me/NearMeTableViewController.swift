//
//  NearMeTableViewController.swift
//  iSpyChallenge
//
//  Created by Jeff Shulman on 1/10/23.
//

import Combine
import UIKit

class NearMeTableViewController: UITableViewController {

    private var viewModel = NearMeViewModel()
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        observeChanges()
    }
    
    private func observeChanges() {
        viewModel.$cellModels.sink { [weak self] _ in
            self?.tableView.reloadData()
        }
        .store(in: &subscriptions)
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NearMeTableViewCell.reuseIdentifier, for: indexPath) as! NearMeTableViewCell
        
        cell.setupCell(viewModel: viewModel.cellModels[indexPath.row])
        
        return cell
    }
}
