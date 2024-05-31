//
//  LocationMethods.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 31.05.2024.
//

import Foundation

extension RealTimeDataBaseManager {
    
    func setLocation(latitude: Double, longitude: Double) {
        guard let safeEmail = UserDefaults.standard.string(forKey: "safeEmail") else {
            return
        }
        database.child(safeEmail)
            .child("location")
            .setValue(["latitude": latitude, "longitude": longitude])
    }

    func setRoute(latitude: Double, longitude: Double) {
        guard let safeEmail = UserDefaults.standard.string(forKey: "safeEmail") else {
            return
        }
        database.child(safeEmail)
            .child("route")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var routeArray = snapshot.value as? [[String: Double]] {
                    let dict = ["latitude": latitude, "longitude": longitude]
                    routeArray.append(dict)
                    strongSelf.database.child(safeEmail).child("route").setValue(routeArray)
                } else {
                    var routeArray = [[String: Double]]()
                    let dict = ["latitude": latitude, "longitude": longitude]
                    routeArray.append(dict)
                    strongSelf.database.child("\(safeEmail)/route").setValue(routeArray)
                }
            }
    }

    func obtainRouteArray(completion: @escaping (([[String: Double]]?) -> Void)) {
        guard let safeEmail = UserDefaults.standard.string(forKey: "safeEmail") else {
            return
        }
        database.child(safeEmail)
            .child("route")
            .observeSingleEvent(of: .value) { snapshot in
                guard let routeArray = snapshot.value as? [[String: Double]]  else {
                    completion(nil)
                    return
                }
                completion(routeArray)
            }
    }
}
