//
//  LaunchpadsViewController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 11.06.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class LaunchpadsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var isComingFromLaunch = false
    
    var pads = [PadResult.Pad]()
    var launchpads = [Pad]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if mapView.mapType == .satellite {
            segmentedControl.tintColor = UIColor.white
        } else {
            segmentedControl.tintColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        }
        
        downloadPads()
        setupMap()
        
        print(isComingFromLaunch)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: MKMapView
    
    func setupMap() {
        
        mapView.delegate = self
        mapView.mapType = .standard
        
        let initialLocation = CLLocation(latitude: 28.530880, longitude: -80.564562)
        let regionRadius: CLLocationDistance = 1000000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func moveMap(latitude: Double, longitude: Double) {
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: Data
    
    func downloadPads() {
        Alamofire.request(API.All.pads.url()).responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                let decodedPads = try! decoder.decode(PadResult.self, from: data)
                self.pads = decodedPads.pads
                
                for pad in decodedPads.pads {
                    if (pad.latitude != nil) && (pad.longitude != nil) {
                        let launchpad = Pad(title: pad.name, padType: pad.padType, coordinate: CLLocationCoordinate2D(latitude: Double(pad.latitude)!, longitude: Double(pad.longitude)!))
                        self.launchpads.append(launchpad)
                        self.mapView.addAnnotation(launchpad)
                    }
                }
            }
        }
    }
    
    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Pad else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.glyphImage = #imageLiteral(resourceName: "Rocket")
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }
        
        return view
    }
    
    //MARK: IBAction
    
    @IBAction func segmentedDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
            segmentedControl.tintColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        } else {
            mapView.mapType = .satellite
            segmentedControl.tintColor = UIColor.white
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
