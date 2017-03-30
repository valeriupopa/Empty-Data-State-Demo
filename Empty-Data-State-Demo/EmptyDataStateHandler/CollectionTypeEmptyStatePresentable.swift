//
//  CollectionTypeEmptyStatePresentable.swift
//  TheMovie
//
//  Created by Valeriu POPA on 3/2/17.
//  Copyright © 2017 Valeriu POPA. All rights reserved.
//

import Foundation

protocol CollectionTypeEmptyStatePresentable {
    
    // MARK: - Properties
    var emptyStateDataSource: CollectionEmptyStateDataSource? { get set }
    var emptyStateDelegate: CollectionEmptyStateDelegate? { get set }
    var available: Bool { get }
    var numberOfItems: Int { get }
    
    // MARK: - Methods
    func swizzleIfPossible(selector: Selector)
    func invalidate()
}
