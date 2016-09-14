//
//  LibrarySplitViewController.swift
//  Kiwix
//
//  Created by Chris Li on 8/17/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class LibrarySplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredDisplayMode = .AllVisible
        minimumPrimaryColumnWidth = 320.0
        delegate = self
        
        configureDismissButton()
    }
    
    func configureDismissButton() {
        guard let master = viewControllers.first as? UINavigationController else {return}
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Cross"), style: .Plain, target: self, action: #selector(LibrarySplitViewController.dismiss))
        master.topViewController?.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}