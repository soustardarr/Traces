//
//  MainViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import MapKit
import FirebaseAuth
import Combine


protocol MainViewModelDelegate: AnyObject {
    func didUpdateRegion(_ region: MKCoordinateRegion)
    func didFailWithError(_ error: Error)
//    func showLocationErrorVC()
}

class MainViewModel: NSObject {

    // MARK: - Stored prop

//    var locationManager = CLLocationManager()
    var locationManager = LocationManager.shared.locationManager

    weak var delegate: MainViewModelDelegate?
    
    var regionUser: MKCoordinateRegion? {
        didSet {
            getUserRegion?(regionUser)
        }
    }

    var getUserRegion: ((MKCoordinateRegion?) -> ())?

    func realTimeRegion() {
        guard let location = locationManager.location else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        regionUser = region
    }

    // MARK: - Methods
    override init() {
        super.init()
//        LocationManager.shared.createManager()
        locationManager.delegate = self
        requestLocation()
    }
    private func requestLocation() {
        let authorizationStatus = locationManager.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
//            delegate?.showLocationErrorVC()
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }

}

// MARK: - Delegates

extension MainViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard FirebaseAuth.Auth.auth().currentUser != nil else { return }

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locations.last {
                RealTimeDataBaseManager.shared.setLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                RealTimeDataBaseManager.shared.setRoute(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        case .denied, .restricted:
//            self.requestLocation()
            //                delegate?.showLocationErrorVC()
            // Пользователь запретил использование местоположения, продолжаем запрашивать разрешение
            print("fdsfsdfdsfds")
        case .notDetermined:
//            self.requestLocation()
            print("fdsfsdfdsfds")

        @unknown default:
//            self.requestLocation()
            print("fdsfsdfdsfds")

        }


    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let location = manager.location else { return }
        let authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse:
            self.requestLocation()
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.delegate?.didUpdateRegion(region)
        case .authorizedAlways:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.delegate?.didUpdateRegion(region)
        case .denied, .restricted:
            self.requestLocation()
            //                delegate?.showLocationErrorVC()
            // Пользователь запретил использование местоположения, продолжаем запрашивать разрешение
        case .notDetermined:
            self.requestLocation()
        @unknown default:
            self.requestLocation()
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.didFailWithError(error)
    }

}
