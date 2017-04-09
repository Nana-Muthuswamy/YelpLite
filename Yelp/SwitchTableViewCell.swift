//
//  SwitchTableViewCell.swift
//  Yelp
//
//  Created by Nana on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

protocol FilterSwitchDelegate: class {
    func switchValueDidChange(sender: SwitchTableViewCell)
}

class SwitchTableViewCell: UITableViewCell {

    weak var delegate: FilterSwitchDelegate?

    @IBOutlet weak var switchControl: UISwitch!

    @IBAction func valueChangedFor(_ sender: UISwitch) {
        delegate?.switchValueDidChange(sender: self)
    }
}
