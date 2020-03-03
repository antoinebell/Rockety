//
//  MissionsDetailViewController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 22.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import CoreLocation
import SafariServices
import CFAlertViewController
import BLTNBoard
import EventKit
import Crashlytics

class MissionsDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    var isSpaceX: Bool!
    var downloaded = false
    var isComingFromAgency = false
    
    var mission: Mission!
    var rocket: Rocket!
    var launchpad: Launchpad!
    
    var launch: ElseMission.Launch!
    var rocketAPI: API.Rocket = .rocket999
    
    var missionPayloadType: Payloads = .notAvailable
    
    lazy var bulletinManager: BLTNItemManager = {
        let calendarPage = makeCalendarPage()
        return BLTNItemManager(rootItem: calendarPage)
    }()
    
    let eventStore = EKEventStore()
    
    var gestureRecognizer: UISwipeGestureRecognizer!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var calendarButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        rocketAPI = API.Rocket(id: launch.rocket.id)
        
        let eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(String(describing: launch.id))")
        
        print("was event added?", eventAdded)
        
        if eventAdded {
            calendarButton.setImage(#imageLiteral(resourceName: "Calendar-Done"), for: .normal)
        } else {
            calendarButton.setImage(#imageLiteral(resourceName: "Calendar"), for: .normal)
        }
        
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(back(sender:)))
        gestureRecognizer.direction = .right
        self.view.addGestureRecognizer(gestureRecognizer)
        
        //Fabric
        Answers.logCustomEvent(withName: "Rocket", customAttributes: ["rocketName": launch.rocket.name ?? "No Rocket Name", "mission": launch.name ?? "No Mission Name"])
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: API
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        print(url)
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func downloadDescription(url: URL, label: UILabel) {
        print(url)
        DispatchQueue.main.async {
            var string = ""
            do {
                string = try String(contentsOf: url)
                label.text = string
            } catch {
                print("Error")
                label.text = "No description available."
            }
        }
    }
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSpaceX {
            if mission.rocket.rocket_id == "falconheavy" {
                return 4 + 3 + 1
            } else {
                return 4 + 1 + 1
            }
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var indexes = [Int]()

        if isSpaceX && mission.rocket.rocket_id == "falconheavy" {
            indexes = [0,1,2,3,4,5,6,7]
        } else {
            indexes = [0,1,2,10,10,3,4,5]
        }

        if indexPath.row == indexes[0] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailTitleCell", for: indexPath) as! MissionDetailTitleTableViewCell
            
            cell.missionNumberLabel.text = "#\(launch.id!)"
            
            let delimiter = "|"
            var missionName = launch.name.components(separatedBy: delimiter)
            missionName[1].remove(at: missionName[1].startIndex)
            cell.missionTitleLabel.text = missionName[1]
            
            var startDateString = ""
            var endDateString = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
            if let startDate = dateFormatter.date(from: launch.windowstart) {
                let localizedDateTime: String = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .medium)
                startDateString = localizedDateTime
            } else {
                startDateString = launch.net
            }
            
            if let endDate = dateFormatter.date(from: launch.windowend) {
                let localizedDateTime: String = DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .medium)
                endDateString = localizedDateTime
            } else {
                endDateString = launch.net
            }
            
            cell.missionStartWindowLabel.text = "\(startDateString) - \(endDateString)"
            
            return cell
            
        } else if indexPath.row == indexes[1] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailRocketCell", for: indexPath) as! MissionDetailRocketTableViewCell
            cell.rocketNameLabel.text = launch.rocket.name
            cell.rocketOwnerLabel.text = "\(launch.lsp.name!)  \(IsoCountryCodes.find(key: launch.lsp.countryCode).flag)"
            cell.rocketDescriptionLabel.text = "No information on that rocket, it must be brand new!"
            var string = ""
            do {
                string = try String(contentsOf: URL(string: rocketAPI.descriptionURL())!).replacingOccurrences(of: "\\n", with: "\n")
                cell.rocketDescriptionLabel.text = string
            } catch {
                print("Error")
                cell.rocketDescriptionLabel.text = "No description available for this rocket 🚀"
            }
                        
            if !downloaded {
                downloadImage(url: URL(string: rocketAPI.imageURL())!, imageView: cell.rocketImageView)
                downloaded = true
            }
            return cell
        } else if indexPath.row == indexes[2] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage1Cell", for: indexPath) as! MissionDetailStage1TableViewCell
            
            var reused: Bool = false
            
            cell.rocketCoreSerialLabel.text = "N/A"
            cell.rocketCoreReusedLabel.alpha = 0
            
            if isSpaceX {
                
                if mission.rocket.first_stage.cores[0].core_serial != nil {
                    cell.rocketCoreSerialLabel.text = mission.rocket.first_stage.cores[0].core_serial!
                }
                
                if mission.rocket.first_stage.cores[0].reused != nil {
                    reused = mission.rocket.first_stage.cores[0].reused!
                }
                
                if reused {
                    cell.rocketCoreReusedLabel.text = "Reused"
                    cell.rocketCoreReusedLabel.alpha = 1
                } else {
                    cell.rocketCoreReusedLabel.text = "New"
                    cell.rocketCoreReusedLabel.alpha = 1
                }
                
            }
            
            cell.rocketCoreReusedLabel.layer.borderColor = UIColor.white.cgColor
            cell.rocketCoreReusedLabel.layer.borderWidth = 0.5
            cell.rocketCoreReusedLabel.layer.cornerRadius = 10
            
            return cell
        } else if indexPath.row == indexes[3] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage1DCell", for: indexPath) as! MissionDetailStage1DTableViewCell
            
            cell.rocketCoreSerialLabel.text = mission.rocket.first_stage.cores[1].core_serial ?? "N/A"
            
            var reused: Bool?
            
            if mission.rocket.first_stage.cores[1].reused != nil {
                reused = mission.rocket.first_stage.cores[1].reused
            }
            
            if reused != nil {
                if reused! {
                    cell.rocketCoreReusedLabel.text = "Reused"
                } else {
                    cell.rocketCoreReusedLabel.text = "New"
                }
            } else {
                cell.rocketCoreReusedLabel.text = ""
                cell.rocketCoreReusedLabel.alpha = 0
            }
            
            cell.rocketCoreReusedLabel.layer.borderColor = UIColor.white.cgColor
            cell.rocketCoreReusedLabel.layer.borderWidth = 0.5
            cell.rocketCoreReusedLabel.layer.cornerRadius = 10
            
            return cell
        } else if indexPath.row == indexes[4] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage1DCell", for: indexPath) as! MissionDetailStage1DTableViewCell
            
            cell.rocketCoreSerialLabel.text = mission.rocket.first_stage.cores[2].core_serial ?? "N/A"
            
            var reused: Bool?
            
            if mission.rocket.first_stage.cores[2].reused != nil {
                reused = mission.rocket.first_stage.cores[2].reused
            }
            
            if reused != nil {
                if reused! {
                    cell.rocketCoreReusedLabel.text = "Reused"
                } else {
                    cell.rocketCoreReusedLabel.text = "New"
                }
            } else {
                cell.rocketCoreReusedLabel.text = ""
                cell.rocketCoreReusedLabel.alpha = 0
            }
            
            cell.rocketCoreReusedLabel.layer.borderColor = UIColor.white.cgColor
            cell.rocketCoreReusedLabel.layer.borderWidth = 0.5
            cell.rocketCoreReusedLabel.layer.cornerRadius = 10
            
            return cell
        } else if indexPath.row == indexes[5] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2Cell", for: indexPath) as! MissionDetailStage2TableViewCell
            
            if !launch.missions.isEmpty {
                cell.rocketCoreIdLabel.text = "\(launch.missions[0].name!) \(missionPayloadType.type())"
                cell.rocketCoreCustomersLabel.text = launch.missions[0].typeName
                cell.rocketCoreDescriptionLabel.text = launch.missions[0].description
            } else {
                cell.rocketCoreIdLabel.text = "N/A"
                cell.rocketCoreCustomersLabel.text = "N/A"
            }
            
            return cell
        } else if indexPath.row == indexes[6] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailLaunchCell", for: indexPath) as! MissionDetailLaunchTableViewCell
            
            let delimiter = ","
            var padName = launch.location.pads[0].name.components(separatedBy: delimiter)
            
            cell.launchSiteNameLabel.text = padName[0]
            cell.launchSiteNameLongLabel.text = launch.location.name
            
            let initialLocation = CLLocationCoordinate2D(latitude: launch.location.pads[0].latitude, longitude: launch.location.pads[0].longitude)
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion.init(center: initialLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            cell.launchSiteMapView.setRegion(coordinateRegion, animated: true)
            cell.launchSiteMapView.mapType = .hybrid
            
            return cell
        } else if indexPath.row == indexes[7] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailPressCell", for: indexPath) as! MissionDetailPressTableViewCell
            cell.pressButton.addTarget(self, action: #selector(openElseLink(sender:)), for: .touchUpInside)
            cell.youtubeButton.addTarget(self, action: #selector(openElseLink(sender:)), for: .touchUpInside)
            cell.redditButton.alpha = 0
            
            return cell
        }
        else { //Second cell of second stage
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2DCell", for: indexPath) as! MissionDetailStage2DTableViewCell
            
            cell.rocketCoreIdLabel.text = "N/A"
            cell.rocketCoreCustomersLabel.text = "N/A"
            
            return cell
        }
    }
    
    //MARK: Links
    
    @objc func openLink(sender: UIButton) {
        
        if sender.tag == 100 {
            if mission.links.presskit != nil {
                let vc = SFSafariViewController(url: URL(string: mission.links.presskit!)!)
                present(vc, animated: true, completion: nil)
            } else {
                let alertController = CFAlertViewController(title: "Oops !", message: "No Press Kit is available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            }
        } else if sender.tag == 101 {
            if mission.links.video_link != nil {
                let vc = SFSafariViewController(url: URL(string: mission.links.video_link!)!)
                present(vc, animated: true, completion: nil)
            } else {
                let alertController = CFAlertViewController(title: "Oops !", message: "No video is available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            }
        } else if sender.tag == 102 {
            if mission.links.reddit_campaign != nil {
                let vc = SFSafariViewController(url: URL(string: mission.links.reddit_campaign!)!)
                present(vc, animated: true, completion: nil)
            } else {
                let alertController = CFAlertViewController(title: "Oops !", message: "The Reddit campaign is not available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func openElseLink(sender: UIButton) {
        
        if sender.tag == 100 {
            if launch.infoURLs.count == 0 || launch.infoURLs.isEmpty {
                let alertController = CFAlertViewController(title: "Oops !", message: "No article is available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            } else {
                let vc = SFSafariViewController(url: URL(string: launch.infoURLs[0])!)
                present(vc, animated: true, completion: nil)
            }
        } else if sender.tag == 101 {
            if launch.vidURLs.count == 0 || launch.vidURLs.isEmpty {
                let alertController = CFAlertViewController(title: "Oops !", message: "No video is available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            } else {
                let vc = SFSafariViewController(url: URL(string: launch.vidURLs[0])!)
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: IBAction
    
    @IBAction func addToCalendar(_ sender: UIButton) {
        
        let eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(String(describing: launch.id))")
        
        if eventAdded {
            calendarButton.imageView?.image = #imageLiteral(resourceName: "Calendar-Done")
        } else {
            calendarButton.imageView?.image = #imageLiteral(resourceName: "Calendar")
            checkCalendarAuthorization()
        }
        
    }
    
    @IBAction func openMap(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
        LaunchpadsViewController().isComingFromLaunch = true
//        LaunchpadsViewController().moveMap(latitude: launch.location.pads[0].latitude, longitude: launch.location.pads[0].longitude)
    }
    
    //MARK: BulletinBoard

    func prepareForBulletin() {
        
        // Register notification observers
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupDidComplete),
                                               name: .SetupDidComplete,
                                               object: nil)
        
        if !BulletinDataSource.userDidCompleteSetupCalendar {
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
        BulletinDataSource.userDidCompleteSetupCalendar = true
    }
    
    func makeCalendarPage() -> FeedbackPageBulletinItem {
        let page = FeedbackPageBulletinItem(title: "Calendar")
        page.image = #imageLiteral(resourceName: "Calendar-BB")
        
        page.descriptionText = "Add launches to calendar."
        page.actionButtonTitle = "Prepare for Liftoff"
        page.alternativeButtonTitle = "Not now"
        
        page.isDismissable = false
        
        page.appearance.actionButtonColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        page.appearance.alternativeButtonTitleColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        
        page.actionHandler = { item in
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event, completion: { (accessGranted, error) in
                
                DispatchQueue.main.async {
                    
                    item.manager?.dismissBulletin(animated: true)
                    self.checkCalendarAuthorization()
                }
            })
        }
        
        page.alternativeHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
    }
    
    //MARK: EventKit
    
    func checkCalendarAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)

        print(status.rawValue)
        
        switch status {
        case .notDetermined:
            prepareForBulletin()
        case .authorized:
            print("Calendar Authorized")
            var eventAdded: Bool!
            if isSpaceX {
                eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(mission.flight_number)")
                if eventAdded == nil || !eventAdded {
                    insertEvent()
                }
            } else {
                eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(String(describing: launch.id))")
                if eventAdded == nil || !eventAdded {
                    insertEvent()
                }
            }
        case .restricted, .denied:
            let alertController = CFAlertViewController(title: "Oops !", message: "You didn't authorize us to access your calendar. Do you want to give us access in the Settings ?", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
            let settingsAction = CFAlertAction(title: "Open Settings", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white) { (action) in
                let openSettingsURL = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(openSettingsURL!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            let cancelAction = CFAlertAction(title: "Cancel", style: .Cancel, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        @unknown default:
            break;
        }
    }
    
    func insertEvent() {
        
        var startDate: Date!
        var endDate: Date!
        
        if isSpaceX {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

            let startDateString = mission.launch_date_local
            startDate = dateFormatter.date(from: startDateString)
            endDate = startDate?.addingTimeInterval(3600)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
            
            let startDateString = launch.net
            startDate = dateFormatter.date(from: startDateString!)
            endDate = startDate.addingTimeInterval(3600)
        }
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            print("Access requested, granted :", granted)
            
            if granted {

                let event = EKEvent(eventStore: self.eventStore)
                
                if self.isSpaceX {
                    event.title = self.mission.mission_name
                    event.startDate = startDate!
                    event.endDate = endDate!
                    event.calendar = self.eventStore.defaultCalendarForNewEvents
                } else {
                    event.title = self.launch.name
                    event.startDate = startDate!
                    event.endDate = endDate!
                    event.calendar = self.eventStore.defaultCalendarForNewEvents
                }
                
                do {
                    print("Saved")
                    try self.eventStore.save(event, span: .thisEvent)
                    
                    UserDefaults.standard.set(true, forKey: "EventAddedToCalendar_\(String(describing: self.launch.id))")
                    
                    DispatchQueue.main.async {
                        self.calendarButton.setImage(#imageLiteral(resourceName: "Calendar-Done"), for: .normal)

                  
                        let alertController = CFAlertViewController(title: "Event added !", message: "This launch was added to your calendar !", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                        let okAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        let alertController = CFAlertViewController(title: "Oops !", message: "Houston, we've have had a problem here. The event couldn't have been saved. Please check that you authorized Rockety to access your calendar.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                        let okAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    //MARK: UIGestureRecognizer
    
    @objc func back(sender: UISwipeGestureRecognizer) {
        if isComingFromAgency {
            performSegue(withIdentifier: "returnAgencyMission", sender: self)
        } else {
            performSegue(withIdentifier: "returnMissionsWithSegue", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
