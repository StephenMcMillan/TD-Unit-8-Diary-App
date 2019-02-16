//
//  LocationSearchController.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchControllerDelegate: class {
    func locationSearchController(_ controller: LocationSearchController, userSelectedMapItem mapItem: MKMapItem)
}

class LocationSearchController: UITableViewController {
    
    @IBOutlet weak var locationSearchBar: UISearchBar!
    
    var locations: [MKMapItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: LocationSearchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationSearchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let location = locations[indexPath.row]
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.placemark.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Return to the original view with the location object.
        delegate?.locationSearchController(self, userSelectedMapItem: locations[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    //  MARK: Navigation
    @IBAction func cancelLocationSearch(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension LocationSearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let localSearch = MKLocalSearch(request: searchRequest)
        
        localSearch.start { [unowned self] (response, error) in
            if let response = response {
                self.locations = response.mapItems
            }
        }
    }
}
