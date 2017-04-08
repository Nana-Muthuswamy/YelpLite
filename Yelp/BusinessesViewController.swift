//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Nana on 4/23/15.
//  Copyright (c) 2015 Nana. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    fileprivate var businesses: [Business]! = [Business]() {
        didSet {
            DispatchQueue.main.async {[weak weakSelf = self] in
                weakSelf?.tableView.reloadData()
            }
        }
    }

    fileprivate var searchController: UISearchController!
    fileprivate var searchTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Table View traits
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension

        // Setup Search Controller and Search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self

        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        searchController.searchBar.placeholder = "Restaurants"
        searchController.searchBar.sizeToFit()

        self.navigationItem.titleView = searchController.searchBar

        self.definesPresentationContext = true

        // Search and load nearby results for the current location
        fetchNearbyRestaurants()
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }

    // MARK: Data Manager

    func fetchNearbyRestaurants() {
        performSearch(text: "")
    }

    func performSearch(text: String) {

        Business.searchWithTerm(term: text) {[weak weakSelf = self] (businesses: [Business]?, error: Error?) in
            print("Simple Search Results: \(String(describing: businesses))")
            weakSelf?.businesses = businesses
        }

        /*
         Business.searchWithTerm(term: "Restaurants", sort: .distance, categories: ["asianfusion", "burgers"], deals: true) {[weak weakSelf = self] (businesses: [Business]!, error: Error!) in

         print("Adv Search Results: \(businesses)")
         weakSelf?.businesses = businesses
         }
         */
    }
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessTableViewCell") as! BusinessTableViewCell

        cell.businessInfo = nil

        let business = businesses[indexPath.row]
        cell.businessInfo = business

        return cell
    }
}

extension BusinessesViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        if let searchText = searchController.searchBar.text, searchText.characters.count > 0 {

            if searchTimer != nil {
                searchTimer.invalidate()
            }

            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {[weak weakSelf = self] (timer) in
                weakSelf?.performSearch(text: searchText)
            })
        }
    }
}
