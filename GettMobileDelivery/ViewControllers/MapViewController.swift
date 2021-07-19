//
//  MapViewController.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    //MARK: params
    
    let locationManager = CLLocationManager()
    var destinationsVM: DestinationViewModel?
    var initialLocation: CLLocation?
    let deaultZoom: Float = 16
    var shouldNavigateToPickup = false
    
    var defaultStartingLocationForSimulator = CLLocation(latitude: 32.064603005741484, longitude: 34.7717155846415)
    @IBOutlet weak var deliveryInformationView: DeliveryDetailsView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var ArrivedButton: UIButton!
    
    //MARK: Methoods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        configureMap()
        //tracking the location only to navigate to the pickup point
        shouldNavigateToPickup = self.destinationsVM == nil
        if  shouldNavigateToPickup {
            locationManager.delegate = self
            let launchView = LaunchView(frame: self.view.bounds)
            addLounchView(launchView)
            setOnFirstNavigation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDeliveryDetails()
    }
    
    private func configureMap() {
        if let location = getLocationFromData() {
            setPathForDevice(from: location)
            let latitude: CLLocationDegrees = location.coordinate.latitude
            let longitude: CLLocationDegrees  = location.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: deaultZoom)
            mapView.camera = camera
        }
        mapView.mapType = .terrain
        self.mapView.bringSubviewToFront(ArrivedButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let deliveryDetailsViewViewController = segue.destination as? DeliveryDetailsViewViewController,
              let destinationsVM = self.destinationsVM else { return }
        deliveryDetailsViewViewController.destinationsVM = destinationsVM
        if shouldNavigateToPickup {
            deliveryDetailsViewViewController.type = ResourceHelper.pickupType
        }
    }
    
    //MARK: configuration helpers
    
    private func setOnFirstNavigation() {
        setLocationManager()
        readDestinations()
    }
    
    private func setDeliveryDetails() {
        if let destinationsVM = self.destinationsVM ,let destination = destinationsVM.getDestination(at: 0) {
            self.deliveryInformationView.addressLabel.text = destinationsVM.getDestinationAddress(destination)
            self.deliveryInformationView.statusLabel.text = destinationsVM.getDestinationType(destination)
        }
    }
    
    private func setLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
                break
            case .denied, .restricted:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            @unknown default:
            fatalError()
        }
    }
    
    /*
     self.destinationsVM will be nil on app launch
     since map is configured before getting the destinations from json
     */
    private func getLocationFromData() -> CLLocation? {
        if let destinationsVM = self.destinationsVM, !destinationsVM.isEmpty(),
           let destination = destinationsVM.getDestination(at: 0) {
            let location = destinationsVM.getDestinationGeo(destination)
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    private func readDestinations() {
        Service.shared.getDirections { [weak self] destinations,response,error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let destinations = destinations {
                if let self = self {
                    self.destinationsVM = DestinationViewModel(destinations)
                    DispatchQueue.main.async {
                        /* only for simulator since shouldNavigateToPickup is true  */
                        self.setPathForDevice(from: self.defaultStartingLocationForSimulator)
                    }
                }
            }
        }
    }
    
    private func drawPath(from location: CLLocation) {
        if self.destinationsVM != nil {
            initialLocation = location
            createMarker(for: location)
            if !self.destinationsVM!.isEmpty(),
               let nextPoint = shouldNavigateToPickup ? self.destinationsVM!.getDestination(at: 0) : self.destinationsVM!.popNextDestination() {
                let nextLocation = self.destinationsVM!.getDestinationGeo(nextPoint)
                createMarker(for: nextLocation)
                self.drawPath(from: location.coordinate, to: nextLocation.coordinate)
            }
            
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: deaultZoom)
            mapView.camera = camera
        }
    }
    
    //MARK: Helper methods
    
    private func setPathForDevice(from location: CLLocation) {
        #if targetEnvironment(simulator)
          drawPath(from: location)
        #else
        if !shouldNavigateToPickup {
            drawPath(from: location)
        }
        #endif
    }
    
    private func createMarker(for location: CLLocation) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
    }
    
    func drawPath(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        Service.shared.fetchRoute(from: from, to: to) { [weak self] route, error in
            if let error = error {
                print("\(error.localizedDescription) -> \(error)")
            } else {
                if let route = route, let self = self {
                    DispatchQueue.main.async {
                        let path = GMSPath(fromEncodedPath: route)
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 5.0
                        polyline.strokeColor = .darkGray
                        polyline.map = self.mapView
                        if let launchView = self.topMostView as? LaunchView {
                            self.removeLounchView(launchView)
                        }
                    }
                }
            }
        }
    }
    
    private func addLounchView(_ subview: UIView) {
        UIView.transition(with: self.view, duration: 1, options: [.transitionCrossDissolve], animations: {
          self.view.addSubview(subview)
        }, completion: nil)
    }
    
    private func removeLounchView(_ subview: UIView) {
        UIView.transition(with: self.view, duration: 1, options: [.transitionCrossDissolve], animations: {
          subview.removeFromSuperview()
        }, completion: nil)
    }
}

//MARK: CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    var topMostView: UIView? {
        return view.subviews.last
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first {
            drawPath(from: location)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        if let  launchView = topMostView as? LaunchView {
            removeLounchView(launchView)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            guard let launchView =  topMostView as? LaunchView else { return }
            self.removeLounchView(launchView)
            manager.startUpdatingLocation()
        }
    }
}

