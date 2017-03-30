//
//  CollectioEmptyStateHandler.swift
//  TheMovie
//
//  Created by Valeriu POPA on 3/1/17.
//  Copyright © 2017 Valeriu POPA. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct SwizzleInfo {
    var owner : AnyClass
    var selector : Selector
    var original : IMP
//    var swizzle  : IMP
}

fileprivate var swizzleInfoArray : [SwizzleInfo] = []

extension UIScrollView: CollectionTypeEmptyStatePresentable, UIScrollViewDelegate {
    
    // MARK: - Private Properties
    private struct AssociatedType {
        static var emptyStateDataSource: UInt8 = 0
        static var emptyStateDelegate: UInt8 = 1
        static var emptyStateView: UInt8 = 2
    }
    
    // Custom view for empty state
    
    private var emptyStateView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedType.emptyStateView) as? UIView
        }
        
        set (newEmptyStateView) {
            objc_setAssociatedObject(self, &AssociatedType.emptyStateView, newEmptyStateView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Check if datasource is set and instance is type of UITableView or UICollectionView or UIScrollView
    internal var available: Bool {
        return self.emptyStateDataSource != nil && (self.isKind(of: UITableView.self) || self.isKind(of: UICollectionView.self) || self.isKind(of: UIScrollView.self))
    }
    
    internal var numberOfItems: Int {
        var items: Int = 0
        
        if let tableView = self as? UITableView {
            guard let dataSource = tableView.dataSource else {
                return items
            }
            
            if dataSource.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))) {
               
                let numberOfSections: Int = dataSource.numberOfSections!(in: tableView)
                if dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
                    for section in 0..<numberOfSections {
                        items += dataSource.tableView(tableView, numberOfRowsInSection: section)
                    }
                }
            }
        } else if let collectionView = self as? UICollectionView {
            guard let dataSource = collectionView.dataSource else {
                return items
            }
            
            if dataSource.responds(to: #selector(UICollectionViewDataSource.numberOfSections(in:))) {
                let numberOfSections: Int = dataSource.numberOfSections!(in: collectionView)
                
                if dataSource.responds(to: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) {
                    for section in 0..<numberOfSections {
                        items += dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                    }
                }
            }
        }
        
        return items
    }
    
    // MARK: - Public Properties
    var emptyStateDataSource: CollectionEmptyStateDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedType.emptyStateDataSource) as? CollectionEmptyStateDataSource
        }
        set (newDataSource) {
            
            if let value = newDataSource {
                
                if self.available {
                    return
                }
                
                delegate = self
                
                objc_setAssociatedObject(self, &AssociatedType.emptyStateDataSource, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                
                // get the reference of the custom view to be shown in case of empty state.
                self.emptyStateView = value.view(forEmptyState: self)
                
                // swizzle methods for UITableView or UICollectionView
                if self is UITableView {
                    self.swizzleIfPossible(selector: #selector(UITableView.reloadData))
//                    self.swizzleIfPossible(selector: #selector(UITableView.endUpdates))
                }
                
                if self is UICollectionView { // same as self.isKind(of: UICollectionView.self)
                    self.swizzleIfPossible(selector: #selector(UICollectionView.reloadData))
                }
            } else {
                self.invalidate()
            }
        }
    }
    
    var emptyStateDelegate: CollectionEmptyStateDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedType.emptyStateDelegate) as? CollectionEmptyStateDelegate
        }
        set (newDelegate) {
            if let value = newDelegate {
                objc_setAssociatedObject(self, &AssociatedType.emptyStateDelegate, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: - Public Methods
      
    // MARK: - Private Methods
    internal func swizzleIfPossible(selector: Selector) {
        
        if !self.responds(to: selector) {
            return
        }
        
        // swizzle only once for each instance.
        for item in swizzleInfoArray {
            if item.selector == selector && item.owner == type(of: self) {
                return
            }
        }
        
        // store information about swizzle selector
        guard let originalImplementation = method_getImplementation(class_getInstanceMethod(type(of: self), selector)) else {
            return
        }
        
        swizzleInfoArray.append(SwizzleInfo(owner: type(of: self), selector: selector, original: originalImplementation))
        
        switch selector {
        case #selector(UITableView.reloadData), #selector(UICollectionView.reloadData):
            self.swizzleMethods(originalSelector: selector, withSelector: #selector(UIScrollView.emptyStateReloadData))
         default:
            self.swizzleMethods(originalSelector: selector, withSelector: #selector(UIScrollView.emptyStateEndUpdates))
        }
    }
    
    internal func invalidate() {
        self.isScrollEnabled = true
        
        if let emptyStateCustomView = self.emptyStateView {
            emptyStateCustomView.removeFromSuperview()
        }
    }
    
    internal func emptyStateReloadData() {
        
        if !self.available || self.numberOfItems != 0 {
            // check for original implementation and call it
            for item in swizzleInfoArray {
                
                if item.owner == type(of: self) {
                    
                    self.invalidate()
                    
                    typealias OIF = @convention(c) (AnyObject, Selector) -> Void
                    let curriedImplementation = unsafeBitCast(item.original, to: OIF.self)
                    
                    if self is UITableView {
                        curriedImplementation(self, #selector(UITableView.reloadData))
                    }
                    
                    if self is UICollectionView {
                        curriedImplementation(self, #selector(UICollectionView.reloadData))
                    }
                }
            }
            
            return
        }
        
        guard let targetView = self.emptyStateView else {
            return
        }
        
        // set constraints to the target view
        targetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetView.frame.origin = self.bounds.origin
        
        self.isScrollEnabled = false
        
        if self is UITableView, self is UICollectionView {
            self.insertSubview(targetView, at: 0)
        } else {
            self.addSubview(targetView)
        }
    }
    
    func emptyStateEndUpdates() {
        
        if self.numberOfItems != 0 {
            // check for original implementation and call it
            for item in swizzleInfoArray {
                
                if item.owner == type(of: self) {
                    
                    typealias OIF = @convention(c) (AnyObject, Selector) -> Void
                    let curriedImplementation = unsafeBitCast(item.original, to: OIF.self)
                    
                    curriedImplementation(self, #selector(UITableView.endUpdates))
                    
                    guard let customView = self.emptyStateView else {
                        return
                    }
                    
                    customView.frame.origin = bounds.origin
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let customView = self.emptyStateView, let _ = self.emptyStateView?.superview else {
            return
        }
        
        customView.frame.origin = bounds.origin
    }
}
