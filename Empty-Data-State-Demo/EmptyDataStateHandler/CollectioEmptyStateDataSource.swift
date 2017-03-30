//
//  CollectioEmptyStateDataSource.swift
//  TheMovie
//
//  Created by Valeriu POPA on 3/2/17.
//  Copyright © 2017 Valeriu POPA. All rights reserved.
//

import UIKit

@objc
protocol CollectionEmptyStateDataSource {
    func view(forEmptyState scrollView: UIScrollView) -> UIView
    @objc optional func title(forEmptyState scrollView: UIScrollView) -> NSAttributedString
}
