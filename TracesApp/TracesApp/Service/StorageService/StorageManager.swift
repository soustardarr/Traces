//
//  StorageManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import FirebaseStorage

public enum StorageErorrs: Error {
    case failedToUpload
    case failedToGetDownloadURL
}

class StorageManager {

    static let shared = StorageManager()

    private let storage = Storage.storage().reference()

}


extension StorageManager {

    func uploadImage(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> ()) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                completion(.failure(StorageErorrs.failedToUpload))
                return
            }

            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErorrs.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }


    func downloadAvatarDataSelfProfile(_ safeEmail: String, completion: @escaping (Data?) -> ()) {
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        getDownloadUrl(for: path) { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, error == nil else {
                        print("Ошибка при скачивании фото URLSession: \(String(describing: error))")
                        completion(nil)
                        return
                    }
                    completion(data)
                }.resume()
            case .failure(let error):
                print("не удалось найти ссылку на скачивание, getDownloadUrl: \(error)")
                completion(nil)
            }

        }
    }

//    func downloadAvatarDataSelfProfile(completion: @escaping (Data?) -> ()) {
//        guard let email = UserDefaults.standard.string(forKey: "email") else {
//            print("Не удалось получить emil из UserDefaults, он ПУСТ")
//            completion(nil)
//            return
//        }
//        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
//        let fileName = safeEmail + "_profile_picture.png"
//        let path = "images/" + fileName
//        getDownloadUrl(for: path) { result in
//            switch result {
//            case .success(let url):
//                URLSession.shared.dataTask(with: url) { data, _, error in
//                    guard let data = data, error == nil else {
//                        print("Ошибка при скачивании фото URLSession: \(String(describing: error))")
//                        completion(nil)
//                        return
//                    }
//                    completion(data)
//                }.resume()
//            case .failure(let error):
//                print("не удалось найти ссылку на скачивание, getDownloadUrl: \(error)")
//                completion(nil)
//            }
//
//        }
//    }

    func downloadImage(_ photoFileName: String, completionHandler: @escaping (Result<Data, Error>) -> ()) {
        let path = "images/" + photoFileName
        getDownloadUrl(for: path) { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, error == nil else { return }
                    completionHandler(.success(data))
                }.resume()
            case .failure(let error):
                completionHandler(.failure(error))
            }

        }
    }


    func getDownloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> ()){
        let reference = storage.child(path)

        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErorrs.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }

}


