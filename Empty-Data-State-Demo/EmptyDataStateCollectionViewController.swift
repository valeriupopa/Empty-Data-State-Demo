//
//  EmptyDataStateCollectionViewController.swift
//  Empty-Data-State-Demo
//
//  Created by Valeriu POPA on 3/9/17.
//  Copyright © 2017 Pentalog. All rights reserved.
//

import UIKit

class EmptyDataStateCollectionViewController: UIViewController {
    
    // MARK: - Properties
    fileprivate var dataSource: Int = Int(arc4random_uniform(100))
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Collection View"
        self.collectionView.emptyStateDataSource = self
        
        let cellName = String(describing: EmptyUICollectionViewCell.self)
        
        self.collectionView.register(EmptyUICollectionViewCell.self, forCellWithReuseIdentifier: cellName)
        self.collectionView.register(UINib(nibName: cellName, bundle: Bundle.main), forCellWithReuseIdentifier: cellName)
        
        let resetBarButton = UIBarButtonItem(title: "reset", style: .plain, target: self, action: #selector(resetDataSource))
        
        self.navigationItem.setRightBarButton(resetBarButton, animated: true)
    }
    
    // MARK: - Methods
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
        
        self.collectionView.reloadData()
    }
}

extension EmptyDataStateCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EmptyUICollectionViewCell.self), for: indexPath)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.yellow
        } else {
            cell.backgroundColor = UIColor.red
        }
        
        return cell
    }
}

extension EmptyDataStateCollectionViewController: CollectionEmptyStateDataSource {
    func view(forEmptyState scrollView: UIScrollView) -> UIView {
        return Bundle.main.loadNibNamed("EmptyDataStateView", owner: nil, options: nil)?.first as! UIView
    }
}
