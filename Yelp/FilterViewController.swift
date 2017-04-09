//
//  FilterViewController.swift
//  Yelp
//
//  Created by Nana on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import Foundation

class FilterViewController: UITableViewController, FilterSwitchDelegate {

    var filter: Filter!

    fileprivate var displayDistanceOptions = false
    fileprivate var displaySortOptions = false

    fileprivate var selectedCategoryIndices = Array<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedFilter = UserDefaults.standard.dictionary(forKey: "savedFilter") {
            filter = Filter(dictionary: savedFilter)
        } else {
            filter = Filter(dealsOnly: false, radius: 0, sort: .bestMatched, categories: nil)
        }

        // Force set to generate options for radii and sort modes
        filter.setRadius(filter.radius)
        filter.setSortType(filter.sort)

        let allCategories = Filter.categories

        filter.categories?.forEach({ (selectedElement) in

            if let index = allCategories.index(where: { (category) -> Bool in
                return selectedElement == category["code"]
            }) {
                selectedCategoryIndices.append(index)
            }
        })
    }

    // MARK: - FilterSwitchDelegate

    func switchValueDidChange(sender: SwitchTableViewCell) {

        let name = sender.firstLabel!.text!

        if let index = Filter.categories.index(where: { (element) -> Bool in
            return name == element["name"]
        }) {

            if sender.switchControl.isOn {
                filter.addCategory(at: index)
                selectedCategoryIndices.append(index)

            } else {

                filter.removeCategory(at: index)
                selectedCategoryIndices = selectedCategoryIndices.filter({ (element) -> Bool in
                    return element != index
                })
            }

        } else { // Offering a Deal Switch value changed
            filter.dealsOnly = sender.switchControl.isOn
        }
    }

    // MARK: - Action Methods

    @IBAction func dismissFilterView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
// MARK: - Table View Datasource and Delegate

extension FilterViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return displayDistanceOptions ? Filter.radii.count : 1
        case 2:
            return displaySortOptions ? YelpSortMode.count() : 1
        case 3:
            return Filter.categories.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
            cell.switchControl.isOn = filter.dealsOnly
            cell.firstLabel?.text = "Offering a Deal"

            cell.delegate = self

            return cell

        case 1:

            if displayDistanceOptions {

                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedOptionCell")!
                    cell.firstLabel?.text = filter.formattedRadius
                    return cell

                case 1...4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OtherOptionCell")!
                    cell.firstLabel?.text = filter.otherRadiiOtions[indexPath.row - 1]

                    return cell

                default:
                    break
                }

            } else {

                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")!
                cell.firstLabel?.text = filter.formattedRadius
                return cell
            }

        case 2:

            if displaySortOptions {

                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedOptionCell")!
                    cell.firstLabel?.text = filter.sortName
                    return cell

                case 1...2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OtherOptionCell")!
                    cell.firstLabel?.text = filter.otherSortOptions[indexPath.row - 1]
                    return cell

                default:
                    break
                }

            } else {

                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")!
                cell.firstLabel?.text = filter.sortName
                return cell
            }

        case 3:

            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell

            cell.firstLabel?.text = Filter.categories[indexPath.row]["name"]!

            if selectedCategoryIndices.filter({ (element) -> Bool in
                element == indexPath.row
            }).count == 1 {
                cell.switchControl.isOn = true
            } else {
                cell.switchControl.isOn = false
            }

            cell.delegate = self

            return cell

        default:
            break

        }

        return tableView.dequeueReusableCell(withIdentifier: "OtherOptionCell")!
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Distance"
        case 2:
            return "Sort By"
        case 3:
            return "Category"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 1:
            if displayDistanceOptions { // Get the selected distance option
                displayDistanceOptions = false

                let newSelectedValue = tableView.cellForRow(at: indexPath)!.firstLabel!.text!

                if let matchingElement = Filter.radii.first(where: { (element) -> Bool in
                    return element.value == newSelectedValue
                }) {
                    filter.setRadius(matchingElement.key)
                }

            } else { // display other display options
                displayDistanceOptions = true
            }

            tableView.reloadData()

        case 2:
            if displaySortOptions { // Get the selected sort option
                displaySortOptions = false

                let newSelectedValue = tableView.cellForRow(at: indexPath)!.firstLabel!.text!

                if let matchingElement = Filter.sorts.first(where: { (element) -> Bool in
                    return element.value == newSelectedValue
                }) {
                    filter.setSortType(matchingElement.key)
                }
                
            } else { // display other sort options
                displaySortOptions = true
            }
            
            tableView.reloadData()
            
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
}
