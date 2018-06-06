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
import CoreSpotlight
import MobileCoreServices
import UserNotifications
import BetterSegmentedControl
import BLTNBoard
import TBEmptyDataSet

class MissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, RocketSearchControllerDelegate, UIViewControllerPreviewingDelegate, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    
    //MARK: IBOutlet
    @IBOutlet var tableView: UITableView!
    @IBOutlet var launchesLabel: UILabel!
    @IBOutlet var segmentedControl: BetterSegmentedControl!
    
    //SpaceX API
    var spaceXMissions = [Mission]()
    var spaceXRockets = [Int: Rocket]()
    var spaceXLaunchpads = [Int: Launchpad]()
    
    var filteredSpaceXMissions = [Mission]()
    
    var spaceXIndex: Int = 63
    var spaceXDownloaded: Bool = false
    
    //Else API
    var elseLaunches: ElseMission!
    var elseAgencies = [Int: AgencyResult]()
    var elseLaunchpads = [Int: PadResult]()
    
    var filteredElseLaunches = [ElseMission.Launch]()

    //MARK: Properties
    let refreshControl = UIRefreshControl()
    
    lazy var bulletinManager: BLTNItemManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BLTNItemManager(rootItem: introPage)
    }()
    
    var currentIndex = 0
    
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var rocketSearchController: RocketSearchController!
    
    var selectedLaunchIndex: Int!
    
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
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableViewAutomaticDimension
        
        segmentedControl.titles = ["S P A C E X", "A L L"]
        segmentedControl.titleFont = UIFont(name: "Anurati-Regular", size: 15)!
        segmentedControl.selectedTitleFont = UIFont(name: "Anurati-Regular", size: 15)!
        
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        configureRocketSearchController()
        
        downloadSpaceX()
        downloadAll()
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
                    
                    if SettingsViewController.spaceXNotifications && SettingsViewController.elseNotifications == false {
                        
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        
                        let center = UNUserNotificationCenter.current()
                        center.getNotificationSettings(completionHandler: { (settings) in
                            if settings.authorizationStatus == .authorized {
                                let content = UNMutableNotificationContent()
                                content.body = "\(mission.mission_name) is lifting off in 15 minutes !"
                                content.sound = UNNotificationSound.default()
                                let dateToTrigger = missionDate?.addingTimeInterval(-900)
                                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: dateToTrigger!)
                                _ = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                            }
                        })
                    }
                    
                    
                }
            }
            
            DispatchQueue.main.async {
                self.setupSpXSearchableContent()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                let path = IndexPath.init(row: nextMission, section: 0)
                self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
                self.spaceXIndex = nextMission
                self.spaceXDownloaded = true
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
//                    self.downloadAgencyData(agencyId: launch.lsp, missionNumber: launch.id)
                    if SettingsViewController.elseNotifications {
                        
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        
                        let center = UNUserNotificationCenter.current()
                        center.getNotificationSettings(completionHandler: { (settings) in
                            if settings.authorizationStatus == .authorized {
                                let content = UNMutableNotificationContent()
                                content.body = "\(launch.name) is lifting off in 15 minutes !"
                                content.sound = UNNotificationSound.default()
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                let dateToTrigger = dateFormatter.date(from: launch.net)?.addingTimeInterval(-900)
                                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: dateToTrigger!)
                                _ = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                            }
                        })
                    }
                }
                
                DispatchQueue.main.async {
                    self.setupElseSearchableContent()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    if self.spaceXDownloaded {
                        let path = IndexPath.init(row: self.spaceXIndex, section: 0)
                        self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
                    }
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
                    let path = IndexPath.init(row: 0, section: 0)
                    self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
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
                    let path = IndexPath.init(row: 0, section: 0)
                    self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
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
            if shouldShowSearchResults {
                return filteredElseLaunches.count
            } else {
                return elseLaunches.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as! MissionTableViewCell
        
        if currentIndex == 0 { //SpaceX
            
            var mission: Mission!
            
            if shouldShowSearchResults {
                mission = filteredSpaceXMissions[indexPath.row]
            } else {
                mission = spaceXMissions[indexPath.row]
            }
            
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
            
        } else { //Else
            
            var mission: ElseMission.Launch!
            
            if shouldShowSearchResults {
                mission = filteredElseLaunches[indexPath.row]
            } else {
                mission = elseLaunches.launches[indexPath.row]
            }
            
            cell.missionNumberLabel.text = "#\(mission.id!)"
            
            var delimiter = "|"
            var missionName = mission.name.components(separatedBy: delimiter)
            missionName[1].remove(at: missionName[1].startIndex)
            
            cell.missionNameLabel.text = missionName[1]
            cell.missionOperatorLabel.text = mission.lsp.name
            cell.missionRocketLabel.text = missionName[0]
            
            delimiter = ","
            var padName = mission.location.pads[0].name.components(separatedBy: delimiter)
            
            cell.missionLaunchSiteLabel.text = padName[0]
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let date = dateFormatter.date(from: mission.net) {
                let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                cell.missionDateLabel.text = localizedDateTime
            } else {
                cell.missionDateLabel.text = mission.net
            }
            
        }
        
        return cell
    }
    
    //MARK: TBEmptyDataSetDataSource & TBEmptyDataSetDelegate
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        if !shouldShowSearchResults {
            return #imageLiteral(resourceName: "asteroid")
        } else {
            return nil
        }
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [
            NSAttributedStringKey.font : UIFont(name: "Anurati-Regular", size: 17),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        if !shouldShowSearchResults {
            return NSAttributedString(string: "L O A D I N G...", attributes: attributes)
        } else {
            return nil
        }
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
        
        if currentIndex == 0 {
            filteredSpaceXMissions = spaceXMissions.filter({ (mission) -> Bool in
                let missionText: NSString = mission.mission_name as NSString
                
                return (missionText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
        } else {
            filteredElseLaunches = elseLaunches.launches.filter({ (launch) -> Bool in
                let launchText: NSString = launch.name as NSString

                return (launchText.range(of: searchString!, options: .caseInsensitive).location) != NSNotFound
            })
        }
        
        
        
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
        
        if currentIndex == 0 {
            filteredSpaceXMissions = spaceXMissions.filter({ (mission) -> Bool in
                let missionText: NSString = mission.mission_name as NSString
                
                return (missionText.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
        } else {
            filteredElseLaunches = elseLaunches.launches.filter({ (launch) -> Bool in
                let launchText: NSString = launch.name as NSString
                
                return (launchText.range(of: searchText, options: .caseInsensitive).location) != NSNotFound
            })
        }
        
        
        tableView.reloadData()
    }
    
    //MARK: UIViewControllerPreviewingContextDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: self.view.convert(location, to: tableView)) else {
            print("IndexPath problem")
            return nil
        }
        
        print(indexPath)
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            print("Cell problem")
            return nil
        }
        
        guard let destVC = storyboard?.instantiateViewController(withIdentifier: "MissionsDetailViewController") as? MissionsDetailViewController else {
            return nil
        }
        
        if currentIndex == 0 {
            if shouldShowSearchResults {
                destVC.mission = filteredSpaceXMissions[indexPath.row]
                destVC.rocket = spaceXRockets[filteredSpaceXMissions[indexPath.row].flight_number]
                destVC.launchpad = spaceXLaunchpads[filteredSpaceXMissions[indexPath.row].flight_number]
                destVC.isSpaceX = true
            } else {
                destVC.mission = spaceXMissions[indexPath.row]
                destVC.rocket = spaceXRockets[spaceXMissions[indexPath.row].flight_number]
                destVC.launchpad = spaceXLaunchpads[spaceXMissions[indexPath.row].flight_number]
                destVC.isSpaceX = true
            }
        } else {
            if shouldShowSearchResults {
                destVC.isSpaceX = false
                destVC.launch = filteredElseLaunches[indexPath.row]
            } else {
                destVC.isSpaceX = false
                destVC.launch = elseLaunches.launches[indexPath.row]
            }
        }
        
        destVC.preferredContentSize = CGSize(width: 0.0, height: 450)
        previewingContext.sourceRect = cell.frame
        
        return destVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    //MARK: CoreSpotlight
    
    func setupSpXSearchableContent() {
        var searchableItems = [CSSearchableItem]()
        
        for i in stride(from: 0, to: spaceXMissions.count, by: 1) {
            let mission = spaceXMissions[i]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = DateFormatter.localizedString(from: dateFormatter.date(from: mission.launch_date_local)!, dateStyle: .short, timeStyle: .medium)
            
            let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            searchableItemAttributeSet.title = mission.mission_name
            searchableItemAttributeSet.contentDescription = "SpaceX | \(mission.rocket.rocket_name) \(mission.rocket.rocket_type) | Launch Date : \(date)"
            
            var keywords = [String]()
            keywords.append(mission.mission_name)
            keywords.append(mission.rocket.rocket_name)
            keywords.append(mission.rocket.rocket_type)
            for core in mission.rocket.first_stage.cores {
                if core.core_serial != nil {
                    keywords.append(core.core_serial!)
                }
            }
            for payload in mission.rocket.second_stage.payloads {
                keywords.append(payload.payload_id)
                keywords.append(payload.payload_type)
                for customer in payload.customers {
                    keywords.append(customer)
                }
            }
            
            searchableItemAttributeSet.keywords = keywords
            
            let searchableItem = CSSearchableItem(uniqueIdentifier: "ch.antoinebellanger.Rockety.SpX.\(mission.flight_number)", domainIdentifier: "launches", attributeSet: searchableItemAttributeSet)
            
            searchableItems.append(searchableItem)
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) in
            }
        }
    }
    
    func setupElseSearchableContent() {
        var searchableItems = [CSSearchableItem]()
        
        for i in stride(from: 0, to: elseLaunches.count, by: 1) {
            let mission = elseLaunches.launches[i]
            
            let delimiter = "|"
            var missionName = mission.name.components(separatedBy: delimiter)
            missionName[1].remove(at: missionName[1].startIndex)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let date = DateFormatter.localizedString(from: dateFormatter.date(from: mission.net)!, dateStyle: .short, timeStyle: .medium)
            
            let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            searchableItemAttributeSet.title = missionName[1]
            searchableItemAttributeSet.contentDescription = "\(mission.lsp.name!) | \(mission.rocket.name!) | Launch Date : \(date)"
            
            var keywords = [String]()
            keywords.append(mission.name)
            keywords.append(mission.rocket.name)

            searchableItemAttributeSet.keywords = keywords
            
            let missionId = mission.id
            
            let searchableItem = CSSearchableItem(uniqueIdentifier: "ch.antoinebellanger.Rockety.Else.\(missionId!)", domainIdentifier: "launches", attributeSet: searchableItemAttributeSet)
            searchableItems.append(searchableItem)
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) in
                
            }
        }
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == CSSearchableItemActionType {
            if let userInfo = activity.userInfo {
                let selectedLaunch = userInfo[CSSearchableItemActivityIdentifier] as! String
                let components = selectedLaunch.components(separatedBy: ".")
                print(components, components[2])
                if components[3] == "SpX" {
                    selectedLaunchIndex = (Int(selectedLaunch.components(separatedBy: ".").last!)!-1)
                    performSegue(withIdentifier: "showMissionSpXCS", sender: self)
                } else if components[3] == "Else" {
                    print(Int(selectedLaunch.components(separatedBy: ".").last!)!)
                    selectedLaunchIndex = elseLaunches.launches.index { (mission) -> Bool in
                        mission.id == Int(selectedLaunch.components(separatedBy: ".").last!)!
                    }
                    performSegue(withIdentifier: "showMissionElseCS", sender: self)
                }
            }
        }
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
        
        bulletinManager.showBulletin(above: self)
        
    }
    
    @objc func setupDidComplete() {
        BulletinDataSource.userDidCompleteSetup = true
    }
    
    //MARK: IBAction
    
    @IBAction func segmentValueChanged(_ sender: BetterSegmentedControl) {
        
        print(sender.index)

        currentIndex = Int(sender.index)
        
        switch sender.index {
        case 0:
            self.refreshControl.addTarget(self, action: #selector(self.downloadSpaceX), for: .valueChanged)
            self.refreshControl.removeTarget(self, action: #selector(self.downloadAll), for: .valueChanged)
            self.tableView.reloadData()
            let path = IndexPath.init(row: self.spaceXIndex, section: 0)
            self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
        case 1:
            self.refreshControl.removeTarget(self, action: #selector(self.downloadSpaceX), for: .valueChanged)
            self.refreshControl.addTarget(self, action: #selector(self.downloadAll), for: .valueChanged)
            self.tableView.reloadData()
            let path = IndexPath.init(row: 0, section: 0)
            self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
        default:
            break;
        }
    }
    
    //MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMission" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if currentIndex == 0 {
                    if shouldShowSearchResults {
                        let destVC = segue.destination as! MissionsDetailViewController
                        destVC.mission = filteredSpaceXMissions[indexPath.row]
                        destVC.rocket = spaceXRockets[filteredSpaceXMissions[indexPath.row].flight_number]
                        destVC.launchpad = spaceXLaunchpads[filteredSpaceXMissions[indexPath.row].flight_number]
                        destVC.isSpaceX = true
                    } else {
                        let destVC = segue.destination as! MissionsDetailViewController
                        destVC.mission = spaceXMissions[indexPath.row]
                        destVC.rocket = spaceXRockets[spaceXMissions[indexPath.row].flight_number]
                        destVC.launchpad = spaceXLaunchpads[spaceXMissions[indexPath.row].flight_number]
                        destVC.isSpaceX = true
                    }
                } else {
                    if shouldShowSearchResults {
                        let destVC = segue.destination as! MissionsDetailViewController
                        destVC.isSpaceX = false
                        destVC.launch = filteredElseLaunches[indexPath.row]
                    } else {
                        let destVC = segue.destination as! MissionsDetailViewController
                        destVC.isSpaceX = false
                        destVC.launch = elseLaunches.launches[indexPath.row]
                    }
                }
            }
        } else if segue.identifier == "showMissionSpXCS" {
            let destVC = segue.destination as! MissionsDetailViewController
            destVC.isSpaceX = true
            destVC.mission = spaceXMissions[selectedLaunchIndex]
            destVC.rocket = spaceXRockets[spaceXMissions[selectedLaunchIndex].flight_number]
            destVC.launchpad = spaceXLaunchpads[spaceXMissions[selectedLaunchIndex].flight_number]
        } else if segue.identifier == "showMissionElseCS" {
            let destVC = segue.destination as! MissionsDetailViewController
            destVC.isSpaceX = false
            destVC.launch = elseLaunches.launches[selectedLaunchIndex]
        }
    }
    
    @IBAction func returnMissions(segue: UIStoryboardSegue) {
        
    }


}

