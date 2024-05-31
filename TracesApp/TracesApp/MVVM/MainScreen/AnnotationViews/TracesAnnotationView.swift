//
//  TracesAnnotationView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 30.05.2024.
//

import UIKit
import MapKit

class TracesAnnotationView: MKAnnotationView {

    var tracesAnnotationView: UIView = {
        let tracesAnnotationView = UIView()
        tracesAnnotationView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.5)
        tracesAnnotationView.translatesAutoresizingMaskIntoConstraints = false
        tracesAnnotationView.clipsToBounds = true
        tracesAnnotationView.layer.cornerRadius = 15
        tracesAnnotationView.isUserInteractionEnabled = false
        return tracesAnnotationView
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(tracesAnnotationView)

        NSLayoutConstraint.activate([
            tracesAnnotationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tracesAnnotationView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            tracesAnnotationView.widthAnchor.constraint(equalToConstant: 30),
            tracesAnnotationView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }



}
