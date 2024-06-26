//
//  MainController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit
import MapKit
import SwiftUI
import Combine
import FittedSheets

class MainController: UIViewController {

    weak var mainControllerCoordinator: MainControllerCoordinator?
    private var mainView: MainView?
    private var mainViewModel: MainViewModel?
    private var userRegion: MKCoordinateRegion?
    private var profile: User?
    private var profileAnnotationView: AnnotationView?
    var deepLinkVC: UIViewController?
    private var friends: [User] = []
    var cancellable: Set<AnyCancellable> = []

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
        obtainActiveUser()
        obtainFriend()
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
        ObtainFriendManager.shared.setupFriendsEmailsObserver()
        let safeEmail = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: safeEmail) { [ weak self ] result in
            switch result {
            case .success(let user):
                doInMainThread {
                    self?.profile = user
                    self?.mainView?.mapView.annotations.forEach({ ann in
                        if ann is MKUserLocation {
                            self?.profileAnnotationView = AnnotationView(name: user.name, image: user.profilePicture ?? Data())
                            if let annotationView = self?.mainView?.mapView.view(for: ann) {
                                self?.updateUserAnnotationView(annotationView)
                            }
                        }
                    })
                }
            case .failure(let error):
                print("ошибка получения профиля для MainVC \(error)")
            }
        }

    }

    private func updateUserAnnotationView(_ annotationView: MKAnnotationView) {
        annotationView.subviews.forEach { $0.removeFromSuperview() }
        if let profileAnnotationView = self.profileAnnotationView {
            annotationView.addSubview(profileAnnotationView)
        }
    }


    private func obtainFriend() {
        ObtainFriendManager.shared.$generalFriends
            .sink { [ weak self ] users in
                guard let strongSelf = self else { return }
                guard let users = users else { return }
                if strongSelf.friends.isEmpty {
                    strongSelf.friends = users
                } else if strongSelf.friends.count < users.count {
                    let setFriends = Set(strongSelf.friends)
                    let setUsers = Set(users)
                    let differenceUsers = setUsers.subtracting(setFriends)
                    strongSelf.friends.append(contentsOf: differenceUsers)
                } else {
                    let setFriends = Set(strongSelf.friends)
                    let setUsers = Set(users)
                    let differenceUsers = setFriends.subtracting(setUsers)
                    let difFriendNames = Set(differenceUsers.map { $0.name })
                    for user in Array(differenceUsers) {
                        ObtainFriendManager.shared.removeLocationObserver(user: user)
                        for (name, userAnnotation) in strongSelf.friendAnnotations {
                            if difFriendNames.contains(name) {
                                strongSelf.friendAnnotations.removeValue(forKey: name)
                                strongSelf.mainView?.mapView.removeAnnotation(userAnnotation.pointAnnotation)
                            }
                        }
                        for an in strongSelf.mainView?.mapView.annotations ?? [] {
                            if let title = an.title, difFriendNames.contains(title ?? "") {
                                strongSelf.mainView?.mapView.removeAnnotation(an)
                            }
                        }
                    }
                    strongSelf.friends = strongSelf.friends.filter { !differenceUsers.contains($0) }
                }

            }
            .store(in: &cancellable)
    }

    private var friendAnnotations = [String: UserAnnotation]()

    private func obtainActiveUser() {
        ObtainFriendManager.shared.locationUpdateForActiveUser = { friend in
            if let location = friend.location,
               let latitude = location["latitude"],
               let longitude = location["longitude"] {
//                print("\(latitude), \(longitude) \(friend.safeEmail)")
                if let existingAnnotation = self.mainView?.mapView.annotations.first(where: { $0.title == friend.name }) as? MKPointAnnotation {
                    existingAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    // Обновляем дополнительные представления аннотации
                    if let annotationView = self.mainView?.mapView.view(for: existingAnnotation) as? AnnotationView {
                        annotationView.avatarImageView.image = UIImage(data: friend.profilePicture ?? Data()) ?? .profileIcon
                        annotationView.nameLabel.text = friend.name
                    }
                } else {
                    // Если аннотации еще нет, создаем новую и добавляем в словарь
                    let annotation = MKPointAnnotation()
                    let userAnnotation = UserAnnotation(name: friend.name, profilePicture: friend.profilePicture ?? Data(), pointAnnotation: annotation)
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = friend.name
                    annotation.subtitle = friend.safeEmail
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


    func didTappedCloseButton() {
        mainView?.toggleUI()
        let annotationsToRemove = mainView?.mapView.annotations.filter { $0.title??.starts(with: "traces") == true }

        // Удаляем отфильтрованные аннотации с карты
        if let annotationsToRemove = annotationsToRemove {
            mainView?.mapView.removeAnnotations(annotationsToRemove)
        }
    }

    func didTappedButtonWorld() {
//        mainView?.toggleUI()
//        RealTimeDataBaseManager.shared.obtainRouteArray { array in
//            guard let array = array else {
//                return
//            }
//            self.drawRoute(routeArray: array)
//        }

        
    }

    func drawRoute(routeArray: [[String: Double]]) {
        var cnt = 0
        for dict in routeArray {
            if let latitude = dict["latitude"], let longitude = dict["longitude"] {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "traces\(cnt)"
                
                mainView?.mapView.addAnnotation(annotation)
                cnt += 1
            }
        }

    }


    
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
            } else if hDistance ?? 0 > horizontalDistanceCity,
                      vDistance ?? 0 > verticalDistanceCity,
                      hDistance ?? 0 < horizontalDistanceCounty,
                      vDistance ?? 0 < verticalDistanceCounty {
                guard let place = placemark.administrativeArea else { return }
                if place != self.mainView?.locationLabel.text {
                    self.mainView?.locationLabel.text = place
                    self.setWeather(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                }
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
            annotationView.subviews.forEach { $0.removeFromSuperview() }
            let profileAnnotationViewOptional = AnnotationView(name: profile?.name ?? "", image: profile?.profilePicture ?? Data())
            annotationView.addSubview(profileAnnotationView ?? profileAnnotationViewOptional)
            return annotationView
        }

        if annotation.title??.starts(with: "traces") == true {
            var annotationView: TracesAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: "TracesAnnotationIdentifier") as? TracesAnnotationView {
                dequeuedView.annotation = annotation
                annotationView = dequeuedView
                annotationView.subviews.forEach { $0.removeFromSuperview() }
            } else {
                annotationView = TracesAnnotationView(annotation: annotation, reuseIdentifier: "TracesAnnotationIdentifier")
            }
            annotationView.addSubview(annotationView.tracesAnnotationView)
            return annotationView
        }

        if annotation is MKPointAnnotation {
            let identifier = "FriendAnnotation"
            var annotationView: MKAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                annotationView = dequeuedView
                annotationView.subviews.forEach { $0.removeFromSuperview() }
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            let annotationInfo: UserAnnotation?
            if let name = annotationView.annotation?.title {
                annotationInfo = friendAnnotations[name ?? ""]
                let profileAnnotationView = AnnotationView(name: annotationInfo?.name ?? "", image: annotationInfo?.profilePicture ?? Data())
                annotationView.addSubview(profileAnnotationView)
            } else {
                annotationView.image = .add
            }

            

            return annotationView
        }


        return nil
    }



    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let annotation = view.annotation, view.annotation?.title??.starts(with: "traces") != true else { return }

        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
        if view.annotation is MKUserLocation == false {
            let safeEmail = view.annotation?.subtitle ?? ""
            let controller = EmojiController(safeEmail: safeEmail ?? "")
            let height = CGFloat((self.view.window?.windowScene?.screen.bounds.height)!)
            let sheetController = SheetViewController(controller: controller, sizes: [.fixed(height / 3.3)])
            self.present(sheetController, animated: true, completion: nil)
        } else {
            return
        }

    }

}



