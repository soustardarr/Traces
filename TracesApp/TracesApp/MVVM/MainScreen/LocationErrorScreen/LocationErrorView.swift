//
//  LocationErrorView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 31.05.2024.
//

import UIKit

class LocationErrorView: UIView {

    var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isUserInteractionEnabled = true
        overlayView.isHidden = true
        return overlayView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.rightAnchor.constraint(equalTo: rightAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor)

        ])

    }

}
