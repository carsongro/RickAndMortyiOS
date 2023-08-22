//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Carson Gross on 5/5/23.
//

import UIKit

extension UIView {
    func addSubviews(_ view: UIView...) {
        view.forEach({
            addSubview($0)
        })
    }
}
