//
//  iSpyTabBarController.swift
//  iSpyChallenge
//

import UIKit
import CoreData
import Factory

class iSpyTabBarController: UITabBarController {
    @Injected(Container.dataController) private var dataController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataBrowserViewController?.dataController = dataController
        dataController.loadAllData()
    }
}

private extension iSpyTabBarController {
    var dataBrowserViewController: DataBrowserTableViewController? {
        viewControllers?
            .compactMap { ($0 as? UINavigationController)?.viewControllers.first as? DataBrowserTableViewController }
            .first
    }
}
