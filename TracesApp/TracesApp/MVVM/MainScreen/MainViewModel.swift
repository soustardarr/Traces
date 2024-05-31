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
}

class MainViewModel: NSObject {

    // MARK: - Stored prop

    var locationManager: CLLocationManager?
    weak var delegate: MainViewModelDelegate?
    
    var regionUser: MKCoordinateRegion? {
        didSet {
            getUserRegion?(regionUser)
        }
    }

    var getUserRegion: ((MKCoordinateRegion?) -> ())?

    func realTimeRegion() {
        guard let location = locationManager?.location else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        regionUser = region
    }

    // MARK: - Methods
    override init() {
        super.init()
        setupSettings()
    }

    private func setupSettings() {

        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self

        let authorizationStatus = self.locationManager?.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
//            self.locationManager?.requestAlwaysAuthorization()
            self.locationManager?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            self.locationManager?.requestAlwaysAuthorization()
            self.locationManager?.allowsBackgroundLocationUpdates = true
            self.locationManager?.startUpdatingLocation()
        case .authorizedAlways:
            self.locationManager?.allowsBackgroundLocationUpdates = true
            self.locationManager?.startUpdatingLocation()
        default:
            // Пользователь запретил использование местоположения
            print("Location permissions denied.")
        }
    }
}

// MARK: - Delegates

extension MainViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard FirebaseAuth.Auth.auth().currentUser != nil else { return }
        
        if let location = locations.last {
            RealTimeDataBaseManager.shared.setLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            RealTimeDataBaseManager.shared.setRoute(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }

    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationAuthorization()

        guard let location = manager.location else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.delegate?.didUpdateRegion(region)
        case .denied:
            print("")
        case .notDetermined, .restricted:
            print("")
        default:
            print("")

        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.didFailWithError(error)
    }

}



//    private func checkLocationAuthorization() {
//        guard let locationManager = locationManager,
//              let location = locationManager.location else { return }
//        switch locationManager.authorizationStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//            self.delegate?.didUpdateRegion(region)
//        case .denied:
//            print("")
//        case .notDetermined, .restricted:
//            print("")
//        default:
//            print("")
//
//        }
//
//    }

//    private func setupSettings() {
//
//        self.locationManager = CLLocationManager()
//        self.locationManager?.delegate = self
//
//        // Проверяем статус авторизации перед запросом
//        let authorizationStatus = self.locationManager?.authorizationStatus
//        switch authorizationStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            self.locationManager?.allowsBackgroundLocationUpdates = true
//            self.locationManager?.startUpdatingLocation()
////            self.locationManager?.startMonitoringSignificantLocationChanges()
//        case .notDetermined:
//            // Запрашиваем разрешение
//            self.locationManager?.requestAlwaysAuthorization()
//            self.locationManager?.requestWhenInUseAuthorization()
//        default:
//            // Пользователь запретил использование местоположения
//            print("Location permissions denied.")
//        }
//    }
