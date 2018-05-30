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
import BulletinBoard
import EventKit
import Crashlytics

class MissionsDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var isSpaceX: Bool!
    
    var mission: Mission!
    var rocket: Rocket!
    var launchpad: Launchpad!
    
    var launch: ElseMission.Launch!
    var rocketURL: API.Images = .none
    
    lazy var bulletinManager: BulletinManager = {
        let calendarPage = BulletinDataSource.makeCalendarPage()
        return BulletinManager(rootItem: calendarPage)
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
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if !isSpaceX {
            if launch.rocket.name == "Falcon 1 Merlin A" || launch.rocket.name == "Falcon 1 Merlin C" {
                rocketURL = .falcon1
            } else if launch.rocket.name == "Falcon 9 Full Thrust" || launch.rocket.name == "Falcon 9 FT" || launch.rocket.name == "Falcon 9 v1.0" || launch.rocket.name == "Falcon 9 v1.1" {
                rocketURL = .falcon9
            } else if launch.rocket.name == "Falcon Heavy" {
                rocketURL = .falconheavy
            } else if launch.rocket.name == "Long March 2C/SMA" {
                rocketURL = .longmarch2c
            } else if launch.rocket.name == "Long March 3A" {
                rocketURL = .longmarch3a
            } else if launch.rocket.name == "Long March 3B" {
                rocketURL = .longmarch3b
            } else if launch.rocket.name == "GSLV Mk III" {
                rocketURL = .gslvmkiii
            } else if launch.rocket.name == "Ariane 5" || launch.rocket.name == "Ariane 5 ECA" || launch.rocket.name == "Ariane 5 ES" {
                rocketURL = .ariane5
            } else if launch.rocket.name == "Ariane 6" {
                rocketURL = .ariane6
            } else if launch.rocket.name == "Soyuz" || launch.rocket.name == "Soyuz-FG" {
                rocketURL = .soyuz
            } else if launch.rocket.name == "Vega" {
                rocketURL = .vega
            } else if launch.rocket.name == "Vega-C" {
                rocketURL = .vegac
            }
        }
        
        if isSpaceX {
            let rocketName = "\(mission.rocket.rocket_name) \(mission.rocket.rocket_type)"
            print(rocketName)
            if rocketName == "Falcon 1 Merlin A" || rocketName == "Falcon 1 Merlin C" {
                rocketURL = .falcon1
            } else if rocketName == "Falcon 9 Full Thrust" || rocketName == "Falcon 9 FT" || rocketName == "Falcon 9 v1.0" || rocketName == "Falcon 9 v1.1" {
                rocketURL = .falcon9
            } else if rocketName == "Falcon Heavy" {
                rocketURL = .falconheavy
            }
        }
        
        var eventAdded: Bool!
        if isSpaceX {
            eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(mission.flight_number)")
        } else {
            eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(launch.id)")
        }
        
        if eventAdded {
            calendarButton.alpha = 0
        }
        
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(back(sender:)))
        gestureRecognizer.direction = .right
        self.view.addGestureRecognizer(gestureRecognizer)
        
        //Fabric
        var attributes:[String:String] = [:]
        if isSpaceX {
            attributes = ["rocketName": mission.rocket.rocket_name, "mission": mission.mission_name]
        } else {
            attributes = ["rocketName": launch.rocket.name, "mission": launch.name]
        }
        Answers.logCustomEvent(withName: "Rocket", customAttributes: attributes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Image
    
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
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSpaceX {
            if rocket.id == "falconheavy" {
                return 4 + 3 + mission.rocket.second_stage.payloads.count
            } else {
                return 4 + 1 + mission.rocket.second_stage.payloads.count
            }
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isSpaceX {
            
            if rocket.id == "falconheavy" {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailTitleCell", for: indexPath) as! MissionDetailTitleTableViewCell
                    cell.missionNumberLabel.text = "#\(mission.flight_number)"
                    cell.missionTitleLabel.text = mission.mission_name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    if let date = dateFormatter.date(from: mission.launch_date_local) {
                        let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                        cell.missionSubtitleLabel.text = localizedDateTime
                    } else {
                        cell.missionSubtitleLabel.text = mission.launch_date_local
                    }
                    
                    if mission.links.mission_patch != nil {
                        downloadImage(url: URL(string: mission.links.mission_patch!)!, imageView: cell.missionPatchImageView)
                    } else {
                        cell.missionPatchImageView.image = UIImage(named: "SpaceX")
                    }
                    return cell
                } else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailRocketCell", for: indexPath) as! MissionDetailRocketTableViewCell
                    cell.rocketNameLabel.text = mission.rocket.rocket_name + " " + mission.rocket.rocket_type
                    cell.rocketOwnerLabel.text = "SpaceX  🇺🇸"
                    cell.rocketDescriptionLabel.text = rocket.description
                    downloadImage(url: URL(string: API.Images.falconheavy.url())!, imageView: cell.rocketImageView)
                    return cell
                } else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage1Cell", for: indexPath) as! MissionDetailStage1TableViewCell
                    cell.rocketCoreSerialLabel.text = mission.rocket.first_stage.cores[0].core_serial ?? "N/A"
                    
                    var reused: Bool?
                    
                    if mission.rocket.first_stage.cores[0].reused != nil {
                        reused = mission.rocket.first_stage.cores[0].reused
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
                } else if indexPath.row == 3 {
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
                } else if indexPath.row == 4 {
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
                } else if indexPath.row == 5 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2Cell", for: indexPath) as! MissionDetailStage2TableViewCell
                    cell.rocketCoreIdLabel.text = "\(mission.rocket.second_stage.payloads[0].payload_id) (\(mission.rocket.second_stage.payloads[0].payload_type))"
                    
                    var customers = ""
                    var customerCount = 0
                    for customer in mission.rocket.second_stage.payloads[0].customers {
                        if customerCount != 0 {
                            customers = customers + " & \(customer)"
                        } else {
                            customers = "\(customer)"
                        }
                        customerCount = customerCount + 1
                    }
                    
                    cell.rocketCoreCustomersLabel.text = customers
                    
                    if mission.rocket.second_stage.payloads.count != 1 {
                        cell.separatorInset.left = 500
                        cell.separatorInset.right = 0
                    }
                    
                    return cell
                } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailLaunchCell", for: indexPath) as! MissionDetailLaunchTableViewCell
                    cell.launchSiteNameLabel.text = mission.launch_site.site_name
                    cell.launchSiteNameLongLabel.text = mission.launch_site.site_name_long
                    
                    let initialLocation = CLLocationCoordinate2D(latitude: launchpad.location.latitude, longitude: launchpad.location.longitude)
                    let regionRadius: CLLocationDistance = 1000
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius, regionRadius)
                    cell.launchSiteMapView.setRegion(coordinateRegion, animated: true)
                    cell.launchSiteMapView.mapType = .hybrid
                    
                    return cell
                } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailPressCell", for: indexPath) as! MissionDetailPressTableViewCell
                    cell.pressButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                    cell.youtubeButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                    cell.redditButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                    
                    return cell
                } else { //Second cell of second stage
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2DCell", for: indexPath) as! MissionDetailStage2DTableViewCell
                    cell.rocketCoreIdLabel.text = "\(mission.rocket.second_stage.payloads[1].payload_id) (\(mission.rocket.second_stage.payloads[1].payload_type))"
                    
                    var customers = ""
                    var customerCount = 0
                    for customer in mission.rocket.second_stage.payloads[1].customers {
                        if customerCount != 0 {
                            customers = customers + " & \(customer)"
                        } else {
                            customers = "\(customer)"
                        }
                        customerCount = customerCount + 1
                    }
                    
                    cell.rocketCoreCustomersLabel.text = customers
                    
                    return cell
                }
            } else {
                
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailTitleCell", for: indexPath) as! MissionDetailTitleTableViewCell
                    cell.missionNumberLabel.text = "#\(mission.flight_number)"
                    cell.missionTitleLabel.text = mission.mission_name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    if let date = dateFormatter.date(from: mission.launch_date_local) {
                        let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                        cell.missionSubtitleLabel.text = localizedDateTime
                    } else {
                        cell.missionSubtitleLabel.text = mission.launch_date_local
                    }
                    
                    if mission.links.mission_patch != nil {
                        downloadImage(url: URL(string: mission.links.mission_patch!)!, imageView: cell.missionPatchImageView)
                    } else {
                        cell.missionPatchImageView.image = UIImage(named: "SpaceX")
                    }
                    return cell
                } else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailRocketCell", for: indexPath) as! MissionDetailRocketTableViewCell
                    cell.rocketNameLabel.text = mission.rocket.rocket_name + " " + mission.rocket.rocket_type
                    cell.rocketOwnerLabel.text = "SpaceX  🇺🇸"
                    cell.rocketDescriptionLabel.text = rocket.description

                    downloadImage(url: URL(string: rocketURL.url())!, imageView: cell.rocketImageView)
                    return cell
                } else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage1Cell", for: indexPath) as! MissionDetailStage1TableViewCell
                    cell.rocketCoreSerialLabel.text = mission.rocket.first_stage.cores[0].core_serial ?? "N/A"
                    
                    var reused: Bool?
                    
                    if mission.rocket.first_stage.cores[0].reused != nil {
                        reused = mission.rocket.first_stage.cores[0].reused
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
                } else if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2Cell", for: indexPath) as! MissionDetailStage2TableViewCell
                    cell.rocketCoreIdLabel.text = "\(mission.rocket.second_stage.payloads[0].payload_id) (\(mission.rocket.second_stage.payloads[0].payload_type))"
                    
                    var customers = ""
                    var customerCount = 0
                    for customer in mission.rocket.second_stage.payloads[0].customers {
                        if customerCount != 0 {
                            customers = customers + " & \(customer)"
                        } else {
                            customers = "\(customer)"
                        }
                        customerCount = customerCount + 1
                    }
                    
                    cell.rocketCoreCustomersLabel.text = customers
                    
                    if mission.rocket.second_stage.payloads.count != 1 {
                        cell.separatorInset.left = 500
                        cell.separatorInset.right = 0
                    }
                    
                    return cell
                } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailLaunchCell", for: indexPath) as! MissionDetailLaunchTableViewCell
                    cell.launchSiteNameLabel.text = mission.launch_site.site_name
                    cell.launchSiteNameLongLabel.text = mission.launch_site.site_name_long
                    
                    let initialLocation = CLLocationCoordinate2D(latitude: launchpad.location.latitude, longitude: launchpad.location.longitude)
                    let regionRadius: CLLocationDistance = 1000
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius, regionRadius)
                    cell.launchSiteMapView.setRegion(coordinateRegion, animated: true)
                    cell.launchSiteMapView.mapType = .hybrid
                    
                    return cell
                } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailPressCell", for: indexPath) as! MissionDetailPressTableViewCell
                    cell.pressButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                    cell.youtubeButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                    cell.redditButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                    
                    return cell
                } else { //Second cell of second stage
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2DCell", for: indexPath) as! MissionDetailStage2DTableViewCell
                    cell.rocketCoreIdLabel.text = "\(mission.rocket.second_stage.payloads[1].payload_id) (\(mission.rocket.second_stage.payloads[1].payload_type))"
                    
                    var customers = ""
                    var customerCount = 0
                    for customer in mission.rocket.second_stage.payloads[1].customers {
                        if customerCount != 0 {
                            customers = customers + " & \(customer)"
                        } else {
                            customers = "\(customer)"
                        }
                        customerCount = customerCount + 1
                    }
                    
                    cell.rocketCoreCustomersLabel.text = customers
                    
                    return cell
                }
            }
            
        } else { //Else mission
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailTitleCell", for: indexPath) as! MissionDetailTitleTableViewCell
                
                cell.missionNumberLabel.text = "#\(launch.id!)"
                
                let delimiter = "|"
                var missionName = launch.name.components(separatedBy: delimiter)
                missionName[1].remove(at: missionName[1].startIndex)
                cell.missionTitleLabel.text = missionName[1]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss 'UTC'"
                if let date = dateFormatter.date(from: launch.net) {
                    let localizedDateTime: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium)
                    cell.missionSubtitleLabel.text = localizedDateTime
                } else {
                    cell.missionSubtitleLabel.text = launch.net
                }
                
                cell.missionPatchImageView.alpha = 0
                
                return cell

            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailRocketCell", for: indexPath) as! MissionDetailRocketTableViewCell
                cell.rocketNameLabel.text = launch.rocket.name
                cell.rocketOwnerLabel.text = "\(launch.lsp.name!)  \(IsoCountryCodes.find(key: launch.lsp.countryCode).flag)"
                cell.rocketDescriptionLabel.text = "Description"

                downloadImage(url: URL(string: rocketURL.url())!, imageView: cell.rocketImageView)
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage1Cell", for: indexPath) as! MissionDetailStage1TableViewCell
                cell.rocketCoreSerialLabel.text = "N/A"
            
                cell.rocketCoreReusedLabel.alpha = 0
                cell.rocketCoreReusedLabel.layer.borderColor = UIColor.white.cgColor
                cell.rocketCoreReusedLabel.layer.borderWidth = 0.5
                cell.rocketCoreReusedLabel.layer.cornerRadius = 10
                
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2Cell", for: indexPath) as! MissionDetailStage2TableViewCell

                if !launch.missions.isEmpty {
                    cell.rocketCoreIdLabel.text = "\(launch.missions[0].name!) (Satellite)"
                    cell.rocketCoreCustomersLabel.text = launch.missions[0].typeName
                } else {
                    cell.rocketCoreIdLabel.text = "N/A"
                    cell.rocketCoreCustomersLabel.text = "N/A"
                }
                
                return cell
            } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailLaunchCell", for: indexPath) as! MissionDetailLaunchTableViewCell
                
                let delimiter = ","
                var padName = launch.location.pads[0].name.components(separatedBy: delimiter)
                
                cell.launchSiteNameLabel.text = padName[0]
                cell.launchSiteNameLongLabel.text = launch.location.name
                
                let initialLocation = CLLocationCoordinate2D(latitude: launch.location.pads[0].latitude, longitude: launch.location.pads[0].longitude)
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius, regionRadius)
                cell.launchSiteMapView.setRegion(coordinateRegion, animated: true)
                cell.launchSiteMapView.mapType = .hybrid
                
                return cell
            } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailPressCell", for: indexPath) as! MissionDetailPressTableViewCell
                cell.pressButton.addTarget(self, action: #selector(openElseLink(sender:)), for: .touchUpInside)
                cell.youtubeButton.addTarget(self, action: #selector(openElseLink(sender:)), for: .touchUpInside)
                
//                cell.redditButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                cell.redditButton.alpha = 0
                
                return cell
            } else { //Second cell of second stage
                let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailStage2DCell", for: indexPath) as! MissionDetailStage2DTableViewCell
//                cell.rocketCoreIdLabel.text = "\(mission.rocket.second_stage.payloads[1].payload_id) (\(mission.rocket.second_stage.payloads[1].payload_type))"
//
//                var customers = ""
//                var customerCount = 0
//                for customer in mission.rocket.second_stage.payloads[1].customers {
//                    if customerCount != 0 {
//                        customers = customers + " & \(customer)"
//                    } else {
//                        customers = "\(customer)"
//                    }
//                    customerCount = customerCount + 1
//                }
//
//                cell.rocketCoreCustomersLabel.text = customers
                
                cell.rocketCoreIdLabel.text = "Payload"
                cell.rocketCoreCustomersLabel.text = "Customer"
                
                return cell
            }
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
            if launch.infoURLs.count == 0 {
                let alertController = CFAlertViewController(title: "Oops !", message: "No article is available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            } else {
                let vc = SFSafariViewController(url: URL(string: launch.infoURLs[0])!)
                present(vc, animated: true, completion: nil)
            }
        } else if sender.tag == 101 {
            if launch.vidURLs.count == 0 {
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
        checkCalendarAuthorization()
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
        
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    
    @objc func setupDidComplete() {
        BulletinDataSource.userDidCompleteSetup = true
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
            } else {
                eventAdded = UserDefaults.standard.bool(forKey: "EventAddedToCalendar_\(launch.id)")
            }
            print(eventAdded)
            if eventAdded == nil || !eventAdded {
                insertEvent()
            }
        case .restricted, .denied:
            let alertController = CFAlertViewController(title: "Oops !", message: "You didn't authorize us to access your calendar. Do you want to give us access in the Settings ?", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
            let settingsAction = CFAlertAction(title: "Open Settings", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white) { (action) in
                let openSettingsURL = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(openSettingsURL!, options: [:], completionHandler: nil)
            }
            let cancelAction = CFAlertAction(title: "Cancel", style: .Cancel, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
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
                    
                    if self.isSpaceX {
                        UserDefaults.standard.set(true, forKey: "EventAddedToCalendar_\(self.mission.flight_number)")
                    } else {
                        UserDefaults.standard.set(true, forKey: "EventAddedToCalendar_\(self.launch.id)")
                    }
                    
                    DispatchQueue.main.async {
                        self.calendarButton.alpha = 0                        
                  
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
        performSegue(withIdentifier: "returnMissionsWithSegue", sender: self)
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
