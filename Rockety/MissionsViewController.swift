//
//  ViewController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 21.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import PinterestSegment
import BulletinBoard

class MissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, RocketSearchControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    //SpaceX API
    var spaceXMissions = [Mission]()
    var spaceXRockets = [Int: Rocket]()
    var spaceXLaunchpads = [Int: Launchpad]()
    
    var filteredSpaceXMissions = [Mission]()
    
    //Else API
    var elseLaunches: ElseMission!
    var elseAgencies = [Int: AgencyResult]()
    var elseLaunchpads = [Int: PadResult]()

    //MARK: Properties
    let refreshControl = UIRefreshControl()
    
    lazy var bulletinManager: BulletinManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BulletinManager(rootItem: introPage)
    }()
    
    var currentIndex = 0
    
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var rocketSearchController: RocketSearchController!
    
    //MARK: viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareForBulletin()
        
        refreshControl.addTarget(self, action: #selector(downloadSpaceX), for: .valueChanged)
        refreshControl.backgroundColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "L O A D I N G...", attributes: [NSAttributedStringKey.font: UIFont(name: "Anurati-Regular", size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.white])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.rowHeight = 145
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        let w = view.frame.width
        let titles = ["S P A C E  X"]
        let s = PinterestSegment(frame: CGRect(x: 0, y: 100, width: w - 100, height: 35), titles: titles)
        s.style.titleFont = UIFont(name: "Anurati-Regular", size: 14)!
        view.addSubview(s)
        
        s.valueChange = { index in
            
            self.currentIndex = index
            
            if index == 0 {
                self.refreshControl.addTarget(self, action: #selector(self.downloadSpaceX), for: .valueChanged)
                self.refreshControl.removeTarget(self, action: #selector(self.downloadAll), for: .valueChanged)
                self.downloadSpaceX()
            } else {
                self.refreshControl.removeTarget(self, action: #selector(self.downloadSpaceX), for: .valueChanged)
                self.refreshControl.addTarget(self, action: #selector(self.downloadAll), for: .valueChanged)
                self.downloadAll()
            }
        }
        
        configureRocketSearchController()
        
        downloadSpaceX()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Data
    
    //MARK: Data - SpaceX
    
    @objc func downloadSpaceX() {
        
        var nextMission = 0
        
        Alamofire.request(API.SpaceX.allLaunches.url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedMissions = try! decoder.decode([Mission].self, from: data)
                self.spaceXMissions = decodedMissions
                
                for mission in decodedMissions {
                    self.downloadLaunchpadData(lauchpadId: mission.launch_site.site_id, missionNumber: mission.flight_number)
                    self.downloadRocketData(rocketId: mission.rocket.rocket_id, missionNumber: mission.flight_number)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let missionDate = dateFormatter.date(from: mission.launch_date_local)
                    let boolDate = Date() > missionDate!
                    if boolDate == true {
                        nextMission = mission.flight_number
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                let path = IndexPath.init(row: nextMission, section: 0)
                self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    func downloadRocketData(rocketId: String, missionNumber: Int) {
        Alamofire.request(API.SpaceX.rocket(rocketId: rocketId).url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedRocket = try! decoder.decode(Rocket.self, from: data)
                self.spaceXRockets[missionNumber] = decodedRocket
            }
        }
    }
    
    func downloadLaunchpadData(lauchpadId: String, missionNumber: Int) {
        Alamofire.request(API.SpaceX.launchpad(launchpadId: lauchpadId).url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedLaunchpad = try! decoder.decode(Launchpad.self, from: data)
                self.spaceXLaunchpads[missionNumber] = decodedLaunchpad
            }
        }
    }
    
    //MARK: Data - Else
    
    @objc func downloadAll() {
        Alamofire.request(API.All.nextLaunches.url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedLaunches = try! decoder.decode(ElseMission.self, from: data)
                self.elseLaunches = decodedLaunches
            
                let launches = decodedLaunches.launches
                for launch in launches {
                    self.downloadAgencyData(agencyId: launch.lsp, missionNumber: launch.id)
                    print(launch.locationid)
                    if launch.locationid != nil {
//                        print("Downloading pad for missionid :", launch.id)
                        self.downloadPadData(padId: launch.locationid!, missionNumber: launch.id)
                    } else {
//                        print("Pad is not available for missionid :", launch.id)
                    }
                }
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    let path = IndexPath.init(row: 0, section: 0)
                    self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
                }
            }
        }
    }
    
    func downloadAgencyData(agencyId: String, missionNumber: Int) {
        Alamofire.request(API.All.agency(agencyId: agencyId).url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedAgency = try! decoder.decode(AgencyResult.self, from: data)
                self.elseAgencies[missionNumber] = decodedAgency
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func downloadPadData(padId: Int, missionNumber: Int) {
        print(padId)
        print(API.All.launchpad(launchpadId: padId).url())
        Alamofire.request(API.All.launchpad(launchpadId: padId).url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedPad = try! decoder.decode(PadResult.self, from: data)
                self.elseLaunchpads[missionNumber] = decodedPad
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: Image
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.global(qos: .background).async {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentIndex == 0 {
            if shouldShowSearchResults {
                return filteredSpaceXMissions.count
            } else {
                return spaceXMissions.count
            }
        } else {
            return elseLaunches.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as! MissionTableViewCell
        
        if currentIndex == 0 { //SpaceX
            
            if shouldShowSearchResults {
                
                let mission = filteredSpaceXMissions[indexPath.row]
                cell.missionNumberLabel.text = "#\(mission.flight_number)"
                cell.missionNameLabel.text = mission.mission_name
                cell.missionOperatorLabel.text = "SpaceX"
                cell.missionRocketLabel.text = "\(mission.rocket.rocket_name) \(mission.rocket.rocket_type)"
                cell.missionLaunchSiteLabel.text = mission.launch_site.site_name
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if let date = dateFormatter.date(from: mission.launch_date_local) {
                    let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                    cell.missionDateLabel.text = localizedDateTime
                } else {
                    cell.missionDateLabel.text = mission.launch_date_local
                }
                
            } else {
                
                let mission = spaceXMissions[indexPath.row]
                cell.missionNumberLabel.text = "#\(mission.flight_number)"
                cell.missionNameLabel.text = mission.mission_name
                cell.missionOperatorLabel.text = "SpaceX"
                cell.missionRocketLabel.text = "\(mission.rocket.rocket_name) \(mission.rocket.rocket_type)"
                cell.missionLaunchSiteLabel.text = mission.launch_site.site_name
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if let date = dateFormatter.date(from: mission.launch_date_local) {
                    let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                    cell.missionDateLabel.text = localizedDateTime
                } else {
                    cell.missionDateLabel.text = mission.launch_date_local
                }
                
            }
            
        } else {
            let mission = elseLaunches.launches[indexPath.row]
            cell.missionNumberLabel.text = "#\(mission.id!)"
            
            var delimiter = "|"
            var missionName = mission.name.components(separatedBy: delimiter)
            missionName[1].remove(at: missionName[1].startIndex)
            
            cell.missionNameLabel.text = missionName[1]
            cell.missionOperatorLabel.text = elseAgencies[mission.id]?.agencies[0].name
            cell.missionRocketLabel.text = missionName[0]

            delimiter = ","
            if elseLaunchpads[mission.id] != nil {
                let missionPad = elseLaunchpads[mission.id]?.pads[0].name.components(separatedBy: delimiter)
                cell.missionLaunchSiteLabel.text = missionPad?[0]
            } else {
                cell.missionLaunchSiteLabel.text = "N/A"
            }
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
            if let date = dateFormatter.date(from: mission.net) {
                let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                cell.missionDateLabel.text = localizedDateTime
            } else {
                cell.missionDateLabel.text = mission.net
            }
        }
        
        return cell
    }
    
    //MARK: Animations
    
    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight = tableView.bounds.size.height
        
        for i in cells {
            let cell: MissionTableViewCell = i as! MissionTableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: MissionTableViewCell = a as! MissionTableViewCell
            UIView.animate(withDuration: 1.2, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            
            index += 1
        }
    }
    
    //MARK: UISearchController
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func configureRocketSearchController() {
        rocketSearchController = RocketSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50), searchBarFont: UIFont.systemFont(ofSize: 16), searchBarTextColor: UIColor.white, searchBarTintColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1))
        rocketSearchController.rocketSearchBar.placeholder = "S E A R C H"
        rocketSearchController.customDelegate = self

        tableView.tableHeaderView = rocketSearchController.rocketSearchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        filteredSpaceXMissions = spaceXMissions.filter({ (mission) -> Bool in
            let missionText: NSString = mission.mission_name as NSString
            
            return (missionText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        tableView.reloadData()
    }
    
    //MARK: RocketSearchControllerDelegate
    
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
        filteredSpaceXMissions = spaceXMissions.filter({ (mission) -> Bool in
            let missionText: NSString = mission.mission_name as NSString
            
            return (missionText.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        tableView.reloadData()
    }
    
    //MARK: BulletinBoard
    
    func prepareForBulletin() {
        
        // Register notification observers
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupDidComplete),
                                               name: .SetupDidComplete,
                                               object: nil)
        
        if !BulletinDataSource.userDidCompleteSetup {
            showBulletin()
        }
        
    }
    
    /**
     * Displays the bulletin.
     */
    
    func showBulletin() {
                
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    
    @objc func setupDidComplete() {
        BulletinDataSource.userDidCompleteSetup = true
    }
    
    //MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMission" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destVC = segue.destination as! MissionsDetailViewController
                destVC.mission = spaceXMissions[indexPath.row]
                destVC.rocket = spaceXRockets[spaceXMissions[indexPath.row].flight_number]
                destVC.launchpad = spaceXLaunchpads[spaceXMissions[indexPath.row].flight_number]
            }
        }
    }
    
    @IBAction func returnMissions(segue: UIStoryboardSegue) {
        
    }


}

