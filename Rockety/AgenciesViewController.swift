//
//  AgenciesViewController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 05.06.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import Alamofire
import CoreSpotlight
import MobileCoreServices
import TBEmptyDataSet

class AgenciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RocketSearchControllerDelegate, TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    
    //MARK: IBOutlet
    @IBOutlet var tableView: UITableView!
    
    //LLAPI
    var LSPs = [LSP.Agency]()
    var filteredLSPs = [LSP.Agency]()
    
    //MARK: Properties
    let refreshControl = UIRefreshControl()
    
    var shouldShowSearchResults = false
    var rocketSearchController: RocketSearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(downloadLSP), for: .valueChanged)
        refreshControl.backgroundColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "L O A D I N G...", attributes: [NSAttributedStringKey.font: UIFont(name: "Anurati-Regular", size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.white])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        if (traitCollection.forceTouchCapability == .available) {
//            registerForPreviewing(with: self, sourceView: view)
//        }
        
        configureRocketSearchController()
        
        downloadLSP()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Data
    
    @objc func downloadLSP() {
        Alamofire.request(API.All.agencies.url()).responseJSON { (response) in
            if let data = response.data {
                let decoder = JSONDecoder()
                var decodedLSP = try! decoder.decode(LSP.self, from: data)
                let agencies = decodedLSP.agencies.filter { $0.countryCode != "UNK" }
                self.LSPs = agencies.sorted { $0.name < $1.name }
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredLSPs.count
        } else {
            return LSPs.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgencyCell", for: indexPath) as! AgencyTableViewCell
        
        var agency: LSP.Agency
        if shouldShowSearchResults {
            agency = filteredLSPs[indexPath.row]
        } else {
            agency = LSPs[indexPath.row]
        }
        
        cell.agencyNameLabel.text = agency.name
        
        let delimiter = ","
        let countries = agency.countryCode.components(separatedBy: delimiter)
        var flags = ""
        for country in countries {
            let noSpaceCountry = country.trimmingCharacters(in: .whitespaces)
            flags += IsoCountryCodes.find(key: noSpaceCountry).flag
        }
        
        cell.agencyCountryLabel.text = flags
        
        return cell
    }
    
    //MARK: TBEmptyDataSetDataSource & TBEmptyDataSetDelegate
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        if !shouldShowSearchResults {
            return #imageLiteral(resourceName: "asteroid")
        }
        
        return nil
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [
            NSAttributedStringKey.font : UIFont(name: "Anurati-Regular", size: 17),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        if !shouldShowSearchResults {
            return NSAttributedString(string: "L O A D I N G...", attributes: attributes)
        }
        
        return nil
    }
    
    //MARK: RocketSearchControllerDelegate
    
    func configureRocketSearchController() {
        rocketSearchController = RocketSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50), searchBarFont: UIFont.systemFont(ofSize: 16), searchBarTextColor: UIColor.white, searchBarTintColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1))
        rocketSearchController.rocketSearchBar.placeholder = "S E A R C H"
        rocketSearchController.customDelegate = self
        
        tableView.tableHeaderView = rocketSearchController.rocketSearchBar
    }
    
    func didStartSearching() {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        
        filteredLSPs = LSPs.filter({ (agency) -> Bool in
            let agencyName: NSString = agency.name as NSString
            
            return (agencyName.range(of: searchText, options: .caseInsensitive).location) != NSNotFound
        })
        
        tableView.reloadData()
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAgencyMissions" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if shouldShowSearchResults {
                    let destVC = segue.destination as! AgencyMissionsViewController
                    destVC.agencyId = filteredLSPs[indexPath.row].id
                    destVC.agency = filteredLSPs[indexPath.row]
                } else {
                    let destVC = segue.destination as! AgencyMissionsViewController
                    destVC.agencyId = LSPs[indexPath.row].id
                    destVC.agency = LSPs[indexPath.row]
                }
            }
        }
    }
    
    @IBAction func returnAgency(_ segue: UIStoryboardSegue) {
        downloadLSP()
    }
    

}
