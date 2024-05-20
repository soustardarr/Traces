//
//  WeatherManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 18.05.2024.
//

import Foundation
import Combine
//import Alamofire

class WeatherManager {

    static let shared = WeatherManager()

//    func obtainWeather(latitude: Double, longitude: Double) async throws -> WeatherData? {
//        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
//        guard let url = URL(string: urlString) else {
//            print("не URL")
//            return nil
//        }
//        return try await withCheckedThrowingContinuation { continuation in
//            AF.request(urlString).responseDecodable(of: WeatherData.self) { response in
//                switch response.result {
//                case .success(let weatherData):
//                    continuation.resume(returning: weatherData)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//
//        }
//    }


    func obtainWeather(latitude: Double, longitude: Double) async throws -> WeatherData? {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)

        return weatherData
    }


}
