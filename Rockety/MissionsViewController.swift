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

class MissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var missions = [Mission]()
    var rocket = [Int: Rocket]()
    var launchpads = [Launchpad]()

    let refreshControl = UIRefreshControl()
    
    lazy var bulletinManager: BulletinManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BulletinManager(rootItem: introPage)
    }()

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
        
        let w = view.frame.width
        let s = PinterestSegment(frame: CGRect(x: 0, y: 100, width: w - 100, height: 35), titles: ["S P A C E X", "N A S A"])
        s.style.titleFont = UIFont(name: "Anurati-Regular", size: 14)!
        view.addSubview(s)
        
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
    
    @objc func downloadSpaceX() {
        
        var nextMission = 0
        
        Alamofire.request("https://api.spacexdata.com/v2/launches/all").responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedMissions = try! decoder.decode([Mission].self, from: data)
                self.missions = decodedMissions
                
                for mission in decodedMissions {
                    self.downloadLaunchpadData(lauchpadId: mission.launch_site.site_id)
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
                self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.middle, animated: true)
            }
        }
    }
    
    func downloadRocketData(rocketId: String, missionNumber: Int) {
        Alamofire.request("https://api.spacexdata.com/v2/rockets/\(rocketId)").responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedRocket = try! decoder.decode(Rocket.self, from: data)
                self.rocket[missionNumber] = decodedRocket
            }
        }
    }
    
    func downloadLaunchpadData(lauchpadId: String) {
        Alamofire.request("https://api.spacexdata.com/v2/launchpads/\(lauchpadId)").responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedLaunchpad = try! decoder.decode(Launchpad.self, from: data)
                self.launchpads.append(decodedLaunchpad)
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
            
//            DispatchQueue.main.async() {
//                imageView.image = UIImage(data: data)
//            }
        }
    }
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as! MissionTableViewCell
        let mission = missions[indexPath.row]
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
            print("Localised DateTime")
        } else {
            cell.missionDateLabel.text = mission.launch_date_local
            print("LaunchDateLocal")
        }
        
        if mission.links.mission_patch != nil {

//            cell.missionPatchImageView.af_setImage(withURL: URL(string: mission.links.mission_patch!)!, placeholderImage: UIImage(named: "SpaceX"), filter: nil, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false) { response in
//                if response.response != nil {
//                    self.tableView.beginUpdates()
//                    self.tableView.endUpdates()
//                }
//            }
            
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
                destVC.mission = missions[indexPath.row]
                destVC.rocket = rocket[missions[indexPath.row].flight_number]
                destVC.launchpad = launchpads[indexPath.row]
            }
        }
    }
    
    @IBAction func returnMissions(segue: UIStoryboardSegue) {
        
    }


}

