//
//  MainView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit
import MapKit

protocol MainViewDelegate: AnyObject {
    func didTappedButtonProfile()
    func didTappedButtonSettings()
    func didTappedButtonWorld()
    func didTappedButtonLocation()
    func didTappedButtonFriends()
    func didTappedButtonMessages()
    func didTappedCloseButton()
}

class MainView: UIView {

    weak var delegate: MainViewDelegate?

    var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.boldSystemFont(ofSize: 20)
        locationLabel.textColor = .black
        locationLabel.numberOfLines = 0
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        return locationLabel
    }()

    var weatherLabel: UILabel = {
        let weatherLabel = UILabel()
        weatherLabel.font = UIFont.boldSystemFont(ofSize: 16)
        weatherLabel.textColor = .black
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        return weatherLabel
    }()

    var buttonProfile: UIImageView = {
        let switchToProfile = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        let profileImage = UIImage(systemName: "person.circle.fill", withConfiguration: colorConfig)
        switchToProfile.image = profileImage
        switchToProfile.isUserInteractionEnabled = true
        switchToProfile.translatesAutoresizingMaskIntoConstraints = false
        return switchToProfile
    }()

    var buttonSettings: UIImageView = {
        let buttonSettings = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        let settingsImage = UIImage(systemName: "gear.circle.fill", withConfiguration: colorConfig)
        buttonSettings.image = settingsImage
        buttonSettings.isUserInteractionEnabled = true
        buttonSettings.translatesAutoresizingMaskIntoConstraints = false
        return buttonSettings
    }()

    var buttonWorld: UIImageView = {
        let buttonWorld = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.white])
        let worldImage = UIImage(systemName: "globe.asia.australia.fill", withConfiguration: colorConfig)
        buttonWorld.clipsToBounds = true
        buttonWorld.layer.cornerRadius = 35/2
        buttonWorld.image = worldImage
        buttonWorld.isUserInteractionEnabled = true
        buttonWorld.translatesAutoresizingMaskIntoConstraints = false
        return buttonWorld
    }()

    var buttonLocation: UIImageView = {
        let buttonLocation = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        let loctionImage = UIImage(systemName: "location.north.circle.fill", withConfiguration: colorConfig)
        buttonLocation.image = loctionImage
        buttonLocation.isUserInteractionEnabled = true
        buttonLocation.translatesAutoresizingMaskIntoConstraints = false
        return buttonLocation
    }()

    var buttonFriends: UIImageView = {
        let buttonFriends = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        let friendsImage = UIImage(systemName: "figure.2.circle.fill", withConfiguration: colorConfig)
        buttonFriends.image = friendsImage
        buttonFriends.isUserInteractionEnabled = true
        buttonFriends.translatesAutoresizingMaskIntoConstraints = false
        return buttonFriends
    }()

    var buttonMessages: UIImageView = {
        let buttonMessages = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        let messagesImage = UIImage(systemName: "message.circle.fill", withConfiguration: colorConfig)
        buttonMessages.image = messagesImage
        buttonMessages.isUserInteractionEnabled = true
        buttonMessages.translatesAutoresizingMaskIntoConstraints = false
        return buttonMessages
    }()

    var grayViewBottom: UIView = {
        let grayView = UIView()
        grayView.backgroundColor = .black
        grayView.clipsToBounds = true
        grayView.layer.cornerRadius = 35
        grayView.translatesAutoresizingMaskIntoConstraints = false
        return grayView
    }()

    var grayViewTop: UIView = {
        let grayView = UIView()
        grayView.backgroundColor = .black
        grayView.clipsToBounds = true
        grayView.layer.cornerRadius = 20
        grayView.translatesAutoresizingMaskIntoConstraints = false
        return grayView
    }()

    var userForMap: UIImageView = {
        let userForMap = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.white, .systemGreen])
        let profileImage = UIImage(systemName: "figure.walk.circle.fill", withConfiguration: colorConfig)
        userForMap.image = profileImage
        userForMap.isUserInteractionEnabled = true
        userForMap.translatesAutoresizingMaskIntoConstraints = false
        userForMap.widthAnchor.constraint(equalToConstant: 40).isActive = true
        userForMap.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userForMap.backgroundColor = .white
        userForMap.layer.borderWidth = 1
        userForMap.layer.borderColor = UIColor.black.cgColor
        userForMap.clipsToBounds = true
        userForMap.layer.cornerRadius = 20
        return userForMap
    }()


    var buttonClose: UIImageView = {
        let buttonClose = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.systemIndigo])
        let messagesImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: colorConfig)
        buttonClose.image = messagesImage
        buttonClose.isUserInteractionEnabled = true
        buttonClose.isHidden = true
        buttonClose.translatesAutoresizingMaskIntoConstraints = false
        return buttonClose
    }()

    var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isUserInteractionEnabled = false // Разрешает перехват событий нажатия, но не делает это, так как цвет фона прозрачный
        overlayView.isHidden = true
        return overlayView
    }()

    func toggleUI() {
        locationLabel.isHidden.toggle()
        weatherLabel.isHidden.toggle()
        buttonProfile.isHidden.toggle()
        buttonSettings.isHidden.toggle()
        buttonWorld.isHidden.toggle()
        buttonLocation.isHidden.toggle()
        buttonFriends.isHidden.toggle()
        buttonMessages.isHidden.toggle()
        grayViewBottom.isHidden.toggle()
        grayViewTop.isHidden.toggle()
        overlayView.isHidden.toggle()
        buttonClose.isHidden.toggle()
    }




    private func addGesture() {
        let gestureProfile = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        buttonProfile.addGestureRecognizer(gestureProfile)
        let gestureFriends = UITapGestureRecognizer(target: self, action: #selector(didTapFriendsButton))
        buttonFriends.addGestureRecognizer(gestureFriends)

        let gestureLocation = UITapGestureRecognizer(target: self, action: #selector(didTapLocationButton))
        buttonLocation.addGestureRecognizer(gestureLocation)

        let gestureChat = UITapGestureRecognizer(target: self, action: #selector(didTapChatButton))
        buttonMessages.addGestureRecognizer(gestureChat)

        let gestureWorld = UITapGestureRecognizer(target: self, action: #selector(didTapButtonWorld))
        buttonWorld.addGestureRecognizer(gestureWorld)

        let gestureClose = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))
        buttonClose.addGestureRecognizer(gestureClose)
    }

    @objc private func didTapChatButton() {
        delegate?.didTappedButtonMessages()
    }

    @objc private func didTapLocationButton() {
        delegate?.didTappedButtonLocation()
    }

    @objc private func didTapFriendsButton() {
        delegate?.didTappedButtonFriends()
    }

    @objc private func didTapProfileButton() {
        delegate?.didTappedButtonProfile()
    }

    @objc private func didTapButtonWorld() {
        delegate?.didTappedButtonWorld()
    }

    @objc private func didTapCloseButton() {
        delegate?.didTappedCloseButton()
    }



    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
        addGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setUpLayout() {
        addSubview(mapView)
        addSubview(locationLabel)
        addSubview(weatherLabel)
        addSubview(grayViewBottom)
        addSubview(grayViewTop)
        addSubview(buttonProfile)
        addSubview(buttonSettings)
        addSubview(buttonWorld)
        addSubview(buttonLocation)
        addSubview(buttonFriends)
        addSubview(buttonMessages)
        addSubview(overlayView)
        addSubview(buttonClose)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonClose.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 1),
            buttonClose.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonClose.widthAnchor.constraint(equalToConstant: 35),
            buttonClose.heightAnchor.constraint(equalToConstant: 35),

            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            locationLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),

            weatherLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            weatherLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),

            buttonProfile.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            buttonProfile.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            buttonProfile.widthAnchor.constraint(equalToConstant: 35),
            buttonProfile.heightAnchor.constraint(equalToConstant: 35),

            buttonSettings.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            buttonSettings.topAnchor.constraint(equalTo: buttonProfile.bottomAnchor, constant: 15),
            buttonSettings.widthAnchor.constraint(equalToConstant: 35),
            buttonSettings.heightAnchor.constraint(equalToConstant: 35),

            buttonWorld.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            buttonWorld.topAnchor.constraint(equalTo: buttonSettings.bottomAnchor, constant: 15),
            buttonWorld.widthAnchor.constraint(equalToConstant: 35),
            buttonWorld.heightAnchor.constraint(equalToConstant: 35),

            buttonLocation.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonLocation.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonLocation.heightAnchor.constraint(equalToConstant: 60),
            buttonLocation.widthAnchor.constraint(equalToConstant: 60),


            buttonMessages.leadingAnchor.constraint(equalTo: buttonLocation.trailingAnchor, constant: 20),
            buttonMessages.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonMessages.heightAnchor.constraint(equalToConstant: 60),
            buttonMessages.widthAnchor.constraint(equalToConstant: 60),

            buttonFriends.trailingAnchor.constraint(equalTo: buttonLocation.leadingAnchor, constant: -20),
            buttonFriends.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonFriends.heightAnchor.constraint(equalToConstant: 60),
            buttonFriends.widthAnchor.constraint(equalToConstant: 60),

            grayViewBottom.widthAnchor.constraint(equalToConstant: 230),
            grayViewBottom.heightAnchor.constraint(equalToConstant: 70),
            grayViewBottom.centerXAnchor.constraint(equalTo: centerXAnchor),
            grayViewBottom.centerYAnchor.constraint(equalTo: buttonLocation.centerYAnchor),

            grayViewTop.centerXAnchor.constraint(equalTo: buttonSettings.centerXAnchor),
            grayViewTop.centerYAnchor.constraint(equalTo: buttonSettings.centerYAnchor),
            grayViewTop.widthAnchor.constraint(equalToConstant: 40),
            grayViewTop.heightAnchor.constraint(equalToConstant: 145),

            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }



}
