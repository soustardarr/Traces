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


    @Published var weather: WeatherData?

    func obtainWeatherAlamofire(latitude: Double, longitude: Double) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
        AF.request(urlString).responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success(let weatherData):
                self.weather = weatherData
            case .failure(let error):
                print("Ошибка получения погоды: \(error)")
            }
        }
    }

}
