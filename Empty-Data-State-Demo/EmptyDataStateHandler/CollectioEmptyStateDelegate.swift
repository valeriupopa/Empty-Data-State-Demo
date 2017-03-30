//
//  CollectioEmptyStateDelegate.swift
//  TheMovie
//
//  Created by Valeriu POPA on 3/2/17.
//  Copyright © 2017 Valeriu POPA. All rights reserved.
//

import UIKit

@objc
protocol CollectionEmptyStateDelegate {
    @objc optional func didTapAction(forEmptyState scrollView: UIScrollView)
}
