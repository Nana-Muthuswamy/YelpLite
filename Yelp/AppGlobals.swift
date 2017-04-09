//
//  AppGlobals.swift
//  Yelp
//
//  Created by Nana on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import Foundation

class AppGlobals {

    // Shared object
    static let shared = AppGlobals()

    var filter: Filter {
        didSet {
            UserDefaults.standard.set(filter.dictionaryRepresentation(), forKey: "savedFilter")
            UserDefaults.standard.synchronize()
        }
    }

    // Enforcing singleton
    private init() {

        if let savedFilter = UserDefaults.standard.dictionary(forKey: "savedFilter") {
            filter = Filter(dictionary: savedFilter)
        } else {
            filter = Filter(dealsOnly: false, radius: 0, sort: .bestMatched, categories: nil)
        }
    }
}
