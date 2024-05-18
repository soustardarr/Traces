//
//  WeatherManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 18.05.2024.
//

import Foundation
import Combine
import Alamofire

class WeatherManager {

    static let shared = WeatherManager()

    func obtainWeather(latitude: Double, longitude: Double) async throws -> WeatherData? {

        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"

        return try await withCheckedThrowingContinuation { continuation in

            AF.request(urlString).responseDecodable(of: WeatherData.self) { response in
                switch response.result {
                case .success(let weatherData):
                    continuation.resume(returning: weatherData)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

        }
    }


}
