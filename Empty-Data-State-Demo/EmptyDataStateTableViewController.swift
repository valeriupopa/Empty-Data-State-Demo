//
//  EmptyDataStateTableViewController.swift
//  Empty-Data-State-Demo
//
//  Created by Valeriu POPA on 3/9/17.
//  Copyright © 2017 Pentalog. All rights reserved.
//

import UIKit
import Foundation

class EmptyDataStateTableViewController: UIViewController {
    
    fileprivate var dataSource: Int = 26
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.autoresizesSubviews = false
        self.title = "Table View"
        
        let resetBarButton = UIBarButtonItem(title: "reset", style: .plain, target: self, action: #selector(resetDataSource))
    
        self.navigationItem.setRightBarButton(resetBarButton, animated: true)
        
        self.tableView.emptyStateDataSource = self
    }
    
    // MARK: - Private methods
    @objc private func resetDataSource(){
        guard let resetButton = self.navigationItem.rightBarButtonItem else { return }
        
        guard let resetButtonTitle = resetButton.title else { return }
        
        switch resetButtonTitle {
        case "reset":
            resetButton.title = "generate"
            dataSource = 0
        default:
            resetButton.title = "reset"
            dataSource = Int(arc4random_uniform(100))
        }
        
        self.tableView.reloadData()
    }
}

extension EmptyDataStateTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "section: \(indexPath.section) row: \(indexPath.row)"
        
        return cell
    }
}

extension EmptyDataStateTableViewController: CollectionEmptyStateDataSource {
    
    internal func view(forEmptyState scrollView: UIScrollView) -> UIView {
        return Bundle.main.loadNibNamed("EmptyDataStateView", owner: nil, options: nil)?.first as! UIView
    }
}


class EmptyDataStateTableViewModel {
    
}
