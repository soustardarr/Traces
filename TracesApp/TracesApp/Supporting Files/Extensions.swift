//
//  Extensions.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import UIKit
import MapKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

//
//extension MKMapView {
//    func centerCoordinateOnScreen() -> CLLocationCoordinate2D? {
//        let centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
//        let centerCoordinate = self.convert(centerPoint, toCoordinateFrom: self)
//        return centerCoordinate
//    }
//}
