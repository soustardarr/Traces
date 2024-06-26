//
//  ProfileController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit

class ProfileController: UIViewController {

    private var headerView: HeaderView?
    private var profileView: ProfileView?
    private var profileViewModel: ProfileViewModel?
    private var profileArray = ["подписчики", "выйти из аккаунта"]
    private var profile: User?
    var profileUrl: String?

    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.profile = user
        let safeEmail = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        self.profileUrl = "traces://openProfile?safeEmail=\(safeEmail)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        obtainProfile()
    }

    private func obtainProfile() {
        guard let email = UserDefaults.standard.string(forKey: "safeEmail") else {
            print("Не удалось получить emil из UserDefaults, он ПУСТ")
            return
        }
        self.profileUrl = "traces://openProfile?safeEmail=\(email)"
        RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: email) { result in
            switch result {
            case .success(let user):
                doInMainThread {
                    self.profile = user
                    self.headerView?.avatarImageView.image = UIImage(data: user.profilePicture ?? Data())
                    self.headerView?.nameLabel.text = user.name
                }
            case .failure(let error):
                print("ошибка получения профиля для MainVC \(error)")
            }
        }
    }


    private func setup() {
        profileView = ProfileView()
        view = profileView
        profileView?.tableView.delegate = self
        profileView?.tableView.dataSource = self
        profileView?.tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
        headerView = HeaderView()
        headerView?.delegate = self
        headerView?.avatarImageView.image = UIImage(data: profile?.profilePicture ?? Data())
        headerView?.nameLabel.text = profile?.name
        profileViewModel = ProfileViewModel()
    }


    func didTappedSignOutButton() {
        let controller = UIAlertController(title: "выход из аккаунта", message: "хотите выйти?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "да", style: .destructive, handler: { [ weak self ] _ in
            guard let strongSelf = self else { return }
            strongSelf.profileViewModel?.signOut()

        }))
        controller.addAction(UIAlertAction(title: "нет", style: .default))
        present(controller, animated: true)
    }

}


extension ProfileController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            present(FollowersController(), animated: true)
        case 1:
            didTappedSignOutButton()
        default:
            break
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return headerView
        default:
            return nil
        }
    }


}


extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        400
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier, for: indexPath) as? ProfileTableViewCell
        cell?.config(with: profileArray[indexPath.row])
        return cell ?? UITableViewCell()
    }

}

extension ProfileController: HeaderViewDelegate {
    func didTappedShareProfile() {
        let controller = UIAlertController(title: "Ссылка скопированна", message: "Поделись с другом!", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "ок", style: .cancel))
        guard let url = profileUrl else {
            print("дождись загрузки профиля")
            return
        }
        UIPasteboard.general.string = url
        present(controller, animated: true)
    }
}
