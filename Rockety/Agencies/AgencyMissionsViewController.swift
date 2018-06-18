//
//  AgencyMissionsViewController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 05.06.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import Alamofire
import TBEmptyDataSet
import Crashlytics

class AgencyMissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RocketSearchControllerDelegate, TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    
    //MARK: IBOutlet
    @IBOutlet var tableView: UITableView!
    
    //MARK: Properties
    var agencyLaunches = [ElseMission.Launch]()
    var filteredAgencyLaunches = [ElseMission.Launch]()
    
    var agencyId: Int!
    var agency: LSP.Agency!
    
    var nextMission = 0
    
    let refreshControl = UIRefreshControl()
    
    var shouldShowSearchResults = false
    var rocketSearchController: RocketSearchController!

    var gestureRecognizer: UISwipeGestureRecognizer!
    
    var downloaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(downloadMissions), for: .valueChanged)
        refreshControl.backgroundColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "L O A D I N G...", attributes: [NSAttributedStringKey.font: UIFont(name: "Anurati-Regular", size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.white])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableViewAutomaticDimension
        
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(back(sender:)))
        gestureRecognizer.direction = .right
        self.view.addGestureRecognizer(gestureRecognizer)
        
        var attributes:[String:String] = [:]
        attributes = ["agencyName": agency.name]
        
        Answers.logCustomEvent(withName: "Agency", customAttributes: attributes)
        
        configureRocketSearchController()

        downloadMissions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Data
    
    @objc func downloadMissions() {
       
        Alamofire.request(API.All.agencyMissions(agencyId: String(agencyId)).url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedLaunches = try! decoder.decode(ElseMission.self, from: data)
                self.agencyLaunches = decodedLaunches.launches
                
                var count = -1
                
                for launch in decodedLaunches.launches {
                    count = count + 1
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    let missionDate = dateFormatter.date(from: launch.net)
                    let boolDate = Date() > missionDate!
                    if boolDate == true {
                        self.nextMission = count
                    }
                }
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.downloaded = true
                    self.tableView.reloadData()
                    if self.nextMission > 1 {
                        let path = IndexPath.init(row: self.nextMission, section: 0)
                        self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
                    }
                    
                }
            }
        }
    }
    
    //MARK: UITableViewDataSource & Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredAgencyLaunches.count
        } else {
            return agencyLaunches.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var mission: ElseMission.Launch!
        
        if shouldShowSearchResults {
            mission = filteredAgencyLaunches[indexPath.row]
        } else {
            mission = agencyLaunches[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as! MissionTableViewCell
        
        cell.missionNumberLabel.text = "#\(mission.id!)"
        
        var delimiter = "|"
        var missionName = mission.name.components(separatedBy: delimiter)
        missionName[1].remove(at: missionName[1].startIndex)
        
        cell.missionNameLabel.text = missionName[1]
        cell.missionOperatorLabel.text = agency.name
        cell.missionRocketLabel.text = missionName[0]
        
        delimiter = ","
        var padName = mission.location?.pads[0].name.components(separatedBy: delimiter)
        
        cell.missionLaunchSiteLabel.text = padName?[0] ?? "N/A"
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = dateFormatter.date(from: mission.net) {
            let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
            cell.missionDateLabel.text = localizedDateTime
        } else {
            cell.missionDateLabel.text = mission.net
        }
        
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
            if downloaded == false {
                return NSAttributedString(string: "L O A D I N G...", attributes: attributes)
            } else {
                return NSAttributedString(string: "H O L D  O N !", attributes: attributes)
            }
        }
        
        return nil
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: .light),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        if !shouldShowSearchResults {
            if downloaded == false {
                return nil
            } else {
                return NSAttributedString(string: "An asteroid is coming and no launch is planned for the moment !", attributes: attributes)
            }
        }
        
        return nil
    }
    
    
    //MARK: UISearchController
    
    func configureRocketSearchController() {
        rocketSearchController = RocketSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50), searchBarFont: UIFont.systemFont(ofSize: 16), searchBarTextColor: UIColor.white, searchBarTintColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1))
        rocketSearchController.rocketSearchBar.placeholder = "Search"
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
        
        filteredAgencyLaunches = agencyLaunches.filter({ (launch) -> Bool in
            let launchName: NSString = launch.name as NSString
            
            return (launchName.range(of: searchText, options: .caseInsensitive).location) != NSNotFound
        })
        
        tableView.reloadData()
    }

    //MARK: UIGestureRecognizer
    
    @objc func back(sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "returnAgency", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAgencyMissionDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if shouldShowSearchResults {
                    let destVC = segue.destination as! MissionsDetailViewController
                    destVC.isSpaceX = false
                    destVC.launch = filteredAgencyLaunches[indexPath.row]
                    destVC.isComingFromAgency = true
                } else {
                    let destVC = segue.destination as! MissionsDetailViewController
                    destVC.isSpaceX = false
                    destVC.launch = agencyLaunches[indexPath.row]
                    destVC.isComingFromAgency = true
                }
            }
        }
    }
    
    @IBAction func returnAgencyMission(_ sender: UIStoryboardSegue) {
        
    }
    

}
