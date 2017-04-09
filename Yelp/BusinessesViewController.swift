//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Nana on 4/23/15.
//  Copyright (c) 2015 Nana. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController, FilterViewDelegate {

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

        // Load search results based on current location and saved filters
        let filter = AppGlobals.shared.filter

        performSearch(text: searchText, dealsOnly: filter.dealsOnly, radius: filter.radius, sort: filter.sort, categories: filter.categories)
    }

    // MARK: Data Manager

    func performSearch(text: String) {

        let filter = AppGlobals.shared.filter
        performSearch(text: text, dealsOnly: filter.dealsOnly, radius: filter.radius, sort: filter.sort, categories: filter.categories)
    }

    func performSearch(text: String, dealsOnly: Bool?, radius: Float?, sort: YelpSortMode?, categories: Array<String>?) {

        let hudView = MBProgressHUD.showAdded(to: self.view, animated: true)
        hudView.label.text = "Loading Results..."

        Business.searchWithTerm(term: text, sort: sort, categories: categories, deals: dealsOnly, radius: radius) {[weak weakSelf = self] (businesses: [Business]!, error: Error!) in

            hudView.hide(animated: true)

            print("Error: \(String(describing: error))")
            print("Adv Search Results: \(String(describing: businesses))")

            weakSelf?.businesses = [Business]()

            if businesses.count > 0 {
                weakSelf?.searchResultsEmpty = false
            } else {
                weakSelf?.searchResultsEmpty = true
            }

            weakSelf?.businesses = businesses
        }
    }

    // MARK: - FilterViewDelegate

    func filterViewDismissed(filter: Filter, refreshResults: Bool) {
        if refreshResults {
            performSearch(text: searchText, dealsOnly: filter.dealsOnly, radius: filter.radius, sort: filter.sort, categories: filter.categories)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFilterView" {

            let destination = segue.destination as! FilterViewController
            destination.delegate = self
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

            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false, block: {[weak weakSelf = self] (timer) in

                weakSelf?.searchText = newText
                weakSelf?.performSearch(text: newText)
            })
        }
    }
}
