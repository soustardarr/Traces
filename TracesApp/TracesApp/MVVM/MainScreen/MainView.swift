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
}

class MainView: UIView {

    weak var delegate: MainViewDelegate?

    var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
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

    private func addGesture() {
        let gestureProfile = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        buttonProfile.addGestureRecognizer(gestureProfile)
        let gestureFriends = UITapGestureRecognizer(target: self, action: #selector(didTapFriendsButton))
        buttonFriends.addGestureRecognizer(gestureFriends)

        let gestureLocation = UITapGestureRecognizer(target: self, action: #selector(didTapLocationButton))
        buttonLocation.addGestureRecognizer(gestureLocation)
    }

    @objc private func didTapLocationButton() {
        delegate?.didTappedButtonLocation()
    }

    @objc private func didTapProfileButton() {
        delegate?.didTappedButtonProfile()
    }

    @objc private func didTapFriendsButton() {
        delegate?.didTappedButtonFriends()
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
        addSubview(grayViewBottom)
        addSubview(grayViewTop)
        addSubview(buttonProfile)
        addSubview(buttonSettings)
        addSubview(buttonWorld)
        addSubview(buttonLocation)
        addSubview(buttonFriends)
        addSubview(buttonMessages)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),

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
            grayViewTop.heightAnchor.constraint(equalToConstant: 145)
        ])
    }



}
