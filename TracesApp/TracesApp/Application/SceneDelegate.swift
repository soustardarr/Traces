//
//  SceneDelegate.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 30.04.2024.
// traces://openProfile?safeEmail=irina@mail,ru

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if let window {
            AppCoordinator.shared.window = window
            AppCoordinator.shared.start()
        }
    }


    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let firstUrl = URLContexts.first, let components = URLComponents(url: firstUrl.url, resolvingAgainstBaseURL: true) {
            switch components.host {
            case "openProfile":
                openScreen(with: components.queryItems ?? [], scene: scene)
            default:
                break
            }

        }
    }

    func openScreen(with queryItems: [URLQueryItem], scene: UIScene) {
        let selfSafeEmail = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        if let safeEmail = queryItems.first(where: { $0.name == "safeEmail" })?.value, selfSafeEmail != safeEmail {
            RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: safeEmail) { result in
                switch result {
                case .success(let user):
                    doInMainThread {
                        guard let windowScene = (scene as? UIWindowScene) else { return }
                        self.window = UIWindow(windowScene: windowScene)
                        if let window = self.window {
                            let peopleVC = PeopleProfileController(avatarimage: UIImage(data: user.profilePicture ?? Data()) ?? .profileIcon, currentUser: user)
                            AppCoordinator.shared.window = window
                            AppCoordinator.shared.startWithDeeplinkVC(peopleVC)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: selfSafeEmail) { result in
                switch result {
                case .success(let user):
                    doInMainThread {
                        guard let windowScene = (scene as? UIWindowScene) else { return }
                        self.window = UIWindow(windowScene: windowScene)
                        if let window = self.window {
                            let peopleVC = ProfileController(user: user)
                            AppCoordinator.shared.window = window
                            AppCoordinator.shared.startWithDeeplinkVC(peopleVC)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) {
        //        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

func doInMainThread(_ work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}
