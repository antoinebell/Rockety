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
import StoreKit

class MissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, RocketSearchControllerDelegate, UIViewControllerPreviewingDelegate, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    
    // - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var launchesLabel: UILabel!

    // - Properties
    var spaceXMissions = [Mission]()
    var filteredSpaceXMissions = [Mission]()
    
    var elseLaunches: ElseMission!
    var filteredElseLaunches = [ElseMission.Launch]()
    
    var downloaded = false
    
    var missionId: String?
    
    let refreshControl = UIRefreshControl()
    
    lazy var bulletinManager: BLTNItemManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BLTNItemManager(rootItem: introPage)
    }()
    
    var currentIndex = 0
    
    var shouldShowSearchResults = false
    var rocketSearchController: RocketSearchController!
    
    var selectedLaunchIndex: Int!
    
    // MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareForBulletin()
        
        refreshControl.addTarget(self, action: #selector(downloadAll), for: .valueChanged)
        refreshControl.backgroundColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "L O A D I N G...", attributes: [NSAttributedString.Key.font: UIFont(name: "Anurati-Regular", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        
        view.backgroundColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        
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
    
    // MARK: Data - SpaceX
    
    @objc func downloadSpaceX() {
        Alamofire.request(API.SpaceX.allLaunches.url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedMissions = try! decoder.decode([Mission].self, from: data)
                self.spaceXMissions = decodedMissions
            }
        }
    }
    
    // MARK: Data - Else
    
    @objc func downloadAll() {
        Alamofire.request(API.All.nextLaunches.url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedLaunches = try! decoder.decode(ElseMission.self, from: data)
                self.elseLaunches = decodedLaunches
                
                DispatchQueue.main.async {
                    print("Downloaded Everything")
                    self.setupElseSearchableContent()
                    self.refreshControl.endRefreshing()
                    self.downloaded = true
                    self.tableView.reloadData()
                    
                    // Deeplink handling
                    if self.missionId != nil {
                        self.performSegue(withIdentifier: "performDeeplink", sender: self)
                    }
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
        if downloaded {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredElseLaunches.count
        } else {
            return elseLaunches.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as! MissionTableViewCell
        
        var mission: ElseMission.Launch!
        
        if shouldShowSearchResults {
            mission = filteredElseLaunches[indexPath.row]
        } else {
            mission = elseLaunches.launches[indexPath.row]
        }
        
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
        
        return cell
    }
    
    //MARK: TBEmptyDataSetDataSource & TBEmptyDataSetDelegate
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        if !shouldShowSearchResults {
            return #imageLiteral(resourceName: "asteroid")
        } else {
            if rocketSearchController.rocketSearchBar.text != "" {
                return #imageLiteral(resourceName: "asteroid")
            }
            return nil
        }
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: "Anurati-Regular", size: 17),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        if !shouldShowSearchResults {
            return NSAttributedString(string: "L O A D I N G...", attributes: attributes as [NSAttributedString.Key : Any])
        } else {
            if rocketSearchController.rocketSearchBar.text != "" {
                return NSAttributedString(string: "N O  R E S U L T S", attributes: attributes as [NSAttributedString.Key : Any])
            }
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
    
    func configureRocketSearchController() {
        rocketSearchController = RocketSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50), searchBarFont: UIFont.systemFont(ofSize: 16), searchBarTextColor: UIColor.white, searchBarTintColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1))
        rocketSearchController.rocketSearchBar.placeholder = "Search"
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
        
        searchBar.resignFirstResponder()
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
        
        filteredElseLaunches = elseLaunches.launches.filter({ (launch) -> Bool in
            let launchText: NSString = launch.name as NSString
            
            return (launchText.range(of: searchText, options: .caseInsensitive).location) != NSNotFound
        })
        
        
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
        
        if shouldShowSearchResults {
            destVC.isSpaceX = false
            destVC.launch = filteredElseLaunches[indexPath.row]
        } else {
            destVC.isSpaceX = false
            destVC.launch = elseLaunches.launches[indexPath.row]
        }
        
        destVC.preferredContentSize = CGSize(width: 0.0, height: 450)
        previewingContext.sourceRect = cell.frame
        
        return destVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    //MARK: CoreSpotlight
    
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
                    selectedLaunchIndex = elseLaunches.launches.firstIndex { (mission) -> Bool in
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
    
    //MARK: SKStore
    
    func showReview() {
        let review = Review()
        review.showReview()
    }
    
    //MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMission" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let found = spaceXMissions.firstIndex { (mission) -> Bool in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let spaceXDate = DateFormatter.localizedString(from: dateFormatter.date(from: mission.launch_date_local)!, dateStyle: .short, timeStyle: .medium)
                    
                    //Else
                    var elseDate = ""
                    
                    dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    if shouldShowSearchResults {
                        elseDate = DateFormatter.localizedString(from: dateFormatter.date(from: filteredElseLaunches[indexPath.row].net)!, dateStyle: .short, timeStyle: .medium)
                    } else {
                        elseDate = DateFormatter.localizedString(from: dateFormatter.date(from: elseLaunches.launches[indexPath.row].net)!, dateStyle: .short, timeStyle: .medium)
                    }
                    
                    return spaceXDate == elseDate
                }
                
                var isSpaceX = false
                
                if found != nil {
                    isSpaceX = true
                }
                
                if shouldShowSearchResults {
                    let destVC = segue.destination as! MissionsDetailViewController
                    destVC.isSpaceX = isSpaceX
                    if isSpaceX {
                        destVC.mission = spaceXMissions[found!]
                    }
                    destVC.launch = filteredElseLaunches[indexPath.row]
                } else {
                    let destVC = segue.destination as! MissionsDetailViewController
                    destVC.isSpaceX = isSpaceX
                    if isSpaceX {
                        destVC.mission = spaceXMissions[found!]
                    }
                    destVC.launch = elseLaunches.launches[indexPath.row]
                }
            }
        } else if segue.identifier == "showMissionElseCS" {
            let destVC = segue.destination as! MissionsDetailViewController
            destVC.isSpaceX = false
            destVC.launch = elseLaunches.launches[selectedLaunchIndex]
        } else if segue.identifier == "performDeeplink" {
            guard let identifier = Int(missionId ?? "") else { return }
            let mission = elseLaunches.launches.filter { $0.id == identifier }
            guard mission.count > 0 else { return }
            let destVC = segue.destination as! MissionsDetailViewController
            destVC.isSpaceX = false
            destVC.launch = mission[0]
        }
    }
    
    @IBAction func returnMissions(segue: UIStoryboardSegue) {
        showReview()
    }


}

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
}

