//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Nana on 4/23/15.
//  Copyright (c) 2015 Nana. All rights reserved.
//

import UIKit
import MBProgressHUD

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
    fileprivate var searchText = ""
    fileprivate var searchResultsEmpty = false
    
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
        // TDO: Extract the last saved filter object and apply to the search
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

        let hudView = MBProgressHUD.showAdded(to: self.view, animated: true)
        hudView.label.text = "Loading Results..."

        Business.searchWithTerm(term: text) {[weak weakSelf = self] (businesses: [Business]?, error: Error?) in

            hudView.hide(animated: true)

            print("Error: \(String(describing: error))")
            print("Simple Search Results: \(String(describing: businesses))")

            weakSelf?.businesses = [Business]()

            if businesses != nil {
                weakSelf?.searchResultsEmpty = false
            } else {
                weakSelf?.searchResultsEmpty = true
            }

            weakSelf?.businesses = businesses
        }
    }

    func performSearch(text: String, dealsOnly: Bool, radius: Float, sort: YelpSortMode, categories: Array<String>?) {

        let hudView = MBProgressHUD.showAdded(to: self.view, animated: true)
        hudView.label.text = "Loading Results..."

        Business.searchWithTerm(term: text, sort: sort, categories: categories, deals: dealsOnly) {[weak weakSelf = self] (businesses: [Business]!, error: Error!) in

            hudView.hide(animated: true)

            print("Error: \(String(describing: error))")
            print("Adv Search Results: \(String(describing: businesses))")

            weakSelf?.businesses = [Business]()

            if businesses != nil {
                weakSelf?.searchResultsEmpty = false
            } else {
                weakSelf?.searchResultsEmpty = true
            }

            weakSelf?.businesses = businesses
        }
    }

    // MARK: Navigation

    @IBAction func applyFilterToSearchResults(unwindSegue: UIStoryboardSegue) {

        if let source = unwindSegue.source as? FilterViewController, let filter = source.filter {

            // Extract the current filter object and save to UserDefaults
            UserDefaults.standard.set(filter.dictionaryRepresentation(), forKey: "savedFilter")
            UserDefaults.standard.synchronize()

            // Apply Filter to search results
            performSearch(text: searchText, dealsOnly: filter.dealsOnly, radius: filter.radius, sort: filter.sort, categories: filter.categories)
        }
    }
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsEmpty ? 1 : businesses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if searchResultsEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "NoResultsCell")!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessTableViewCell") as! BusinessTableViewCell

            cell.businessInfo = nil

            let business = businesses[indexPath.row]
            cell.businessInfo = business

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BusinessesViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        if let newText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), newText != searchText {

            if searchTimer != nil {
                searchTimer.invalidate()
            }

            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {[weak weakSelf = self] (timer) in
                weakSelf?.performSearch(text: newText)
            })
        }
    }
}
