//
//  LaunchpadsViewController.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 03.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import UIKit

class LaunchpadsViewController: BaseViewController {
    // - Properties
    private let viewModel: LaunchpadsViewModelType = LaunchpadsViewModel()
    private var annotations: [PadAnnotation] = []

    // - Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var segmentedControl: UISegmentedControl!
}

// MARK: - View Lifecycle

extension LaunchpadsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        setupUI()
        setupRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.inputs.viewWillAppear()
    }
}

// MARK: - Private methods

extension LaunchpadsViewController {
    private func setupMap() {
        mapView.delegate = self
        mapView.mapType = .standard

        let initialLocation = CLLocation(latitude: 28.530880, longitude: -80.564562)
        let regionRadius: CLLocationDistance = 1000000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    private func setupUI() {
        if mapView.mapType == .satellite {
            segmentedControl.tintColor = UIColor.white
        } else {
            segmentedControl.tintColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        }
    }

    private func setupRx() {
        // Launchpads
        viewModel.outputs.launchpads
            .asObservable()
            .unwrap()
            .bind { [unowned self] launchpads in
                self.addMarkets(launchpads: launchpads)
            }
            .disposed(by: disposeBag)

        // Segmented Control
        segmentedControl.rx.controlEvent(.valueChanged)
            .asObservable()
            .bind { [unowned self] value in
                if segmentedControl.selectedSegmentIndex == 0 {
                    mapView.mapType = .standard
                    segmentedControl.tintColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
                } else {
                    mapView.mapType = .satellite
                    segmentedControl.tintColor = UIColor.white
                }
            }
            .disposed(by: disposeBag)
    }

    private func addMarkets(launchpads: Launchpads) {
        for launchpad in launchpads.results {
            let launchpadAnnotation = PadAnnotation(pad: launchpad)
            if !annotations.contains(launchpadAnnotation) {
                mapView.addAnnotation(launchpadAnnotation)
                annotations.append(launchpadAnnotation)
            }
        }
    }
}

// MARK: - MKMapViewDelegate

extension LaunchpadsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PadAnnotation else { return nil }

        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.markerTintColor = UIColor(named: "Background")
            view.glyphImage = UIImage(named: "launchpad")!
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }

        return view
    }
}
