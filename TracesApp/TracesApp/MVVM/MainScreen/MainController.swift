//
//  MainController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit
import MapKit
import SwiftUI

class MainController: UIViewController {

    weak var mainControllerCoordinator: MainControllerCoordinator?
    private var mainView: MainView?
    private var mainViewModel: MainViewModel?
    private var userRegion: MKCoordinateRegion?
    private var profile: User?
    private var profileAnnotationView: AnnotationView?
    private var deepLinkVC: UIViewController?

    init(deepLinkVC: UIViewController) {
        self.deepLinkVC = deepLinkVC
        super.init(nibName: nil, bundle: nil)
    }
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSettings()
        obtainProfile()
        obtainAndShowFriends()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView?.mapView.setUserTrackingMode(.follow, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let vc = deepLinkVC {
            present(vc, animated: true)
        }
    }
    private func setupSettings() {
        mainView = MainView()
        view = mainView
        mainView?.delegate = self
        mainView?.mapView.delegate = self
        mainViewModel = MainViewModel()
        mainViewModel?.delegate = self
    }

    private func obtainProfile() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("Не удалось получить emil из UserDefaults, он ПУСТ")
            return
        }
        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        DispatchQueue.global(qos: .default).async {
            RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: safeEmail) { result in
                switch result {
                case .success(let user):
                    doInMainThread {
                        self.profile = user
                        self.profileAnnotationView = AnnotationView(name: user.name, image: user.profilePicture ?? Data())
                        // тут нужно обновить анотациб пользователя
                    }
                case .failure(let error):
                    print("ошибка получения профиля для MainVC \(error)")
                }
            }
        }
    }

    private var friendAnnotations = [String: UserAnnotation]()

    private func obtainAndShowFriends() {
        FriendsLocationAndChatManager.shared.locationUpdateForActiveUser = { friend in
            if let location = friend.location,
               let latitude = location["latitude"],
               let longitude = location["longitude"] {
                print("\(latitude), \(longitude) \(friend.safeEmail)")

                if let existingAnnotation = self.friendAnnotations[friend.name]?.pointAnnotation {
                    // Если аннотация уже существует, обновляем её координаты
                    existingAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                } else {
                    // Если аннотации еще нет, создаем новую и добавляем в словарь
                    let annotation = MKPointAnnotation()
                    let userAnnotation = UserAnnotation(name: friend.name, profilePicture: friend.profilePicture ?? Data(), pointAnnotation: annotation)
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = friend.name
                    self.mainView?.mapView.addAnnotation(annotation)
                    self.friendAnnotations[friend.name] = userAnnotation
                }
            }
        }

    }

}


extension MainController: MainViewDelegate {

    func didTappedButtonProfile() {
        let profileVC = ProfileController(user: profile ?? User(name: "", email: ""))
        self.present(profileVC, animated: true)
    }

    func didTappedButtonLocation() {
        mainViewModel?.realTimeRegion()
        mainView?.mapView.setRegion(userRegion ?? MKCoordinateRegion(), animated: true)
        mainView?.mapView.setUserTrackingMode(.follow, animated: true)
    }

    func didTappedButtonFriends() {
        let vc = FriendsController()
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }

    func didTappedButtonSettings() { }

    func didTappedButtonWorld() { }

    
    func didTappedButtonMessages() {
        let chatController = UIHostingController(rootView: ChatSUIView())
        present(chatController, animated: true)
    }
}



extension MainController: MainViewModelDelegate {
    func didUpdateRegion(_ region: MKCoordinateRegion) {
        mainView?.mapView.setRegion(region, animated: true)
    }
    
    func didFailWithError(_ error: any Error) {
        print(error)
    }
}


extension MainController: MKMapViewDelegate {

    func getDistance() -> [String: CLLocationDistance] {
        let visibleRegion = mainView?.mapView.visibleMapRect
        // Получаем координаты углов видимой области карты
        let topLeftCoordinate = MKMapPoint(x: visibleRegion?.minX ?? 0, y: visibleRegion?.minY ?? 0).coordinate
        let bottomRightCoordinate = MKMapPoint(x: visibleRegion?.maxX ?? 0, y: visibleRegion?.maxY ?? 0).coordinate
        // Вычисляем расстояние между углами видимой области карты (по вертикали и горизонтали)
        let horizontalDistance = CLLocation(latitude: topLeftCoordinate.latitude, longitude: topLeftCoordinate.longitude)
            .distance(from: CLLocation(latitude: topLeftCoordinate.latitude, longitude: bottomRightCoordinate.longitude))
        let verticalDistance = CLLocation(latitude: topLeftCoordinate.latitude, longitude: topLeftCoordinate.longitude)
            .distance(from: CLLocation(latitude: bottomRightCoordinate.latitude, longitude: bottomRightCoordinate.longitude))

        let dict = [
            "horizontalDistance": horizontalDistance,
            "verticalDistance": verticalDistance
        ]
        return dict
    }

    func setWeather(latitude: Double, longitude: Double) {
        Task {
            do {
                let weather = try await WeatherManager.shared.obtainWeather(latitude: latitude, longitude: longitude)
                self.mainView?.weatherLabel.text = "\(weather?.currentWeather.temperature.description ?? "")℃" + " ветер: \(weather?.currentWeather.windspeed.description ?? "0") м/с"
            } catch(let error) {
                print("не удалось получить погоду: \(error)")
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let horizontalDistanceCity: Double = 17746
        let verticalDistanceCity: Double = 37545
        let horizontalDistanceCounty: Double = 1336802
        let verticalDistanceCounty: Double = 4875803
        let dict = self.getDistance()
        let hDistance = dict["horizontalDistance"]
        let vDistance = dict["verticalDistance"]

        let centerCoordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first else {
                print("Не удалось получить информацию о местоположении.")
                return
            }
            if hDistance ?? 0 < horizontalDistanceCity,
               vDistance ?? 0 < verticalDistanceCity {
                guard let place = placemark.locality else { return }
                if place != self.mainView?.locationLabel.text {
                    self.mainView?.locationLabel.text = place
                    self.setWeather(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                }
//                self.setWeather(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
            } else if hDistance ?? 0 > horizontalDistanceCity,
                      vDistance ?? 0 > verticalDistanceCity,
                      hDistance ?? 0 < horizontalDistanceCounty,
                      vDistance ?? 0 < verticalDistanceCounty {
                guard let place = placemark.administrativeArea else { return }
                if place != self.mainView?.locationLabel.text {
                    self.mainView?.locationLabel.text = place
                    self.setWeather(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                }
//                self.setWeather(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
            } else if hDistance ?? 0 > horizontalDistanceCounty,
                      vDistance ?? 0 > verticalDistanceCounty,
                      let county = placemark.country {
                self.mainView?.locationLabel.text = county
                self.mainView?.weatherLabel.text = ""
            }

        }
    }




    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "UserLocation")
            let profileAnnotationViewOptional = AnnotationView(name: profile?.name ?? "", image: profile?.profilePicture ?? Data())
            annotationView.addSubview(profileAnnotationView ?? profileAnnotationViewOptional)
            return annotationView
        }

        // Проверяем, является ли аннотация вашей кастомной аннотацией
        if let friendAnnotation = annotation as? MKPointAnnotation {
            let identifier = "FriendAnnotation"
            var annotationView: MKAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                // Если представление аннотации уже существует, используем его
                dequeuedView.annotation = annotation
                annotationView = dequeuedView
            } else {
                // Создаем новое кастомное представление для аннотации друга
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                let annotationInfo: UserAnnotation?
                if let name = annotationView.annotation?.title {
                    annotationInfo = friendAnnotations[name ?? ""]
                    let profileAnnotationView = AnnotationView(name: annotationInfo?.name ?? "", image: annotationInfo?.profilePicture ?? Data())
                    annotationView.addSubview(profileAnnotationView)
                    return annotationView
                } else {
                    annotationView.image = .add
                }
            }

            return annotationView
        }

        return nil
    }

}
