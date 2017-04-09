//
//  UIView+Extension.swift
//  Yelp
//
//  Created by Nana on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

extension UIView {

    var firstLabel: UILabel? {
        return self.viewWithTag(1) as? UILabel
    }
}
