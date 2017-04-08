//
//  BusinessTableViewCell.swift
//  Yelp
//
//  Created by Nana on 4/8/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var reviews: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!

    var businessInfo: Business! {
        didSet {
            if (businessInfo != nil) {

                name.text = businessInfo.name ?? ""
                distance.text = businessInfo.distance ?? ""
                cost.text = ""
                address.text = businessInfo.address ?? ""
                categories.text = businessInfo.categories ?? ""
                reviews.text = businessInfo.reviewCount != nil ? "\(businessInfo.reviewCount!) Reviews" : ""

                if let imageUrl = businessInfo.imageURL {
                    businessImageView.setImageWith(imageUrl)
                }

                if let ratingImageUrl = businessInfo.ratingImageURL {
                    ratingsImageView.setImageWith(ratingImageUrl)
                }

            } else {

                name.text = nil
                distance.text = nil
                cost.text = nil
                address.text = nil
                categories.text = nil
                reviews.text = nil
                businessImageView.image = nil
                ratingsImageView.image = nil
            }
        }
    }

}
